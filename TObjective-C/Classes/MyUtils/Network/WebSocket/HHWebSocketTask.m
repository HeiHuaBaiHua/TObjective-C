//
//  HHWebSocketTask.m
//  HHvce
//
//  Created by HeiHuaBaiHua on 2017/9/28.
//  Copyright © 2017年 tiger. All rights reserved.
//

#import "HHWebSocketTask.h"
#import "HHWebSocketClient.h"

@interface HHWebSocketClient ()

- (void)resumeTask:(HHWebSocketTask *)task;

@end

@interface HHWebSocketTask ()

@property (weak, nonatomic) id client;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) HHWebSocketTaskState state;
@property (nonatomic, strong) HHWebSocketRequest *request;
@property (nonatomic, copy) HHNetworkTaskCompletionHander completionHandler;

@property (nonatomic, strong) HHWebSocketTask *keeper;
@end

@implementation HHWebSocketTask

#pragma mark - Interface(Public)

+ (instancetype)taskWithRequest:(HHWebSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    HHWebSocketTask *task = [HHWebSocketTask new];
    task.state = HHWebSocketTaskStateSuspended;
    task.request = request;
    task.completionHandler = completionHandler;
    task.keeper = task;
    return task;
}

- (void)cancel {
    if (![self canResponse]) { return; }
    
    [self completeWithResult:nil error:HHError(@"请求已取消",HHNetworkTaskErrorCanceled)];
    self.state = HHWebSocketTaskStateCanceled;
}

- (void)resume {
    if (self.state != HHWebSocketTaskStateSuspended) { return; }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.request.timeoutInterval target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    self.state = HHWebSocketTaskStateRunning;
    [self.client resumeTask:self];
}

- (NSNumber *)taskIdentifier {
    return self.request.requestIdentifier;
}

#pragma mark - Interface(Friend)

- (void)completeWithResponse:(HHWebSocketResponse *)response error:(NSError *)error {
    if (![self canResponse]) { return; }
    
    [self completeWithResult:response.content error:error];
}

#pragma mark - Action

- (void)requestTimeout {
    if (![self canResponse]) { return; }
    
    self.state = HHWebSocketTaskStateCanceled;
    [self completeWithResult:nil error:HHError(HHTimeoutErrorNotice, HHNetworkTaskErrorTimeOut)];
}

#pragma mark - Utils

- (BOOL)canResponse {
    return self.state <= HHWebSocketTaskStateRunning;
}

- (void)completeWithResult:(id)result error:(NSError *)error {
    
    self.state = (self.state >= HHWebSocketTaskStateCanceled ? self.state : HHWebSocketTaskStateCompleted);
    [self.timer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        !self.completionHandler ?: self.completionHandler(error, result);
        self.completionHandler = nil;
        self.keeper = nil;
    });
}

@end
