//
//  HHSocketTask.h
//  HHvce
//
//  Created by leihaiyin on 2017/9/28.
//  Copyright © 2017年 tiger. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHSocketRequest.h"
#import "HHNetworkTaskError.h"

typedef enum : NSUInteger {
    HHSocketTaskStateSuspended = 0,
    HHSocketTaskStateRunning = 1,
    HHSocketTaskStateCanceled = 2,
    HHSocketTaskStateCompleted = 3
} HHSocketTaskState;

typedef void(^HHNetworkTaskCompletionHander)(NSError *error,NSDictionary *result);

@interface HHSocketTask : NSObject

+ (instancetype)taskWithRequest:(HHSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler;

- (void)cancel;
- (void)resume;

- (HHSocketTaskState)state;
- (NSNumber *)taskIdentifier;

@end
