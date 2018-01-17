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
typedef void(^HHNetworkTaskCompletionHander)(NSError *error, id result);

@interface HHRequestConfiguration : NSObject

@property (copy, nonatomic) NSString *urlPath;
@property (strong, nonatomic) NSDictionary *requestParameters;

@property (strong, nonatomic) NSDictionary *requestHeader;
@property (assign, nonatomic) HHNetworkRequestType requestType;
@end

@interface HHTaskConfiguration : HHRequestConfiguration

@property (nonatomic, strong) Class deserializeClass;
@property (nonatomic, copy) NSString *deserializePath;

@end

@interface HHDataTaskConfiguration : HHTaskConfiguration

@property (assign, nonatomic) NSTimeInterval cacheValidTimeInterval;

@end

@interface HHUploadTaskConfiguration : HHTaskConfiguration

@property (strong, nonatomic) NSArray<HHUploadFile *> * uploadContents;

@end

#pragma mark - HHAPIManager

@interface HHAPIManager : NSObject

- (void)cancelAllTask;
- (void)cancelTask:(NSNumber *)taskIdentifier;

- (NSNumber *)dispatchDataTaskWithConfiguration:(HHDataTaskConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler;
- (NSNumber *)dispatchUploadTaskWithConfiguration:(HHUploadTaskConfiguration *)config progressHandler:(HHNetworkTaskProgressHandler)progressHandler completionHandler:(HHNetworkTaskCompletionHander)completionHandler;

@end
