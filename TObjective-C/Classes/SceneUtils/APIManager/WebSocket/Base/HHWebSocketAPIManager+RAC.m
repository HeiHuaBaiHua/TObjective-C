//
//  HHWebSocketAPIManager+RAC.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/3.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWebSocketAPIManager+RAC.h"

@implementation HHWebSocketAPIManager (RAC)

- (RACSignal *)dataSignalWithConfig:(HHWebDataTaskConfiguration *)config {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSNumber *taskIdentifier = [self dispatchDataTaskWithConfiguration:config completionHandler:^(NSError *error, id result) {
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }
        }];
        return [RACDisposable disposableWithBlock:^{
            [self cancelTask:taskIdentifier];
        }];
    }].deliverOnMainThread;
}

@end
