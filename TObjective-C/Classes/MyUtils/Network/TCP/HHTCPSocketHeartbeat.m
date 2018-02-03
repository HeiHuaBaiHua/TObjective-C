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

@interface HHTCPSocketHeartbeat ()

@property (nonatomic, weak) HHTCPSocketClient *client;

@property (nonatomic, copy) void(^timeoutHandler)(void);
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSUInteger missTime;
@end

static NSUInteger maxMissTime = 3;
@implementation HHTCPSocketHeartbeat

+ (instancetype)heartbeatWithClient:(id)client timeoutHandler:(void (^)(void))timeoutHandler {
    
    HHTCPSocketHeartbeat *heartbeat = [HHTCPSocketHeartbeat new];
    heartbeat.client = client;
    heartbeat.missTime = -1;
    heartbeat.timeoutHandler = timeoutHandler;
    return heartbeat;
}

- (void)start {
    
    [self stop];
    self.timer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(sendHeatbeat) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stop {
    [self.timer invalidate];
}

- (void)reset {
    self.missTime = -1;
    [self start];
}

- (void)sendHeatbeat {
    
    self.missTime += 1;
    if (self.missTime >= maxMissTime && self.timeoutHandler != nil) {
        self.timeoutHandler();
        self.missTime = -1;
    }
    
    HHTCPSocketRequest *request = [HHTCPSocketRequest requestWithURL:TCP_heatbeat parameters:@{@"ackNum": @(TCP_heatbeat)} header:nil];
    [self.client dispatchDataTaskWithRequest:request completionHandler:nil];
}

- (void)handleServerAckNum:(uint32_t)ackNum {
    NSLog(@"received ackNum: %u", ackNum);
    if (ackNum == TCP_heatbeat) {
        self.missTime = -1;
        return;
    }
    
    HHTCPSocketRequest *request = [HHTCPSocketRequest requestWithURL:TCP_heatbeat parameters:@{@"ackNum": @(ackNum)} header:nil];
    [self.client dispatchDataTaskWithRequest:request completionHandler:nil];
}

@end
