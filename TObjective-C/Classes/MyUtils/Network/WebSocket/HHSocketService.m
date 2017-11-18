//
//  HHSocketService.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHSocketService.h"

@protocol HHSocketService <NSObject>

@optional
- (NSString *)testEnvironmentUrl;
- (NSString *)developEnvironmentUrl;
- (NSString *)releaseEnvironmentUrl;

@end

@interface HHSocketService ()<HHSocketService>

@property (assign, nonatomic) HHServiceType type;
@property (assign, nonatomic) HHServiceEnvironment environment;

@end

@interface HHSocketServiceX : HHSocketService
@end

@interface HHSocketServiceY : HHSocketService
@end

@interface HHSocketServiceZ : HHSocketService
@end

@implementation HHSocketService

#pragma mark - Interface

+ (HHSocketService *)serviceWithType:(HHServiceType)type {
    
    HHSocketService *service;
    switch (type) {
        case HHService0: service = [HHSocketServiceX new];  break;
        case HHService1: service = [HHSocketServiceY new];  break;
        case HHService2: service = [HHSocketServiceZ new];  break;
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

#pragma mark - HHSocketServiceX

@implementation HHSocketServiceX

- (NSString *)testEnvironmentUrl {
    return @"ws://127.0.0.1:8888/ws";
}

- (NSString *)developEnvironmentUrl {
    return @"ws://127.0.0.1:8888/ws";
}

- (NSString *)releaseEnvironmentUrl {
    return @"ws://127.0.0.1:8888/ws";
}

@end

#pragma mark - HHSocketServiceY

@implementation HHSocketServiceY

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

#pragma mark - HHSocketServiceZ

@implementation HHSocketServiceZ

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
