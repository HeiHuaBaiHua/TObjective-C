//
//  HHSocketManager.m
//  TSocket
//
//  Created by leihaiyin on 2017/9/11.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <YYModel/YYModel.h>
#import <RealReachability/RealReachability.h>

#import "HHSocket.h"
#import "HHFoundation.h"
#import "HHSocketClient.h"
#import "HHSocketService.h"
#import "HHNetworkTaskError.h"
@interface HHSocketTask()

- (HHSocketRequest *)request;
- (void)setClient:(id)client;
- (void)completeWithResponseData:(id)responseData error:(NSError *)error;

@end

@interface HHSocketClient()<HHSocketDelegate>

@property (nonatomic, strong) HHSocket *socket;
@property (nonatomic, strong) HHSocketService *service;

@property (nonatomic, strong) HHNotifier<HHSocketNotificationObserver> *observer;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, HHSocketTask *> *dispathTable;
@end

@implementation HHSocketClient

static dispatch_semaphore_t lock;
+ (instancetype)sharedClient {
    static HHSocketClient *sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        lock = dispatch_semaphore_create(1);
        sharedClient = [super allocWithZone:NULL];
        [sharedClient configuration];
    });
    return sharedClient;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedClient];
}

#pragma mark - Interface(Public)

- (void)connect {
    if (self.socket.isConnected) { return; }
    
    HHSocketConfig *config = [HHSocketConfig new];
    config.url = self.service.url;
    config.heartbeatMessage = @"heartbeat";
    
    self.socket = [[HHSocket alloc] initWithConfig:config];
    self.socket.delegate = self;
    [self.socket connect];
}

- (NSNumber *)dispatchDataTaskWithRequest:(HHSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    HHSocketTask *task = [self dataTaskWithRequest:request completionHandler:completionHandler];
    return [self dispatchTask:task];
}

- (void)addObserver:(id<HHSocketNotificationObserver>)observer {
    [self.observer addObserver:observer];
}

#pragma mark - Interface(Friend)

- (void)resumeTask:(HHSocketTask *)task {
    
    if (self.socket.isConnected) {
        [self.socket sendData:task.request.requestBody];
    } else {
        
        NSError *error;
        if ([self isNetworkReachable]) {
            error = HHError(HHNetworkErrorNotice, HHNetworkTaskErrorTimeOut);
        } else {
            error = HHError(HHNetworkErrorNotice, HHNetworkTaskErrorCannotConnectedToInternet);
        }
        [self reconnect];
        [task completeWithResponseData:nil error:error];
    }
}

#pragma mark - HHSocketDelegate

- (void)socketDidConnected:(HHSocket *)socket {
    if ([self.observer respondsToSelector:@selector(didConnectToSocketServer)]) {
        [self.observer didConnectToSocketServer];
    }
}

- (void)socketCanNotConnectToService:(HHSocket *)socket {
    [self reconnect];
}

- (void)socket:(HHSocket *)socket didReceiveMessage:(id)message {
    [self handleMessage:message];
}

- (void)socket:(HHSocket *)socket didFailWithError:(NSError *)error {
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    for (HHSocketTask *task in self.dispathTable.allValues) {
        [task completeWithResponseData:nil error:HHError(@"长连接已断开", HHNetworkTaskErrorCannotConnectedToInternet)];
    }
    [self.dispathTable removeAllObjects];
    dispatch_semaphore_signal(lock);
}

#pragma mark - Utils

- (void)configuration {
    
    self.dispathTable = [NSMutableDictionary dictionary];
    self.observer = (id)[HHNotifier notifier];
    self.service = [HHSocketService serviceWithType:HHService0];
}

- (void)reconnect {
    
    if ([self isNetworkReachable]) {
        [self.socket reconnect];
    }
}

- (HHSocketTask *)dataTaskWithRequest:(HHSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    NSMutableArray *taskIdentifier = [NSMutableArray arrayWithObject:@-1];
    HHSocketTask *task = [HHSocketTask taskWithRequest:request completionHandler:^(NSError *error, id result) {
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

- (NSNumber *)dispatchTask:(HHSocketTask *)task {
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
    
    NSString *responseId = messageDict[@"id"];
    if (!responseId) {/** 后台推送 */
        
        if ([self.observer respondsToSelector:@selector(didReceiveSocketNotification:)]) {
            [self.observer didReceiveSocketNotification:messageDict];
        }
    } else {/** 客户端主动发出请求返回的response */
        
        HHSocketTask *task = self.dispathTable[@(responseId.integerValue)];
        [task completeWithResponseData:messageDict error:nil];
    }
}

- (BOOL)isNetworkReachable {
    
    ReachabilityStatus status = GLobalRealReachability.currentReachabilityStatus;
    return status == RealStatusViaWWAN || status == RealStatusViaWiFi;
}

@end
