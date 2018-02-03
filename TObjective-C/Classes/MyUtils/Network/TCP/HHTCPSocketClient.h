//
//  HHTCPSocketClient.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/16.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHTCPSocketRequest.h"
#import "HHNetworkTaskError.h"
@interface HHTCPSocketClient : NSObject

+ (instancetype)sharedInstance;

- (void)connect;

- (NSNumber *)dispatchDataTaskWithRequest:(HHTCPSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler;

- (void)cancelAllTasks;
- (void)cancelTaskWithTaskIdentifier:(NSNumber *)taskIdentifier;

@end
