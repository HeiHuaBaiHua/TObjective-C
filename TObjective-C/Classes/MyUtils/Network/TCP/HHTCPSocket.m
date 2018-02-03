//
//  HHTCPSocket.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/15.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import <RealReachability/RealReachability.h>

#import "HHTCPSocket.h"
#import "GCDAsyncSocket.h"
#import "HHTCPSocketService.h"

#if 1
# define SocketLog(...) NSLog(__VA_ARGS__)
#else
# define SocketLog(...) {}
#endif

@interface HHTCPSocket()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) HHTCPSocketService *service;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

@property (nonatomic, assign) BOOL keepRuning;
@property (nonatomic, strong) NSPort *machPort;
@property (nonatomic, strong) NSThread *socketThread;

@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, assign) NSInteger reconnectTime;
@end

static NSUInteger socketTag = 110;
@implementation HHTCPSocket

- (instancetype)init {
    return [self initWithService:nil];
}

- (instancetype)initWithService:(HHTCPSocketService *)service {
    if (self = [super init]) {
        self.service = service ?: [HHTCPSocketService defaultService];
        
        const char *delegateQueueLabel = [[NSString stringWithFormat:@"%p_socketDelegateQueue", self] cStringUsingEncoding:NSUTF8StringEncoding];
        self.reconnectTime = self.maxRetryTime;
        self.delegateQueue = dispatch_queue_create(delegateQueueLabel, DISPATCH_QUEUE_SERIAL);
        
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
        self.machPort = [NSMachPort port];
        self.keepRuning = YES;
        self.socket.IPv4PreferredOverIPv6 = NO;
        [NSThread detachNewThreadSelector:@selector(configSocketThread) toTarget:self withObject:nil];
        
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
    
    self.keepRuning = NO;
    self.isConnecting = NO;
    [self disconnect];
    [self performSelector:@selector(configSocketThread) onThread:self.socketThread withObject:nil waitUntilDone:YES];
}

- (void)connect {
    if (self.isConnecting || !self.isNetworkReachable) { return; }
    self.isConnecting = YES;
    
    [self disconnect];
    
    SocketLog(@"TCPSocket开始连接...");
    BOOL isFirstTimeConnect = (self.reconnectTime == self.maxRetryTime);
    int64_t delayTime = isFirstTimeConnect ? 0 : (arc4random() % 3) + 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_global_queue(2, 0), ^{
        [self performSelector:@selector(connectOnSocketThread) onThread:self.socketThread withObject:nil waitUntilDone:YES];
    });
}

- (void)reconnect {
    
    self.reconnectTime = self.maxRetryTime;
    [self connect];
}

- (void)disconnect {
    if (!self.socket.isConnected) { return; }
    
    [self.socket setDelegate:nil delegateQueue:nil];
    [self.socket disconnect];
}

- (void)writeData:(NSData *)data {
    if (data.length == 0) { return; }
    
    [self.socket writeData:data withTimeout:-1 tag:socketTag];
}

- (BOOL)isConnected {
    return self.socket.isConnected;
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    SocketLog(@"TCPSocket连接成功...");
    
    if ([self.delegate respondsToSelector:@selector(socket:didConnectToHost:port:)]) {
        [self.delegate socket:self didConnectToHost:host port:port];
    }
    
    self.reconnectTime = self.maxRetryTime;
    [self.socket readDataWithTimeout:-1 tag:socketTag];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
    SocketLog(@"TCPSocket连接已断开...%@", error);
    
    if ([self.delegate respondsToSelector:@selector(socketDidDisconnect:error:)]) {
        [self.delegate socketDidDisconnect:self error:error];
    }
    [self tryToReconnect];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [self.socket readDataWithTimeout:-1 tag:socketTag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    if ([self.delegate respondsToSelector:@selector(socket:didReadData:)]) {
        [self.delegate socket:self didReadData:data];
    }
    [self.socket readDataWithTimeout:-1 tag:socketTag];
}

#pragma mark - Action

- (void)configSocketThread {
    
    if (self.socketThread == nil) {
        self.socketThread = [NSThread currentThread];
        [[NSRunLoop currentRunLoop] addPort:self.machPort forMode:NSDefaultRunLoopMode];
    }
    while (self.keepRuning) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    [[NSRunLoop currentRunLoop] removePort:self.machPort forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];
    [self.socketThread cancel];
    self.socket = nil;
    self.machPort = nil;
    self.socketThread = nil;
    self.delegateQueue = nil;
}

- (void)connectOnSocketThread {
    
    [self.socket setDelegate:self delegateQueue:self.delegateQueue];
    [self.socket connectToHost:self.service.host onPort:self.service.port error:nil];
    self.isConnecting = NO;
}

#pragma mark - Notification

- (void)didReceivedNetworkChangedNotification:(NSNotification *)notif {
    [self reconnectIfNeed];
}

- (void)didReceivedAppBecomeActiveNotification:(NSNotification *)notif {
    [self reconnectIfNeed];
}

#pragma mark - Utils

- (void)tryToReconnect {
    if (self.isConnecting || !self.isNetworkReachable) { return; }
    
    self.reconnectTime -= 1;
    if (self.reconnectTime >= 0) {
        [self connect];
    } else if ([self.delegate respondsToSelector:@selector(socketCanNotConnectToService:)]) {
        [self.delegate socketCanNotConnectToService:self];
    }
}

- (void)reconnectIfNeed {
    if (self.isConnecting || self.isConnected) { return; }
    
    [self reconnect];
}

- (NSUInteger)maxRetryTime {
    return _maxRetryTime > 0 ? _maxRetryTime : 5;
}

- (BOOL)isNetworkReachable {
    
    ReachabilityStatus status = GLobalRealReachability.currentReachabilityStatus;
    return status == RealStatusViaWWAN || status == RealStatusViaWiFi;
}

@end
