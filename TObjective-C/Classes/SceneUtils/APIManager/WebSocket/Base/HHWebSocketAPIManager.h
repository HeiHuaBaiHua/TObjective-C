//
//  HHWebSocketAPIManger.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/3.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHWebSocketRequest.h"
#import "HHNetworkTaskError.h"

@interface HHWebRequestConfiguration : NSObject

@property (nonatomic, assign) HHWebSocketRequestURL url;
@property (nonatomic, strong) NSDictionary *requestParameters;
@property (nonatomic, strong) NSDictionary *requestHeader;
@end

@interface HHWebTaskConfiguration : HHWebRequestConfiguration

@property (nonatomic, strong) Class deserializeClass;
@property (nonatomic, copy) NSString *deserializePath;

@end

@interface HHWebDataTaskConfiguration : HHWebTaskConfiguration

@property (nonatomic, assign) NSTimeInterval cacheValidTimeInterval;

@end

@interface HHWebSocketAPIManager : NSObject

- (void)cancelAllTask;
- (void)cancelTask:(NSNumber *)taskIdentifier;

- (NSNumber *)dispatchDataTaskWithConfiguration:(HHWebDataTaskConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler;

@end
