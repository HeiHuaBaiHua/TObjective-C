//
//  HHWebSocket.m
//  TSocket
//
//  Created by HeiHuaBaiHua on 2017/9/8.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#define Debug 1

#if Debug
# define SocketLog(...) NSLog(__VA_ARGS__)
#else
# define SocketLog(...) {}
#endif

#import <SocketRocket/SRWebSocket.h>
#import <RealReachability/RealReachability.h>

#import "HHWebSocket.h"

@interface HHWebSocket ()<SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) HHWebSocketService *service;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, assign) NSInteger reconnectTime;

@property (nonatomic, strong) NSTimer *heartbeatTimer;
@end

@implementation HHWebSocket

- (instancetype)init {
    return [self initWithService:nil];
}

- (instancetype)initWithService:(HHWebSocketService *)service {
    if (self = [super init]) {
        self.service = service ?: [HHWebSocketService defaultService];;
        
        const char *dispatchQueueLabel = [[NSString stringWithFormat:@"%p_socketDispatchQueue", self] cStringUsingEncoding:NSUTF8StringEncoding];
        self.dispatchQueue = dispatch_queue_create(dispatchQueueLabel, DISPATCH_QUEUE_SERIAL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedNetworkChangedNotification:) name:kRealReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedAppBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Interface

- (void)close {
    
    self.isConnecting = NO;
    [self disconnect];
}

- (void)connect {
    if (self.isConnecting || !self.isNetworkReachable) { return; }
    self.isConnecting = YES;
    
    [self disconnect];
    [self setupSocket];
    
    SocketLog(@"WebSocket开始连接...");
    BOOL isFirstTimeConnect = (self.reconnectTime == self.maxRetryTime);
    int64_t delayTime = isFirstTimeConnect ? 0 : (arc4random() % 3) + 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_global_queue(2, 0), ^{
        [self.socket open];
    });
}

- (void)disconnect {
    
    self.socket.delegate = nil;
    [self.socket close];
    [self.heartbeatTimer invalidate];
}

- (void)reconnect {
    
    self.reconnectTime = self.maxRetryTime;
    [self connect];
}

- (void)writeData:(id)data {
    if (!self.isConnected) { return; }
    
    [self.socket send:data];
}

- (BOOL)isConnected {
    return self.socket.readyState == SR_OPEN;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    self.isConnecting = NO;
    
    SocketLog(@"WebSocket连接成功...");
    if ([self.delegate respondsToSelector:@selector(socketDidConnected:)]) {
        [self.delegate socketDidConnected:self];
    }
    
    self.reconnectTime = self.maxRetryTime;
    [self startHeartbeat];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    self.isConnecting = NO;
    
    SocketLog(@"WebSocket错误: %@", error);
    if ([self.delegate respondsToSelector:@selector(socket:didFailWithError:)]) {
        [self.delegate socket:self didFailWithError:error];
    }
    
    if (!self.isConnected) {
        [self tryToReconnect];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([self.delegate respondsToSelector:@selector(socket:didReceiveMessage:)]) {
        [self.delegate socket:self didReceiveMessage:message];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    SocketLog(@"WebSocket已断开: (%zd)%@", code, reason);
    self.isConnecting = NO;
    [self tryToReconnect];
}

#pragma mark - Action

- (void)sendHeartbeat {
    if (!self.isConnected) { return; }
    
    [self.socket sendPing:[@"heatbeat" dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - Notification

- (void)didReceivedNetworkChangedNotification:(NSNotification *)notif {
    [self reconnectIfNeed];
}

- (void)didReceivedAppBecomeActiveNotification:(NSNotification *)notif {
    [self reconnectIfNeed];
}

#pragma mark - Utils

- (void)setupSocket {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.service.url] cachePolicy:0 timeoutInterval:10];
    self.socket = [[SRWebSocket alloc] initWithURLRequest:request];
    self.socket.delegate = self;
    [self.socket setDelegateDispatchQueue:self.dispatchQueue];
}

- (void)tryToReconnect {
    if (self.isConnecting || !self.isNetworkReachable) { return; }
    
    [self.heartbeatTimer invalidate];
    self.reconnectTime -= 1;
    if (self.reconnectTime >= 0) {
        [self connect];
    } else if ([self.delegate respondsToSelector:@selector(socketCanNotConnectToService:)]) {
        [self.delegate socketCanNotConnectToService:self];
    }
}

- (void)reconnectIfNeed {
    if (self.isConnected || !self.isNetworkReachable) { return; }
    
    [self reconnect];
}

- (void)startHeartbeat {
    
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(sendHeartbeat) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.heartbeatTimer forMode:NSRunLoopCommonModes];
}

- (NSUInteger)maxRetryTime {
    return _maxRetryTime > 0 ? _maxRetryTime : 5;
}

- (BOOL)isNetworkReachable {
    
    ReachabilityStatus status = GLobalRealReachability.currentReachabilityStatus;
    return status == RealStatusViaWWAN || status == RealStatusViaWiFi;
}

@end
