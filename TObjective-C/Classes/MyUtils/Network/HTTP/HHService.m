//
//  HHService.m
//  HeiHuaBaiHua
//
//  Created by HeiHuaBaiHua on 16/6/2.
//  Copyright © 2016年 HeiHuaBaiHua. All rights reserved.
//

#import "HHService.h"

@protocol HHService <NSObject>

@optional
- (NSString *)testEnvironmentBaseUrl;
- (NSString *)developEnvironmentBaseUrl;
- (NSString *)releaseEnvironmentBaseUrl;

@end

@interface HHService ()<HHService>

@property (assign, nonatomic) HHServiceType type;
@property (assign, nonatomic) HHServiceEnvironment environment;

@end

@interface HHServiceX : HHService
@end

@interface HHServiceY : HHService
@end

@interface HHServiceZ : HHService
@end

@implementation HHService

#pragma mark - Interface

+ (HHService *)serviceWithType:(HHServiceType)type {
    
    HHService *service;
    switch (type) {
        case HHService0: service = [HHServiceX new];  break;
        case HHService1: service = [HHServiceY new];  break;
        case HHService2: service = [HHServiceZ new];  break;
    }
    service.type = type;
    service.environment = BulidServiceEnvironment;
    return service;
}

- (NSString *)baseUrl {
    
    switch (self.environment) {
        case HHServiceEnvironmentTest: return [self testEnvironmentBaseUrl];
        case HHServiceEnvironmentDevelop: return [self developEnvironmentBaseUrl];
        case HHServiceEnvironmentRelease: return [self releaseEnvironmentBaseUrl];
    }
}

@end

#pragma mark - HHServiceX

@implementation HHServiceX

- (NSString *)testEnvironmentBaseUrl {
    return @"http://127.0.0.1:8888";
}

- (NSString *)developEnvironmentBaseUrl {
    return @"https://api.weibo.com/2";
}

- (NSString *)releaseEnvironmentBaseUrl {
    return @"https://api.weibo.com/2";
}

@end

#pragma mark - HHServiceY

@implementation HHServiceY

- (NSString *)testEnvironmentBaseUrl {
    return @"testEnvironmentBaseUrl_Y";
}

- (NSString *)developEnvironmentBaseUrl {
    return @"developEnvironmentBaseUrl_Y";
}

- (NSString *)releaseEnvironmentBaseUrl {
    return @"releaseEnvironmentBaseUrl_Y";
}

@end

#pragma mark - HHServiceZ

@implementation HHServiceZ

- (NSString *)testEnvironmentBaseUrl {
    return @"testEnvironmentBaseUrl_Z";
}

- (NSString *)developEnvironmentBaseUrl {
    return @"developEnvironmentBaseUrl_Z";
}

- (NSString *)releaseEnvironmentBaseUrl {
    return @"releaseEnvironmentBaseUrl_Z";
}

@end
