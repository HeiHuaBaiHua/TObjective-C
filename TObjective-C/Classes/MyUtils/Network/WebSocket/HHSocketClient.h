//
//  HHSocketManager.h
//  TSocket
//
//  Created by leihaiyin on 2017/9/11.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHSocketTask.h"

@protocol HHSocketNotificationObserver <NSObject>

- (void)didConnectToSocketServer;
- (void)didReceiveSocketNotification:(NSDictionary *)notification;

@end

@interface HHSocketClient : NSObject

+ (instancetype)sharedClient;

- (void)connect;
- (NSNumber *)dispatchDataTaskWithRequest:(HHSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler;
- (void)addObserver:(id<HHSocketNotificationObserver>)observer;
@end
