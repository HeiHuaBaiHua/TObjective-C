//
//  HHTCPSocketTask.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHNetworkConfig.h"
#import "HHNetworkTaskError.h"

#import "HHTCPSocketResponse.h"

typedef enum : NSUInteger {
    HHTCPSocketTaskStateSuspended = 0,
    HHTCPSocketTaskStateRunning = 1,
    HHTCPSocketTaskStateCanceled = 2,
    HHTCPSocketTaskStateCompleted = 3
} HHTCPSocketTaskState;

@interface HHTCPSocketTask : NSObject

- (void)cancel;
- (void)resume;

- (HHTCPSocketTaskState)state;
- (NSNumber *)taskIdentifier;

@end
