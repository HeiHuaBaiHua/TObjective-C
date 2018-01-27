//
//  HHTCPSocket.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/15.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHTCPSocketConfig.h"

@class HHTCPSocket;
@protocol HHTCPSocketDelegate <NSObject>

- (void)socketCanNotConnectToService:(HHTCPSocket *)sock;
- (void)socket:(HHTCPSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port;
- (void)socketDidDisconnect:(HHTCPSocket *)sock error:(NSError *)error;

- (void)socket:(HHTCPSocket *)sock didReadData:(NSData *)data;

@end

@interface HHTCPSocket : NSObject

+ (instancetype)socketWithDelegate:(id<HHTCPSocketDelegate>)delegate;
+ (instancetype)socketWithDelegate:(id<HHTCPSocketDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (BOOL)isConnectd;

- (void)close;
- (void)connect;
- (void)disconnect;
- (void)connectWithRetryTime:(NSUInteger)retryTime;

- (void)writeData:(NSData *)data;

@end
