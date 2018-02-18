//
//  HHWebSocketTask.h
//  HHvce
//
//  Created by HeiHuaBaiHua on 2017/9/28.
//  Copyright © 2017年 tiger. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHWebSocketResponse.h"
#import "HHNetworkTaskError.h"

typedef enum : NSUInteger {
    HHWebSocketTaskStateSuspended = 0,
    HHWebSocketTaskStateRunning = 1,
    HHWebSocketTaskStateCanceled = 2,
    HHWebSocketTaskStateCompleted = 3
} HHWebSocketTaskState;

@interface HHWebSocketTask : NSObject

- (void)cancel;
- (void)resume;

- (HHWebSocketTaskState)state;
- (NSNumber *)taskIdentifier;

@end
