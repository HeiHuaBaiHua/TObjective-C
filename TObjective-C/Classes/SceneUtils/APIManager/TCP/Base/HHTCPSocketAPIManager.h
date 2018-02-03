//
//  HHTCPSocketAPIManager.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/1/27.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHTCPSocketRequest.h"
#import "HHNetworkTaskError.h"

@interface HHTCPRequestConfiguration : NSObject

@property (nonatomic, assign) HHTCPSocketRequestURL url;
@property (nonatomic, strong) NSDictionary *requestParameters;
@property (nonatomic, strong) NSDictionary *requestHeader;
@end

@interface HHTCPTaskConfiguration : HHTCPRequestConfiguration

@property (nonatomic, strong) Class deserializeClass;
@property (nonatomic, copy) NSString *deserializePath;

@end

@interface HHTCPDataTaskConfiguration : HHTCPTaskConfiguration

@property (nonatomic, assign) NSTimeInterval cacheValidTimeInterval;

@end

@interface HHTCPSocketAPIManager : NSObject

- (void)cancelAllTask;
- (void)cancelTask:(NSNumber *)taskIdentifier;

- (NSNumber *)dispatchDataTaskWithConfiguration:(HHTCPDataTaskConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler;

@end
