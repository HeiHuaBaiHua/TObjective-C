//
//  HHWebSocket.h
//  TSocket
//
//  Created by HeiHuaBaiHua on 2017/9/8.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHWebSocketService.h"

@class HHWebSocket;
@protocol HHWebSocketDelegate <NSObject>

@optional
- (void)socketDidConnected:(HHWebSocket *)socket;
- (void)socketCanNotConnectToService:(HHWebSocket *)socket;
- (void)socket:(HHWebSocket *)socket didReceiveMessage:(id)message;
- (void)socket:(HHWebSocket *)socket didFailWithError:(NSError *)error;

@end

@interface HHWebSocket : NSObject

@property (nonatomic, weak) id<HHWebSocketDelegate> delegate;
@property (nonatomic, assign) NSUInteger maxRetryTime;

- (instancetype)initWithService:(HHWebSocketService *)service;

- (void)close;
- (void)connect;
- (void)reconnect;
- (BOOL)isConnected;

- (void)writeData:(id)data;

@end
