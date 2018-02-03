//
//  HHAPIManager+RAC.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHAPIManager+RAC.h"

@implementation HHAPIManager (RAC)

- (RACSignal *)dataSignalWithConfig:(HHDataTaskConfiguration *)config {
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

- (RACSignal *)uploadSignalWithConfig:(HHUploadTaskConfiguration *)config {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSNumber *taskIdentifier = [self dispatchUploadTaskWithConfiguration:config progressHandler:^(CGFloat progress) {
            [subscriber sendNext:RACTuplePack(@(progress), nil)];
        } completionHandler:^(NSError *error, id result) {
            
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:RACTuplePack(@1, result)];
                [subscriber sendCompleted];
            }
        }];
        return [RACDisposable disposableWithBlock:^{
            [self cancelTask:taskIdentifier];
        }];
    }].deliverOnMainThread;
}

@end
