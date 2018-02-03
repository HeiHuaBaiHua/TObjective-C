//
//  HHWebSocketAPIManger.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/3.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <YYModel/YYModel.h>

#import "HHWebSocketClient.h"
#import "HHWebSocketAPIManager.h"

@implementation HHWebRequestConfiguration
@end

@implementation HHWebTaskConfiguration
@end

@implementation HHWebDataTaskConfiguration
@end

#pragma mark - HHAPIManager

@interface HHWebSocketAPIManager ()

@property (nonatomic, strong) NSMutableArray<NSNumber *> *loadingTaskIdentifies;

@end

@implementation HHWebSocketAPIManager
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
        [[HHWebSocketClient sharedInstance] cancelTaskWithTaskIdentifier:taskIdentifier];
    }
    [self.loadingTaskIdentifies removeAllObjects];
}

- (void)cancelTask:(NSNumber *)taskIdentifier {
    
    [[HHWebSocketClient sharedInstance] cancelTaskWithTaskIdentifier:taskIdentifier];
    [self.loadingTaskIdentifies removeObject:taskIdentifier];
}

- (NSNumber *)dispatchDataTaskWithConfiguration:(HHWebDataTaskConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler{
    
    HHWebSocketRequest *request = [HHWebSocketRequest requestWithURL:config.url parameters:config.requestParameters header:config.requestHeader];
    NSNumber *taskIdentifier = [[HHWebSocketClient sharedInstance] dispatchDataTaskWithRequest:request completionHandler:^(NSError *error, id result) {
        
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
