//
//  HHSocket.m
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

#import "HHSocket.h"

@implementation HHSocketConfig

- (instancetype)init {
    if (self = [super init]) {
        self.reconnectTime = 3;
    }
    return self;
}

- (void)setReconnectTime:(NSInteger)reconnectTime {
    _reconnectTime = reconnectTime > 0 ? reconnectTime : 3;
}

@end

@interface HHSocket ()<SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) HHSocketConfig *socketConfig;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@property (nonatomic, assign) NSInteger reconnectTime;
@property (nonatomic, strong) NSTimer *heartbeatTimer;

@property (nonatomic, assign) BOOL isClosedByUser;
@property (nonatomic, assign) BOOL isConnecting;

@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation HHSocket

- (void)showConnectStatus:(NSString *)text {
//    if (!Debug) { return; }
//
//    UIWindow *window = [UIApplication sharedApplication].delegate.window;
//    if (!self.statusLabel) {
//        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, 300, 16)];
//        self.statusLabel.textColor = [UIColor redColor];
//        self.statusLabel.font = [UIFont systemFontOfSize:12];
//        self.statusLabel.backgroundColor = [UIColor clearColor];
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.statusLabel.text = text;
//        [window addSubview:self.statusLabel];
//        [window bringSubviewToFront:self.statusLabel];
//    });
}

+ (void)initialize {
    [GLobalRealReachability startNotifier];
}

- (instancetype)initWithConfig:(HHSocketConfig *)config {
    if (self = [super init]) {
        
        self.socketConfig = config;
        self.reconnectTime = config.reconnectTime;
        
        const char *dispatchQueueLabel = [[NSString stringWithFormat:@"%p_socketDispatchQueue", self] cStringUsingEncoding:NSUTF8StringEncoding];
        self.dispatchQueue = dispatch_queue_create(dispatchQueueLabel, DISPATCH_QUEUE_SERIAL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedNetworkChangedNotification:) name:kRealReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedAppBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.statusLabel removeFromSuperview];
}

#pragma mark - Interface

- (void)close {
    
    self.reconnectTime = 0;
    self.isClosedByUser = YES;
    [self disconnect];
}

- (void)connect {
    
    SocketLog(@"开始连接...");
    if (self.isConnecting) { return; }
    
    [self disconnect];
    [self setupSocket];
    
    self.isConnecting = YES;
    self.isClosedByUser = NO;
    BOOL isFirstTimeConnect = (self.reconnectTime == self.socketConfig.reconnectTime);
    int64_t delayTime = isFirstTimeConnect ? 0 : (arc4random() % 4) + 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_global_queue(2, 0), ^{
        [self.socket open];
    });
}

- (void)reconnect {
    
    self.reconnectTime = self.socketConfig.reconnectTime;
    [self connect];
}

- (void)sendData:(id)data {
    if (!self.isConnected) { return; }
    
    [self.socket send:data];
}

#pragma mark - Action

/** 网络变化 */
- (void)didReceivedNetworkChangedNotification:(NSNotification *)notif {
    [self reconnectIfNeed];
}

/** 回到前台 */
- (void)didReceivedAppBecomeActiveNotification:(NSNotification *)notif {
    [self reconnectIfNeed];
}

- (void)sendHeartbeat {
    if (!self.isConnected) { return; }
    
    [self.socket sendPing:self.socketConfig.heartbeatMessage];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    
    SocketLog(@"连接成功...");
    [self showConnectStatus:@""];
    if ([self.delegate respondsToSelector:@selector(socketDidConnected:)]) {
        [self.delegate socketDidConnected:self];
    }
    
    self.isConnecting = NO;
    self.reconnectTime = self.socketConfig.reconnectTime;
    [self startHeartbeat];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    SocketLog(@"连接出错: %@", error);
    if ([self.delegate respondsToSelector:@selector(socket:didFailWithError:)]) {
        [self.delegate socket:self didFailWithError:error];
    }
    
    self.isConnecting = NO;
    if (!self.isConnected) {
        [self.heartbeatTimer invalidate];
        
        if (self.reconnectTime > 0) {
            
            self.reconnectTime -= 1;
            [self connect];
        } else if ([self.delegate respondsToSelector:@selector(socketCanNotConnectToService:)]) {
            [self.delegate socketCanNotConnectToService:self];
            SocketLog(@"多次重连失败 放弃连接");
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([self.delegate respondsToSelector:@selector(socket:didReceiveMessage:)]) {
        [self.delegate socket:self didReceiveMessage:message];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    SocketLog(@"连接已断开: (%zd)%@", code, reason);
    self.isConnecting = NO;
    [self.heartbeatTimer invalidate];
    [self showConnectStatus:@"socket未连接..."];
    if ([self.delegate respondsToSelector:@selector(socketCanNotConnectToService:)]) {
        [self.delegate socketCanNotConnectToService:self];
        SocketLog(@"多次重连失败 放弃连接");
    }
}

#pragma mark - Utils

- (void)setupSocket {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.socketConfig.url] cachePolicy:0 timeoutInterval:10];
    self.socket = [[SRWebSocket alloc] initWithURLRequest:request];
    self.socket.delegate = self;
    [self.socket setDelegateDispatchQueue:self.dispatchQueue];
}

- (void)disconnect {
    
    self.socket.delegate = nil;
    [self.socket close];
    [self.heartbeatTimer invalidate];
    [self showConnectStatus:@"socket未连接..."];
}

- (void)reconnectIfNeed {
    if (self.isConnected || !self.isNetworkReachable || self.isClosedByUser) { return; }
    
    [self reconnect];
}

- (void)startHeartbeat {
    
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = [NSTimer timerWithTimeInterval:15 target:self selector:@selector(sendHeartbeat) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.heartbeatTimer forMode:NSRunLoopCommonModes];
}

- (BOOL)isConnected {
    return self.socket.readyState == SR_OPEN;
}

- (BOOL)isNetworkReachable {
    
    ReachabilityStatus status = GLobalRealReachability.currentReachabilityStatus;
    return status == RealStatusViaWWAN || status == RealStatusViaWiFi;
}

@end
