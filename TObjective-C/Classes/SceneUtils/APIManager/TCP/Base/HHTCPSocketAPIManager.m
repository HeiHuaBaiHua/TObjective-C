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

@property (strong, nonatomic) NSMutableArray<NSNumber *> *loadingTaskIdentifies;

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
    
    //    [HHTCPSocketRequest requestWithURL:config.url message:config.message header:config.requestHeader];
    HHTCPSocketRequest *request = [HHTCPSocketRequest requestWithURL:config.url parameters:config.requestParameters header:config.requestHeader];
    NSNumber *taskIdentifier = [[HHTCPSocketClient sharedInstance] dispatchDataTaskWithRequest:request completionHandler:^(NSError *error, id result) {
        
        NSError *formatError = [self formatError:error];
        if (formatError == nil) {/** 通用错误格式化 */
            
            int code = [result[@"code"] intValue];
            if (code != HHNetworkTaskSuccess) {
                formatError = HHError(result[@"msg"] ?: HHDefaultErrorNotice, code);
            }
        }
        
        if (formatError == nil && config.deserializeClass != nil) {/** 通用json解析 */
            
            NSDictionary *json = result;
            if (config.deserializePath.length > 0) {
                json = [json valueForKeyPath:config.deserializePath];
            }
            if ([json isKindOfClass:[NSDictionary class]]) {
                
                if (json.count > 0) {
                    result = [config.deserializeClass yy_modelWithJSON:json];
                } else {
                    formatError = HHError(HHNoDataErrorNotice, HHNetworkTaskErrorNoData);
                }
            } else if ([json isKindOfClass:[NSArray class]]) {
                
                result = [NSArray yy_modelArrayWithClass:config.deserializeClass json:json];
                if ([result count] == 0) {
                    
                    NSInteger page = [config.requestParameters[@"page"] integerValue];
                    if (page == 0) {
                        formatError = HHError(HHNoDataErrorNotice, HHNetworkTaskErrorNoData);
                    } else {
                        formatError = HHError(HHNoMoreDataErrorNotice, HHNetworkTaskErrorNoMoreData);
                    }
                }
            }
        }
        
        !completionHandler ?: completionHandler(formatError, result);
    }];
    [self.loadingTaskIdentifies addObject:taskIdentifier];
    return taskIdentifier;
}

#pragma mark - Utils

- (NSError *)formatError:(NSError *)error {
    
    if (error != nil) {
        switch (error.code) {
            case NSURLErrorTimedOut: return HHError(HHTimeoutErrorNotice, HHNetworkTaskErrorTimeOut);
            case NSURLErrorCancelled: return HHError(HHDefaultErrorNotice, HHNetworkTaskErrorCanceled);
                
            case NSURLErrorCannotFindHost:
            case NSURLErrorCannotConnectToHost:
            case NSURLErrorNotConnectedToInternet: {
                return HHError(HHNetworkErrorNotice, HHNetworkTaskErrorCannotConnectedToInternet);
            }
                
            default: return HHError(HHDefaultErrorNotice, HHNetworkTaskErrorDefault);
        }
    }
    return error;
}

@end
