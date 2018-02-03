//
//  HHTCPSocketHeartbeat.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/10.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHTCPSocketHeartbeat : NSObject

+ (instancetype)heartbeatWithClient:(id)client timeoutHandler:(void(^)(void))timeoutHandler;

- (void)stop;
- (void)reset;
- (void)handleServerAckNum:(uint32_t)ackNum;

@end
