//
//  HHTCPSocketAPIManager.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/1/27.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <YYModel/YYModel.h>

#import "HHTCPSocketClient.h"
#import "HHTCPSocketAPIManager.h"

@implementation HHTCPRequestConfiguration
@end

@implementation HHTCPTaskConfiguration
@end

@implementation HHTCPDataTaskConfiguration
@end

#pragma mark - HHAPIManager

@interface HHTCPSocketAPIManager ()

@property (nonatomic, strong) NSMutableArray<NSNumber *> *loadingTaskIdentifies;

@end

@implementation HHTCPSocketAPIManager
- (instancetype)init {
    if (self = [super init]) {
        self.loadingTaskIdentifies = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [self cancelAllTask];
}

#pragma mark - Interface

- (void)cancelAllTask {
    
    for (NSNumber *taskIdentifier in self.loadingTaskIdentifies) {
        [[HHTCPSocketClient sharedInstance] cancelTaskWithTaskIdentifier:taskIdentifier];
    }
    [self.loadingTaskIdentifies removeAllObjects];
}

- (void)cancelTask:(NSNumber *)taskIdentifier {
    
    [[HHTCPSocketClient sharedInstance] cancelTaskWithTaskIdentifier:taskIdentifier];
    [self.loadingTaskIdentifies removeObject:taskIdentifier];
}

- (NSNumber *)dispatchDataTaskWithConfiguration:(HHTCPDataTaskConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler{
    
    HHTCPSocketRequest *request = [HHTCPSocketRequest requestWithURL:config.url parameters:config.requestParameters header:config.requestHeader];
    NSNumber *taskIdentifier = [[HHTCPSocketClient sharedInstance] dispatchDataTaskWithRequest:request completionHandler:^(NSError *error, id result) {
        
        if (error == nil) {
            
            int code = [result[@"code"] intValue];
            if (code != HHNetworkTaskSuccess) {
                error = HHError(result[@"msg"] ?: HHDefaultErrorNotice, code);
            }
        }
        
        if (error == nil && config.deserializeClass != nil) {/** 通用json解析 */
            
            NSDictionary *json = result;
            if (config.deserializePath.length > 0) {
                json = [json valueForKeyPath:config.deserializePath];
            }
            if ([json isKindOfClass:[NSDictionary class]]) {
                
                if (json.count > 0) {
                    result = [config.deserializeClass yy_modelWithJSON:json];
                } else {
                    error = HHError(HHNoDataErrorNotice, HHNetworkTaskErrorNoData);
                }
            } else if ([json isKindOfClass:[NSArray class]]) {
                
                result = [NSArray yy_modelArrayWithClass:config.deserializeClass json:json];
                if ([result count] == 0) {
                    
                    NSInteger page = [config.requestParameters[@"page"] integerValue];
                    if (page == 0) {
                        error = HHError(HHNoDataErrorNotice, HHNetworkTaskErrorNoData);
                    } else {
                        error = HHError(HHNoMoreDataErrorNotice, HHNetworkTaskErrorNoMoreData);
                    }
                }
            }
        }
        
        !completionHandler ?: completionHandler(error, result);
    }];
    [self.loadingTaskIdentifies addObject:taskIdentifier];
    return taskIdentifier;
}

@end
