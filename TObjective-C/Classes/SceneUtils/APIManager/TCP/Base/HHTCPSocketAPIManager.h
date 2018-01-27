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

@property (assign, nonatomic) HHTCPSocketRequestURL url;
@property (strong, nonatomic) NSDictionary *requestParameters;
@property (strong, nonatomic) NSDictionary *requestHeader;
@end

@interface HHTCPTaskConfiguration : HHTCPRequestConfiguration

@property (nonatomic, strong) Class deserializeClass;
@property (nonatomic, copy) NSString *deserializePath;

@end

@interface HHTCPDataTaskConfiguration : HHTCPTaskConfiguration

@property (assign, nonatomic) NSTimeInterval cacheValidTimeInterval;

@end

@interface HHTCPSocketAPIManager : NSObject

- (void)cancelAllTask;
- (void)cancelTask:(NSNumber *)taskIdentifier;

- (NSNumber *)dispatchDataTaskWithConfiguration:(HHTCPDataTaskConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler;

@end
