//
//  HHTCPSocketAPIManager+RAC.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/1/27.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHTCPSocketAPIManager+RAC.h"

@implementation HHTCPSocketAPIManager (RAC)

- (RACSignal *)dataSignalWithConfig:(HHTCPDataTaskConfiguration *)config {
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
