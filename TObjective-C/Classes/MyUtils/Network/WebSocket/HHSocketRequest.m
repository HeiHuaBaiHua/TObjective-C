//
//  HHSocketRequest.m
//  HHvce
//
//  Created by leihaiyin on 2017/9/28.
//  Copyright © 2017年 tiger. All rights reserved.
//

#import <YYModel/YYModel.h>

#import "HHSocketRequest.h"

@interface HHSocketRequest()

@property (strong, nonatomic) NSNumber *requestIdentifier;
@property (strong, nonatomic) id requestBody;

@end

@implementation HHSocketRequest

- (instancetype)initWithURL:(HHSocketRequestURL)url parameters:(NSDictionary *)parameters {
    if (self = [super init]) {
        
        self.timeoutInterval = 6;
        self.requestIdentifier = [HHSocketRequest currentRequestIdentifier];
        
        parameters = parameters ?: @{};
        NSString *params = [parameters yy_modelToJSONString];
        NSString *command = [self commandOfURL:url];
        NSDictionary *requestBody = @{@"id": self.requestIdentifier,
                                      @"command": command,
                                      @"params": params};
        self.requestBody = [requestBody yy_modelToJSONString];
    }
    return self;
}

#pragma mark - Utils

+ (NSNumber *)currentRequestIdentifier {
    
    static int currentRequestIdentifier;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        currentRequestIdentifier = 50;
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    currentRequestIdentifier += 1;
    dispatch_semaphore_signal(lock);
    
    return @(currentRequestIdentifier);
}

- (NSString *)commandOfURL:(HHSocketRequestURL)url {
    switch (url) {
        case HHSocketURLLogin: return @"login";
        case HHSocketURLSubscribe: return @"subscribe";
        case HHSocketURLUnsubscribe: return @"unsubscribe";
    }
    return @"";
}

@end
