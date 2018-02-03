//
//  HHWebSocketService.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWebSocketService.h"

@protocol HHWebSocketService <NSObject>

@optional
- (NSString *)testEnvironmentUrl;
- (NSString *)developEnvironmentUrl;
- (NSString *)releaseEnvironmentUrl;

@end

@interface HHWebSocketService ()<HHWebSocketService>

@property (nonatomic, assign) HHServiceType type;
@property (nonatomic, assign) HHServiceEnvironment environment;

@end

@interface HHWebSocketServiceX : HHWebSocketService
@end

@interface HHWebSocketServiceY : HHWebSocketService
@end

@interface HHWebSocketServiceZ : HHWebSocketService
@end

@implementation HHWebSocketService

#pragma mark - Interface

+ (HHWebSocketService *)defaultService {
    return [self serviceWithType:0];
}

+ (HHWebSocketService *)serviceWithType:(HHServiceType)type {
    
    HHWebSocketService *service;
    switch (type) {
        case HHService0: service = [HHWebSocketServiceX new];  break;
        case HHService1: service = [HHWebSocketServiceY new];  break;
        case HHService2: service = [HHWebSocketServiceZ new];  break;
    }
    service.type = type;
    service.environment = BulidServiceEnvironment;
    return service;
}

- (NSString *)url {
    
    switch (self.environment) {
        case HHServiceEnvironmentTest: return [self testEnvironmentUrl];
        case HHServiceEnvironmentDevelop: return [self developEnvironmentUrl];
        case HHServiceEnvironmentRelease: return [self releaseEnvironmentUrl];
    }
}

@end

#pragma mark - HHWebSocketServiceX

@implementation HHWebSocketServiceX

- (NSString *)testEnvironmentUrl {
    return @"ws://localhost:34567/ws";
}

- (NSString *)developEnvironmentUrl {
    return @"ws://localhost:34567/ws";
}

- (NSString *)releaseEnvironmentUrl {
    return @"ws://localhost:34567/ws";
}

@end

#pragma mark - HHWebSocketServiceY

@implementation HHWebSocketServiceY

- (NSString *)testEnvironmentUrl {
    return @"testEnvironmentUrl_Y";
}

- (NSString *)developEnvironmentUrl {
    return @"developEnvironmentUrl_Y";
}

- (NSString *)releaseEnvironmentUrl {
    return @"releaseEnvironmentUrl_Y";
}

@end

#pragma mark - HHWebSocketServiceZ

@implementation HHWebSocketServiceZ

- (NSString *)testEnvironmentUrl {
    return @"testEnvironmentUrl_Z";
}

- (NSString *)developEnvironmentUrl {
    return @"developEnvironmentUrl_Z";
}

- (NSString *)releaseEnvironmentUrl {
    return @"releaseEnvironmentUrl_Z";
}

@end
