//
//  HHSocket.h
//  TSocket
//
//  Created by HeiHuaBaiHua on 2017/9/8.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHSocketConfig : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger reconnectTime;
@property (nonatomic, strong) id heartbeatMessage;

@end

@class HHSocket;
@protocol HHSocketDelegate <NSObject>

@optional
- (void)socketDidConnected:(HHSocket *)socket;
- (void)socketCanNotConnectToService:(HHSocket *)socket;
- (void)socket:(HHSocket *)socket didReceiveMessage:(id)message;
- (void)socket:(HHSocket *)socket didFailWithError:(NSError *)error;

@end

@interface HHSocket : NSObject

@property (nonatomic, weak) id<HHSocketDelegate> delegate;

- (instancetype)initWithConfig:(HHSocketConfig *)config;

- (void)close;
- (void)connect;
- (void)reconnect;
- (BOOL)isConnected;

- (void)sendData:(id)data;

@end
