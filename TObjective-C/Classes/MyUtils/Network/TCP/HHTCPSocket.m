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

@property (strong, nonatomic) HHTCPSocketService *service;

@property (weak, nonatomic) id<HHTCPSocketDelegate> delegate;
@property (strong, nonatomic) dispatch_queue_t delegateQueue;
@property (strong, nonatomic) GCDAsyncSocket *socket;

@property (assign, nonatomic) BOOL keepRuning;
@property (strong, nonatomic) NSMachPort *machPort;
@property (strong, nonatomic) NSThread *socketThread;

@property (assign, nonatomic) BOOL isConnecting;
@property (assign, nonatomic) NSInteger reconnectTime;
@end

#define SocketTag 110
#define ReconnectTime 5
@implementation HHTCPSocket

+ (void)initialize {
    [GLobalRealReachability startNotifier];
}

+ (instancetype)socketWithDelegate:(id<HHTCPSocketDelegate>)delegate {
    return [self socketWithDelegate:delegate delegateQueue:nil];
}

+ (instancetype)socketWithDelegate:(id<HHTCPSocketDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    return [[HHTCPSocket alloc] initWithDelegate:delegate delegateQueue:delegateQueue];
}

- (instancetype)initWithDelegate:(id<HHTCPSocketDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    if (!delegate) { return nil; }
    
    if (self = [super init]) {

        const char *delegateQueueLabel = [[NSString stringWithFormat:@"%p_socketDelegateQueue", self] cStringUsingEncoding:NSUTF8StringEncoding];
        self.service = [HHTCPSocketService defaultService];
        self.delegate = delegate;
        self.reconnectTime = ReconnectTime;
        self.delegateQueue = delegateQueue ?: dispatch_queue_create(delegateQueueLabel, DISPATCH_QUEUE_SERIAL);
        
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:delegateQueue];
        self.machPort = [NSMachPort port];
        self.keepRuning = YES;
        self.socket.IPv4PreferredOverIPv6 = NO;
        [NSThread detachNewThreadSelector:@selector(configSocketThread) toTarget:self withObject:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedNetworkChangedNotification:) name:kRealReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedAppBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    SocketLog(@"TCPSocket连接成功...");
    
    if ([self.delegate respondsToSelector:@selector(socket:didConnectToHost:port:)]) {
        [self.delegate socket:self didConnectToHost:host port:port];
    }
    self.reconnectTime = ReconnectTime;
    [self.socket readDataWithTimeout:-1 tag:SocketTag];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
    SocketLog(@"TCPSocket连接已断开...%@", error);
    
    if ([self.delegate respondsToSelector:@selector(socketDidDisconnect:error:)]) {
        [self.delegate socketDidDisconnect:self error:error];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [self.socket readDataWithTimeout:-1 tag:SocketTag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    if ([self.delegate respondsToSelector:@selector(socket:didReadData:)]) {
        [self.delegate socket:self didReadData:data];
    }
    [self.socket readDataWithTimeout:-1 tag:SocketTag];
//    if (data.length < 100) {
//        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//    } else {
//        NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
//    }
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
    
    SocketLog(@"TCPSocket开始连接...");
    BOOL isConnectd = self.socket.isConnected;
    [self disconnect];
    
    int64_t delayTime = isConnectd ? (arc4random() % 3) + 0.5 : 0.5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_global_queue(2, 0), ^{
        [self performSelector:@selector(connectOnSocketThread) onThread:self.socketThread withObject:nil waitUntilDone:YES];
    });
}

- (void)reconnect {
    if (self.isConnecting || !self.isNetworkReachable) { return; }
    
    self.reconnectTime -= 1;
    if (self.reconnectTime >= 0) {
        [self connect];
    } else if ([self.delegate respondsToSelector:@selector(socketCanNotConnectToService:)]) {
        [self.delegate socketCanNotConnectToService:self];
    }
}

- (void)connectWithRetryTime:(NSUInteger)retryTime {
    
    self.reconnectTime = retryTime > 0 ? retryTime : ReconnectTime;
    [self connect];
}

- (void)disconnect {
    
    if (self.socket.isConnected) {
        
        [self.socket setDelegate:nil delegateQueue:nil];
        [self.socket disconnect];
    }
}

- (void)writeData:(NSData *)data {
    
    if (data.length == 0) { return; }
    [self.socket writeData:data withTimeout:-1 tag:SocketTag];
}

- (BOOL)isConnectd {
    return self.socket.isConnected;
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
    self.service = nil;
    self.machPort = nil;
    self.socketThread = nil;
    self.delegateQueue = nil;
}

- (void)connectOnSocketThread {
    
    [self.socket setDelegate:self delegateQueue:self.delegateQueue];
    BOOL isSuccess = [self.socket connectToHost:self.service.host onPort:self.service.port error:nil];
    self.isConnecting = NO;
    isSuccess ?: [self reconnect];
}

#pragma mark - Notification

- (void)didReceivedNetworkChangedNotification:(NSNotification *)notif {
    if (self.isConnectd) { return; }
    
    [self connectWithRetryTime:ReconnectTime];
}

- (void)didReceivedAppBecomeActiveNotification:(NSNotification *)notif {
    if (self.isConnectd) { return; }
    
    [self connectWithRetryTime:ReconnectTime];
}

#pragma mark - Utils

- (BOOL)isNetworkReachable {
    
    ReachabilityStatus status = GLobalRealReachability.currentReachabilityStatus;
    return status == RealStatusViaWWAN || status == RealStatusViaWiFi;
}

@end
