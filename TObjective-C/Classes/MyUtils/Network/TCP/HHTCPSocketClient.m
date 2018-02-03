//
//  HHTCPSocketClient.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/16.
//  Copyright © 2017年 黑花白花. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <RealReachability/RealReachability.h>

#import "HHTCPSocketClient.h"

#import "HHTCPSocket.h"
#import "HHTCPSocketTask.h"
#import "HHTCPSocketRequest.h"

#import "HHTCPSocketHeartbeat.h"

@interface HHTCPSocketTask ()

+ (instancetype)taskWithRequest:(HHTCPSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler;

- (void)setClient:(id)client;
- (void)completeWithResponseData:(NSData *)responseData error:(NSError *)error;

@end

@interface HHTCPSocketClient()<HHTCPSocketDelegate>

@property (nonatomic, strong) HHTCPSocket *socket;
@property (nonatomic, strong) NSMutableData *buffer;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, HHTCPSocketTask *> *dispatchTable;

@property (nonatomic, assign) BOOL isReading;
@property (nonatomic, strong) HHTCPSocketHeartbeat *heatbeat;

@end

#if 0
# define SocketLog(...) NSLog(__VA_ARGS__)
#else
# define SocketLog(...) {}
#endif

@implementation HHTCPSocketClient

static dispatch_semaphore_t lock;
+ (instancetype)sharedInstance {
    static HHTCPSocketClient *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        lock = dispatch_semaphore_create(1);
        sharedInstance = [super allocWithZone:NULL];
        [sharedInstance configuration];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)configuration {
    
    self.socket = [HHTCPSocket new];
    self.socket.delegate = self;
    self.buffer = [NSMutableData data];
    self.dispatchTable = [NSMutableDictionary dictionary];
    self.heatbeat = [HHTCPSocketHeartbeat heartbeatWithClient:self timeoutHandler:^{
        //            [self reconnect];
        SocketLog(@"heartbeat timeout");
    }];
}

#pragma mark - Interface(Public)

- (void)connect {
    if (self.socket.isConnected) { return; }
    
    [self.socket connect];
}

- (NSNumber *)dispatchDataTaskWithRequest:(HHTCPSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
//    if (request.url < minRequestUrl || request.url > maxRequestUrl) { return @-1; }
    
    HHTCPSocketTask *task = [self dataTaskWithRequest:request completionHandler:completionHandler];
    return [self dispatchTask:task];
}

- (void)cancelAllTasks {
    
    for (HHTCPSocketTask *task in self.dispatchTable.allValues) {
        [task cancel];
    }
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    [self.dispatchTable removeAllObjects];
    dispatch_semaphore_signal(lock);
}

- (void)cancelTaskWithTaskIdentifier:(NSNumber *)taskIdentifier {
    if (!taskIdentifier) { return; }
    
    [self.dispatchTable[taskIdentifier] cancel];
}

#pragma mark - Interface(Friend)

- (void)resumeTask:(HHTCPSocketTask *)task {
 
    if (self.socket.isConnected) {
        [self.socket writeData:task.request.requestData];
    } else {
     
        NSError *error;
        if (self.isNetworkReachable) {
            error = HHError(HHNetworkErrorNotice, HHNetworkTaskErrorTimeOut);
        } else {
            error = HHError(HHNetworkErrorNotice, HHNetworkTaskErrorCannotConnectedToInternet);
        }
        [task completeWithResponseData:nil error:error];
    }
}

#pragma mark - HHTCPSocketDelegate

- (void)socket:(HHTCPSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self.heatbeat reset];
}

- (void)socketDidDisconnect:(HHTCPSocket *)sock error:(NSError *)error {
    [self.heatbeat stop];
}

- (void)socketCanNotConnectToService:(HHTCPSocket *)sock {
    [self reconnect];
}

- (void)socket:(HHTCPSocket *)sock didReadData:(NSData *)data {
    [self.buffer appendData:data];
    [self.heatbeat reset];
    
    [self readBuffer];
}

#pragma mark - Parse

- (void)readBuffer {
    if (self.isReading) { return; }
    
    self.isReading = YES;
    NSData *responseData = [self getParsedResponseData];
    [self dispatchResponse:responseData];
    self.isReading = NO;
    
    if (responseData.length == 0) { return; }
    [self readBuffer];
}

- (NSData *)getParsedResponseData {
    
    NSData *totalReceivedData = self.buffer;
    uint32_t responseHeaderLength = [HHTCPSocketResponseParser responseHeaderLength];
    if (totalReceivedData.length < responseHeaderLength) { return nil; }
    
    NSData *responseData;
    uint32_t responseContentLength = [HHTCPSocketResponseParser responseContentLengthFromData:totalReceivedData];;
    uint32_t responseLength = responseHeaderLength + responseContentLength;
    if (totalReceivedData.length < responseLength) { return nil; }
    
    SocketLog(@"before: %u_%lu", responseLength, self.readData.length);
    responseData = [totalReceivedData subdataWithRange:NSMakeRange(0, responseLength)];
    self.buffer = [[totalReceivedData subdataWithRange:NSMakeRange(responseLength, totalReceivedData.length - responseLength)] mutableCopy];
    SocketLog(@"after: %u_%lu", responseLength, self.readData.length);
    SocketLog(@"---------");
    return responseData;
}

- (void)dispatchResponse:(NSData *)responseData {
    if (responseData.length == 0) { return; }
    
    uint32_t url = [HHTCPSocketResponseParser responseURLFromData:responseData];
    if (url > TCP_max_notification) {/** 请求响应 */
        
        NSNumber *taskIdentifier = @([HHTCPSocketResponseParser responseSerialNumberFromData:responseData]);
        HHTCPSocketTask *task = self.dispatchTable[taskIdentifier];
        if (task) {
            dispatch_async(dispatch_get_global_queue(2, 0), ^{
                [task completeWithResponseData:responseData error:nil];
            });
        }
    } else if (url == TCP_heatbeat) {/** 心跳 */
        uint32_t ackNum = [HHTCPSocketResponseParser responseSerialNumberFromData:responseData];
        [self.heatbeat handleServerAckNum:ackNum];
    } else {/** 推送 */
        [self dispatchRemoteNotification:url responseData:responseData];
    }
}

- (void)dispatchRemoteNotification:(HHTCPSocketRequestURL)notification responseData:(NSData *)responseData {
    
    NSData *responseContent = [HHTCPSocketResponseParser responseContentFromData:responseData];
    NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:responseContent options:0 error:nil];
    switch (notification) {
        case TCP_notification_xxx: {
            NSLog(@"received notification_xxx: %@", userInfo);
        }   break;

        case TCP_notification_yyy: {
            NSLog(@"received notification_yyy: %@", userInfo);
        }   break;

        case TCP_notification_zzz: {
            NSLog(@"received notification_zzz: %@", userInfo);
        }   break;

        default:break;
    }
}

#pragma mark - Utils

- (HHTCPSocketTask *)dataTaskWithRequest:(HHTCPSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    __block NSNumber *taskIdentifier;
    HHTCPSocketTask *task = [HHTCPSocketTask taskWithRequest:request completionHandler:^(NSError *error, id result) {
        
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        [self.dispatchTable removeObjectForKey:taskIdentifier];
        dispatch_semaphore_signal(lock);
        
        !completionHandler ?: completionHandler(error, result);
    }];
    task.client = self;
    taskIdentifier = task.taskIdentifier;
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    [self.dispatchTable setObject:task forKey:taskIdentifier];
    dispatch_semaphore_signal(lock);
    
    return task;
}

- (NSNumber *)dispatchTask:(HHTCPSocketTask *)task {
    if (task == nil) { return @-1; }
    
    [task resume];
    return task.taskIdentifier;
}

- (void)reconnect {
    
    for (HHTCPSocketTask *task in self.dispatchTable.allValues) {
        [task completeWithResponseData:nil error:HHError(@"长连接已断开", HHTCPSocketResponseCodeLostConnection)];
    }
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    self.buffer = [NSMutableData data];
    [self.dispatchTable removeAllObjects];
    dispatch_semaphore_signal(lock);
    
    [self.socket reconnect];
}

- (BOOL)isNetworkReachable {
    
    ReachabilityStatus status = GLobalRealReachability.currentReachabilityStatus;
    return status == RealStatusViaWWAN || status == RealStatusViaWiFi;
}

@end
