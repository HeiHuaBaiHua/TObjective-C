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
- (void)start;
- (void)reset;
- (void)respondToServerWithSerialNum:(int)serialNum;

@end
