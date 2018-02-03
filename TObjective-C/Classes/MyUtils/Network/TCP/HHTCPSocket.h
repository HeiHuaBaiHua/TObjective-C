//
//  HHTCPSocket.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/15.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHTCPSocketService.h"

@class HHTCPSocket;
@protocol HHTCPSocketDelegate <NSObject>

@optional
- (void)socket:(HHTCPSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port;

- (void)socketCanNotConnectToService:(HHTCPSocket *)sock;
- (void)socketDidDisconnect:(HHTCPSocket *)sock error:(NSError *)error;

- (void)socket:(HHTCPSocket *)sock didReadData:(NSData *)data;

@end

@interface HHTCPSocket : NSObject

@property (nonatomic, weak) id<HHTCPSocketDelegate> delegate;
@property (nonatomic, assign) NSUInteger maxRetryTime;

- (instancetype)initWithService:(HHTCPSocketService *)service;

- (void)close;
- (void)connect;
- (void)reconnect;
- (BOOL)isConnected;

- (void)writeData:(NSData *)data;

@end
