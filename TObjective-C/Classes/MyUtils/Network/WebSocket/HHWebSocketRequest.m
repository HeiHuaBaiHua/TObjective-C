//
//  HHWebSocketRequest.m
//  HHvce
//
//  Created by HeiHuaBaiHua on 2017/9/28.
//  Copyright © 2017年 tiger. All rights reserved.
//

#import <YYModel/YYModel.h>

#import "HHWebSocketRequest.h"

@interface HHWebSocketRequest()

@property (nonatomic, strong) NSNumber *requestIdentifier;
@property (nonatomic, strong) id requestData;

@end

@implementation HHWebSocketRequest

+ (instancetype)requestWithURL:(HHWebSocketRequestURL)url parameters:(NSDictionary *)parameters header:(NSDictionary *)header {
    return [[HHWebSocketRequest alloc] initWithURL:url parameters:parameters header:header];
}

- (instancetype)initWithURL:(HHWebSocketRequestURL)url parameters:(NSDictionary *)parameters header:(NSDictionary *)header {
    if (self = [super init]) {
        
        self.requestIdentifier = @([HHWebSocketRequest currentRequestIdentifier]);
        
        parameters = parameters ?: @{};
        NSString *params = [parameters yy_modelToJSONString];
        NSDictionary *requestBody = @{@"url": @(url).stringValue,
                                      @"serNum": self.requestIdentifier.stringValue,
                                      @"params": params};
        self.requestData = [requestBody yy_modelToJSONString];
    }
    return self;
}

#pragma mark - Utils

+ (uint32_t)currentRequestIdentifier {
    
    static uint32_t currentRequestIdentifier;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        currentRequestIdentifier = WEBSOCKET_max_notification;
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    if (currentRequestIdentifier + 1 == 0xffffffff) {
        currentRequestIdentifier = WEBSOCKET_max_notification;
    }
    currentRequestIdentifier += 1;
    dispatch_semaphore_signal(lock);
    
    return currentRequestIdentifier;
}

#pragma mark - Getter

- (NSUInteger)timeoutInterval {
    return _timeoutInterval > 0 ? _timeoutInterval : 6;
}

@end
