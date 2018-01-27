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

- (NSData *)taskData;

- (void)setClient:(id)client;
- (void)completeWithResponseData:(NSData *)responseData error:(NSError *)error;

@end

@interface HHTCPSocketClient()<HHTCPSocketDelegate>

@property (strong, nonatomic) HHTCPSocket *socket;
@property (strong, nonatomic) NSMutableData *readData;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, HHTCPSocketTask *> *dispathTable;

@property (strong, nonatomic) HHTCPSocketHeartbeat *heatbeat;

@end

@implementation HHTCPSocketClient

static dispatch_semaphore_t lock;
+ (instancetype)sharedInstance {
    static HHTCPSocketClient *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        lock = dispatch_semaphore_create(1);
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.socket = [HHTCPSocket socketWithDelegate:self];
        self.readData = [NSMutableData data];
        self.dispathTable = [NSMutableDictionary dictionary];
//        self.heatbeat = [HHTCPSocketHeartbeat heartbeatWithClient:self timeoutHandler:^{
//            [self reconnect];
//        }];
    }
    return self;
}

#pragma mark - Interface(Public)

- (void)connect {
    if (self.socket.isConnectd) { return; }
    
    [self.socket connectWithRetryTime:5];
}

- (void)disconncet {
    [self.socket disconnect];
}

- (NSNumber *)dispatchDataTaskWithRequest:(HHTCPSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    HHTCPSocketTask *task = [self dataTaskWithRequest:request completionHandler:completionHandler];
    return [self dispatchTask:task];
}

- (void)cancelAllTasks {
    
    for (HHTCPSocketTask *task in self.dispathTable.allValues) {
        [task cancel];
    }
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    [self.dispathTable removeAllObjects];
    dispatch_semaphore_signal(lock);
}

- (void)cancelTaskWithTaskIdentifier:(NSNumber *)taskIdentifier {
    
    HHTCPSocketTask *task = [self.dispathTable objectForKey:taskIdentifier];
    if (task) { [task cancel]; }
}

#pragma mark - Interface(Friend)

- (void)resumeTask:(HHTCPSocketTask *)task {
 
    if (self.socket.isConnectd) {
        [self.socket writeData:task.taskData];
    } else {
     
        NSError *error;
        if (self.isNetworkReachable) {
            error = HHError(HHNetworkErrorNotice, HHNetworkTaskErrorTimeOut);
        } else {
            error = HHError(HHNetworkErrorNotice, HHNetworkTaskErrorCannotConnectedToInternet);
        }
        
        [self reconnect];
        [task completeWithResponseData:nil error:error];
    }
}

#pragma mark - HHTCPSocketDelegate

- (void)socket:(HHTCPSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didConnectToHost" object:nil];
}

- (void)socketDidDisconnect:(HHTCPSocket *)sock error:(NSError *)error {
    
    [self.heatbeat stop];
    [self reconnect];
}

- (void)socketCanNotConnectToService:(HHTCPSocket *)sock {
    [self reconnect];
}

- (void)socket:(HHTCPSocket *)sock didReadData:(NSData *)data {
    
    [self.heatbeat reset];
    if (data.length >= HHMaxResponseLength) { return; }
    
    [self.readData appendData:data];
    NSData *responseData = [self getParsedResponseData];
    if (responseData) {
        
        NSNumber *taskIdentifier = @([HHTCPSocketResponseFormatter responseSerialNumberFromData:responseData]);
        HHTCPSocketTask *task = self.dispathTable[taskIdentifier];
        if (task) {
            dispatch_async(dispatch_get_global_queue(2, 0), ^{
                [task completeWithResponseData:responseData error:nil];
            });
        } else {
            
            //            switch ([taskIdentifier integerValue]) {
            //                case HHTCPSocketTaskPush: {
            //
            //                }   break;
            //
            //                case HHTCPSocketTaskHearbeat: {
            //
            //                    NSLog(@"心跳%d",[taskIdentifier intValue]);
            //                    [self.heatbeat respondToServerWithSerialNum:[taskIdentifier intValue]];
            //                }
            //                default: break;
            //            }
            //            NSLog(@"心跳%d",[taskIdentifier intValue]);
            [self.heatbeat respondToServerWithSerialNum:[taskIdentifier intValue]];
        }
    }
}

#pragma mark - Utils

- (HHTCPSocketTask *)dataTaskWithRequest:(HHTCPSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    NSMutableArray *taskIdentifier = [NSMutableArray arrayWithObject:@-1];
    HHTCPSocketTask *task = [HHTCPSocketTask taskWithRequest:request completionHandler:^(NSError *error, id result) {
        
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        [self.dispathTable removeObjectForKey:taskIdentifier.firstObject];
        dispatch_semaphore_signal(lock);
        
        !completionHandler ?: completionHandler(error, result);
    }];
    task.client = self;
    taskIdentifier[0] = task.taskIdentifier;
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    [self.dispathTable setObject:task forKey:taskIdentifier.firstObject];
    dispatch_semaphore_signal(lock);
    
    return task;
}

- (NSNumber *)dispatchTask:(HHTCPSocketTask *)task {
    
    if (task == nil) { return @-1; }
    
    [task resume];
    return task.taskIdentifier;
}

- (void)reconnect {
    
    for (HHTCPSocketTask *task in self.dispathTable.allValues) {
        [task completeWithResponseData:nil error:HHError(@"长连接已断开", HHTCPSocketTaskErrorLostConnection)];
    }
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    self.readData = [NSMutableData data];
    [self.dispathTable removeAllObjects];
    dispatch_semaphore_signal(lock);
    
    [self.socket connectWithRetryTime:8];
}

- (NSData *)getParsedResponseData {
    
    NSData *responseData;
    NSData *totalReceivedData = self.readData;
    if (totalReceivedData.length >= HHMaxResponseLength * 2) {
        [self reconnect];//socket解析错误, 断开重连
    } else if (totalReceivedData.length >= MsgResponseHeaderLength) {
        
        HHTCPSocketResponseFormatter *formatter = [HHTCPSocketResponseFormatter formatterWithResponseData:totalReceivedData];
        int msgContentLength = formatter.responseContentLength;
        int msgResponseLength = msgContentLength + MsgResponseHeaderLength;
        if (msgResponseLength == totalReceivedData.length) {
            
            responseData = totalReceivedData;
            self.readData = [NSMutableData data];
        } else if (msgContentLength < totalReceivedData.length) {
            
            responseData = [totalReceivedData subdataWithRange:NSMakeRange(0, msgResponseLength)];
            self.readData = [[totalReceivedData subdataWithRange:NSMakeRange(msgResponseLength, totalReceivedData.length - msgResponseLength)] mutableCopy];
        }
    }
    
    return responseData;
}

- (BOOL)isNetworkReachable {
    
    ReachabilityStatus status = GLobalRealReachability.currentReachabilityStatus;
    return status == RealStatusViaWWAN || status == RealStatusViaWiFi;
}

@end
