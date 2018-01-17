//
//  HHAPIManager.m
//  HeiHuaBaiHua
//
//  Created by HeiHuaBaiHua on 16/6/3.
//  Copyright © 2016年 HeiHuaBaiHua. All rights reserved.
//

#import <YYModel/YYModel.h>
#import <CommonCrypto/CommonDigest.h>

#import "HHAPIManager.h"
#import "HHNetworkClient.h"

#pragma mark - HHRequestConfiguration

@implementation HHRequestConfiguration

- (instancetype)init {
    if (self = [super init]) {
        self.requestType = HHNetworkRequestTypeGET;
    }
    return self;
}

@end

@implementation HHTaskConfiguration
@end

@implementation HHDataTaskConfiguration
@end

@implementation HHUploadTaskConfiguration
@end

#pragma mark - HHAPIManager

@interface HHAPIManager ()

@property (strong, nonatomic) NSMutableArray<NSNumber *> *loadingTaskIdentifies;

@end

@implementation HHAPIManager
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
        [[HHNetworkClient sharedInstance] cancelTaskWithTaskIdentifier:taskIdentifier];
    }
    [self.loadingTaskIdentifies removeAllObjects];
}

- (void)cancelTask:(NSNumber *)taskIdentifier {
    
    [[HHNetworkClient sharedInstance] cancelTaskWithTaskIdentifier:taskIdentifier];
    [self.loadingTaskIdentifies removeObject:taskIdentifier];
}

- (NSURLSessionDataTask *)dataTaskWithConfiguration:(HHDataTaskConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    return [[HHNetworkClient sharedInstance] dataTaskWithUrlPath:config.urlPath requestType:config.requestType params:config.requestParameters header:config.requestHeader completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        completionHandler ? completionHandler([self formatError:error], responseObject) : nil;
    }];
}

- (NSNumber *)dispatchDataTaskWithConfiguration:(HHDataTaskConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler{
    
    NSNumber *taskIdentifier = [[HHNetworkClient sharedInstance] dispatchTaskWithUrlPath:config.urlPath requestType:config.requestType params:config.requestParameters header:config.requestHeader completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        id result = responseObject;
        NSError *formatError = [self formatError:error];
        if (formatError == nil) {/** 通用错误格式化 */
            
            int code = [result[@"code"] intValue];
            if (code != HHNetworkTaskSuccess) {
                formatError = HHError(result[@"msg"] ?: HHDefaultErrorNotice, code);
            }
        }
        
        if (formatError == nil && config.deserializeClass != nil) {/** 通用json解析 */
            
            NSDictionary *json = responseObject;
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
                    formatError = HHError(HHNoDataErrorNotice, page == 1 ? HHNetworkTaskErrorNoData : HHNetworkTaskErrorNoMoreData);
                }
            }
        }
        
        completionHandler ? completionHandler(formatError, result) : nil;
    }];
    [self.loadingTaskIdentifies addObject:taskIdentifier];
    return taskIdentifier;
}

- (NSNumber *)dispatchUploadTaskWithConfiguration:(HHUploadTaskConfiguration *)config progressHandler:(HHNetworkTaskProgressHandler)progressHandler completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    NSNumber *taskIdentifier = [[HHNetworkClient sharedInstance] uploadDataWithUrlPath:config.urlPath params:config.requestParameters contents:config.uploadContents header:config.requestHeader progressHandler:^(NSProgress *progress) {
        
        progressHandler ? progressHandler(progress.completedUnitCount * 1.0 / progress.totalUnitCount) : nil;
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        NSError *formatError = [self formatError:error];
        if (formatError == nil) {
            
            int code = [responseObject[@"code"] intValue];
            if (code != HHNetworkTaskSuccess) {
                formatError = HHError(responseObject[@"msg"] ?: HHDefaultErrorNotice, code);
            }
        }
        completionHandler ? completionHandler(formatError, responseObject) : nil;
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
