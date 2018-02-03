//
//  HHAPIManager.h
//  HeiHuaBaiHua
//
//  Created by HeiHuaBaiHua on 16/6/3.
//  Copyright © 2016年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "HHUploadFile.h"
#import "HHNetworkConfig.h"
#import "HHNetworkTaskError.h"

#pragma mark - HHAPIConfiguration

typedef void(^HHNetworkTaskProgressHandler)(CGFloat progress);

@interface HHRequestConfiguration : NSObject

@property (nonatomic, copy) NSString *urlPath;
@property (nonatomic, strong) NSDictionary *requestParameters;

@property (nonatomic, strong) NSDictionary *requestHeader;
@property (nonatomic, assign) HHNetworkRequestType requestType;
@end

@interface HHTaskConfiguration : HHRequestConfiguration

@property (nonatomic, strong) Class deserializeClass;
@property (nonatomic, copy) NSString *deserializePath;

@end

@interface HHDataTaskConfiguration : HHTaskConfiguration

@property (nonatomic, assign) NSTimeInterval cacheValidTimeInterval;

@end

@interface HHUploadTaskConfiguration : HHTaskConfiguration

@property (nonatomic, strong) NSArray<HHUploadFile *> * uploadContents;

@end

#pragma mark - HHAPIManager

@interface HHAPIManager : NSObject

- (void)cancelAllTask;
- (void)cancelTask:(NSNumber *)taskIdentifier;

- (NSURLSessionDataTask *)dataTaskWithConfiguration:(HHDataTaskConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler;
- (NSNumber *)dispatchDataTaskWithConfiguration:(HHDataTaskConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler;
- (NSNumber *)dispatchUploadTaskWithConfiguration:(HHUploadTaskConfiguration *)config progressHandler:(HHNetworkTaskProgressHandler)progressHandler completionHandler:(HHNetworkTaskCompletionHander)completionHandler;

@end
