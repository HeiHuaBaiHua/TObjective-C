//
//  HHTCPSocketHeartbeat.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/10.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import "HHTCPSocketHeartbeat.h"

#import "HHTCPSocketTask.h"
#import "HHTCPSocketClient.h"

@interface HHTCPSocketClient ()

- (void)resumeTask:(HHTCPSocketTask *)task;

@end

@interface HHTCPSocketHeartbeat ()

@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) id client;
@property (copy, nonatomic) void(^timeoutHandler)(void);

@end

@implementation HHTCPSocketHeartbeat

+ (instancetype)heartbeatWithClient:(id)client timeoutHandler:(void (^)(void))timeoutHandler {
    
    HHTCPSocketHeartbeat *heartbeat = [HHTCPSocketHeartbeat new];
    heartbeat.client = client;
    heartbeat.timeoutHandler = timeoutHandler;
    return heartbeat;
}

- (void)start {
    
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:25 target:self selector:@selector(timeout) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)reset {
    [self start];
}

- (void)stop {
    [self.timer invalidate];
}

- (void)timeout {
    self.timeoutHandler ? self.timeoutHandler() : nil;
}

- (void)respondToServerWithSerialNum:(int)serialNum {
    
    HHTCPSocketRequest *request = [HHTCPSocketRequest heartbeatRequestWithAckNum:serialNum];
    [self.client resumeTask:[HHTCPSocketTask taskWithRequest:request completionHandler:nil]];
}

@end
