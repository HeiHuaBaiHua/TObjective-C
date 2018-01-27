//
//  HHTCPSocketService.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/15.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHNetworkConfig.h"
@protocol HHTCPSocketService <NSObject>

@optional
- (int16_t)testEnvironmentPort;
- (NSString *)testEnvironmentHost;

- (int16_t)developEnvironmentPort;
- (NSString *)developEnvironmentHost;

- (int16_t)releaseEnvironmentPort;
- (NSString *)releaseEnvironmentHost;

@end

@interface HHTCPSocketService : NSObject<HHTCPSocketService>

+ (instancetype)defaultService;

- (int16_t)port;
- (NSString *)host;

- (HHServiceType)type;

@end
