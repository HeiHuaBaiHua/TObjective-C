//
//  HHTCPSocketService.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/15.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import "HHTCPSocketService.h"

@interface HHTCPSocketService ()

@property (nonatomic, assign) HHServiceType type;
@property (nonatomic, assign) HHServiceEnvironment environment;

@end

@interface HHTCPSocketServiceX : HHTCPSocketService
@end

@interface HHTCPSocketServiceY : HHTCPSocketService
@end

@interface HHTCPSocketServiceZ : HHTCPSocketService
@end

@implementation HHTCPSocketService

#pragma mark - Interface

+ (instancetype)defaultService {
    return [HHTCPSocketService serviceWithType:HHService0];
}

+ (HHTCPSocketService *)serviceWithType:(HHServiceType)type {
    
    HHTCPSocketService *service;
    type %= ServiceCount;
    switch (type) {
        case HHService0: service = [HHTCPSocketServiceX new];  break;
        case HHService1: service = [HHTCPSocketServiceY new];  break;
        case HHService2: service = [HHTCPSocketServiceZ new];  break;
    }
    service.type = type;
    service.environment = HHServiceEnvironmentTest;
    return service;
}

- (NSString *)host {
    
    switch (self.environment) {
        case HHServiceEnvironmentTest: return [self testEnvironmentHost];
        case HHServiceEnvironmentDevelop: return [self developEnvironmentHost];
        case HHServiceEnvironmentRelease: return [self releaseEnvironmentHost];
    }
}

- (int16_t)port {
    
    switch (self.environment) {
        case HHServiceEnvironmentTest: return [self testEnvironmentPort];
        case HHServiceEnvironmentDevelop: return [self developEnvironmentPort];
        case HHServiceEnvironmentRelease: return [self releaseEnvironmentPort];
    }
}

@end


#pragma mark - HHServiceX

@implementation HHTCPSocketServiceX

- (int16_t)testEnvironmentPort {
    return 23456;
}

- (int16_t)developEnvironmentPort {
    return 23456;
}

- (int16_t)releaseEnvironmentPort {
    return 23456;
}

- (NSString *)testEnvironmentHost {
    return @"localhost";
}

- (NSString *)developEnvironmentHost {
    return @"localhost";
}

- (NSString *)releaseEnvironmentHost {
    return @"localhost";
}

@end

#pragma mark - HHServiceY

@implementation HHTCPSocketServiceY

- (int16_t)testEnvironmentPort {
    return 7001;
}

- (int16_t)developEnvironmentPort {
    return 7001;
}

- (int16_t)releaseEnvironmentPort {
    return 7001;
}

- (NSString *)testEnvironmentHost {
    return @"testEnvironmentHost_Y";
}

- (NSString *)developEnvironmentHost {
    return @"developEnvironmentHost_Y";
}

- (NSString *)releaseEnvironmentHost {
    return @"developEnvironmentHost_Y";
}

@end

#pragma mark - HHServiceZ

@implementation HHTCPSocketServiceZ

- (int16_t)testEnvironmentPort {
    return 7001;
}

- (int16_t)developEnvironmentPort {
    return 7001;
}

- (int16_t)releaseEnvironmentPort {
    return 7001;
}

- (NSString *)testEnvironmentHost {
    return @"developEnvironmentHost_Z";
}

- (NSString *)developEnvironmentHost {
    return @"developEnvironmentHost_Z";
}

- (NSString *)releaseEnvironmentHost {
    return @"developEnvironmentHost_Z";
}

@end
