//
//  HHSocketTask.m
//  HHvce
//
//  Created by leihaiyin on 2017/9/28.
//  Copyright © 2017年 tiger. All rights reserved.
//

#import "HHSocketTask.h"
#import "HHSocketClient.h"

@interface HHSocketClient ()

- (void)resumeTask:(HHSocketTask *)task;

@end

@interface HHSocketTask ()

@property (weak, nonatomic) id client;
@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) HHSocketTaskState state;
@property (strong, nonatomic) HHSocketRequest *request;
@property (copy, nonatomic) HHNetworkTaskCompletionHander completionHandler;

@end

@implementation HHSocketTask

#pragma mark - Interface(Public)

+ (instancetype)taskWithRequest:(HHSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    HHSocketTask *task = [HHSocketTask new];
    task.state = HHSocketTaskStateSuspended;
    task.request = request;
    if (completionHandler != nil) {
        task.completionHandler = ^(NSError *error, id result) {
            /** handler循环引用自身以保证常驻内存 请求着陆后handler置nil破环 释放自身和handler */
            completionHandler(error, result);
            task.state = task.state >= HHSocketTaskStateCanceled ? task.state : HHSocketTaskStateCompleted;
        };
    }
    return task;
}

- (void)cancel {
    
    if (self.state <= HHSocketTaskStateRunning) {
        
        [self completeWithResult:nil error:HHError(@"请求已取消",HHNetworkTaskErrorCanceled)];
        self.state = HHSocketTaskStateCanceled;
    }
}

- (void)resume {
    
    if (self.state == HHSocketTaskStateSuspended) {
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.request.timeoutInterval target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
        self.state = HHSocketTaskStateRunning;
        [self.client resumeTask:self];
    }
}

- (NSNumber *)taskIdentifier {
    return self.request.requestIdentifier;
}

#pragma mark - Interface(Friend)

- (void)completeWithResponseData:(NSDictionary *)responseData error:(NSError *)error {
    
    if (error != nil) {
        [self completeWithResult:nil error:error];
    } else if (self.state <= HHSocketTaskStateRunning) {
        
        NSDictionary *result;
        if ([responseData[@"ok"] boolValue]) {
            result = responseData;
        } else {
            
            NSString *msg = responseData[@"msg"] ?: @"unkonwn";
            error = HHError(msg, [responseData[@"code"] intValue]);
        }
        [self completeWithResult:result error:error];
    }
}

#pragma mark - Action

- (void)requestTimeout {
    
    if (self.state <= HHSocketTaskStateRunning) {
        
        self.state = HHSocketTaskStateCanceled;
        [self completeWithResult:nil error:HHError(HHTimeoutErrorNotice, HHNetworkTaskErrorTimeOut)];
    }
}

#pragma mark - Utils

- (void)completeWithResult:(id)result error:(NSError *)error {
    !error ?: NSLog(@"socket请求失败: %zd %@",error.code, error.domain);
    
    [self.timer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        !self.completionHandler ?: self.completionHandler(error, result);
        self.completionHandler = nil;
    });
}

@end
