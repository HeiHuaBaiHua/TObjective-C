//
//  HHWebSocketManager.h
//  TSocket
//
//  Created by HeiHuaBaiHua on 2017/9/11.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHWebSocketTask.h"

@protocol HHWebSocketNotificationObserver <NSObject>

- (void)didConnectToSocketServer;
- (void)didReceiveSocketNotification:(NSDictionary *)notification;

@end

@interface HHWebSocketClient : NSObject

+ (instancetype)sharedInstance;

- (void)connect;

- (NSNumber *)dispatchDataTaskWithRequest:(HHWebSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler;
- (void)addObserver:(id<HHWebSocketNotificationObserver>)observer;

- (void)cancelAllTasks;
- (void)cancelTaskWithTaskIdentifier:(NSNumber *)taskIdentifier;
@end
