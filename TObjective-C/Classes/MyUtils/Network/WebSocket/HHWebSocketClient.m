//
//  HHWebSocketManager.m
//  TSocket
//
//  Created by HeiHuaBaiHua on 2017/9/11.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <YYModel/YYModel.h>
#import <RealReachability/RealReachability.h>

#import "HHFoundation.h"

#import "HHWebSocket.h"
#import "HHWebSocketClient.h"
#import "HHWebSocketService.h"
#import "HHNetworkTaskError.h"
#import "HHWebSocketMessageParser.h"
@interface HHWebSocketTask()

- (HHWebSocketRequest *)request;
- (void)setClient:(id)client;
- (void)completeWithResponseData:(id)responseData error:(NSError *)error;

@end

@interface HHWebSocketClient()<HHWebSocketDelegate>

@property (nonatomic, strong) HHWebSocket *socket;

@property (nonatomic, strong) HHNotifier<HHWebSocketNotificationObserver> *observer;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, HHWebSocketTask *> *dispatchTable;
@end

@implementation HHWebSocketClient

static dispatch_semaphore_t lock;
+ (instancetype)sharedInstance {
    static HHWebSocketClient *sharedInstance;
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

#pragma mark - Interface(Public)

- (void)connect {
    if (self.socket.isConnected) { return; }
    
    [self.socket connect];
}

- (NSNumber *)dispatchDataTaskWithRequest:(HHWebSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
//    if (request.url < minRequestUrl || request.url > maxRequestUrl) { return @-1; }
    
    HHWebSocketTask *task = [self dataTaskWithRequest:request completionHandler:completionHandler];
    return [self dispatchTask:task];
}

- (void)addObserver:(id<HHWebSocketNotificationObserver>)observer {
    [self.observer addObserver:observer];
}

- (void)cancelAllTasks {
    
    for (HHWebSocketTask *task in self.dispatchTable.allValues) {
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

- (void)resumeTask:(HHWebSocketTask *)task {
    
    if (self.socket.isConnected) {
        [self.socket writeData:task.request.requestData];
    } else {
        
        NSError *error;
        if ([self isNetworkReachable]) {
            error = HHError(HHNetworkErrorNotice, HHNetworkTaskErrorTimeOut);
        } else {
            error = HHError(HHNetworkErrorNotice, HHNetworkTaskErrorCannotConnectedToInternet);
        }
        [task completeWithResponseData:nil error:error];
    }
}

#pragma mark - HHWebSocketDelegate

- (void)socketDidConnected:(HHWebSocket *)socket {
    if ([self.observer respondsToSelector:@selector(didConnectToSocketServer)]) {
        [self.observer didConnectToSocketServer];
    }
}

- (void)socketCanNotConnectToService:(HHWebSocket *)socket {
    [self reconnect];
}

- (void)socket:(HHWebSocket *)socket didReceiveMessage:(id)message {
    [self handleMessage:message];
}

- (void)socket:(HHWebSocket *)socket didFailWithError:(NSError *)error {
    if (self.socket.isConnected) { return; }
    
    for (HHWebSocketTask *task in self.dispatchTable.allValues) {
        [task completeWithResponseData:nil error:HHError(@"长连接已断开", HHNetworkTaskErrorCannotConnectedToInternet)];
    }
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    [self.dispatchTable removeAllObjects];
    dispatch_semaphore_signal(lock);
}

#pragma mark - Utils

- (void)configuration {
    
    self.dispatchTable = [NSMutableDictionary dictionary];
    self.observer = (id)[HHNotifier notifier];
    self.socket = [HHWebSocket new];
    self.socket.delegate = self;
}

- (void)reconnect {
    [self.socket reconnect];
}

- (HHWebSocketTask *)dataTaskWithRequest:(HHWebSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    __block NSNumber *taskIdentifier;
    HHWebSocketTask *task = [HHWebSocketTask taskWithRequest:request completionHandler:^(NSError *error, id result) {
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

- (NSNumber *)dispatchTask:(HHWebSocketTask *)task {
    if (task == nil) { return @-1; }
    
    [task resume];
    return task.taskIdentifier;
}

- (void)handleMessage:(id)message {
    if (message == nil) { return; }
    if ([message isKindOfClass:[NSString class]]) {
        message = [(NSString *)message dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSDictionary *messageDict = [NSJSONSerialization JSONObjectWithData:message options:0 error:NULL];
    if (messageDict == nil) { return; }
    
    HHWebSocketRequestURL url = [HHWebSocketMessageParser responseURLFromMessage:messageDict];
    if (url > WEBSOCKET_max_notification) {/** 请求响应 */
    
        NSNumber *serNum = [HHWebSocketMessageParser responseSerialNumberFromMessage:messageDict];
        NSDictionary *responseData = [HHWebSocketMessageParser responseDataFromMessage:messageDict];
        HHWebSocketTask *task = self.dispatchTable[serNum];
        [task completeWithResponseData:responseData error:nil];
    }  else {/** 推送 */
        if ([self.observer respondsToSelector:@selector(didReceiveSocketNotification:)]) {
            [self.observer didReceiveSocketNotification:messageDict];
        }
    }
}

- (BOOL)isNetworkReachable {
    
    ReachabilityStatus status = GLobalRealReachability.currentReachabilityStatus;
    return status == RealStatusViaWWAN || status == RealStatusViaWiFi;
}

@end
