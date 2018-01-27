//
//  HHNetworkTaskError.h
//  TAFNetworking
//
//  Created by 黑花白花 on 2017/2/11.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#ifndef HHNetworkTaskError_h
#define HHNetworkTaskError_h

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    HHNetworkTaskSuccess = 1,
    HHNetworkTaskErrorTimeOut = 101,
    HHNetworkTaskErrorCannotConnectedToInternet = 102,
    HHNetworkTaskErrorCanceled = 103,
    HHNetworkTaskErrorDefault = 104,
    HHNetworkTaskErrorNoData = 105,
    HHNetworkTaskErrorNoMoreData = 106
} HHNetworkTaskError;

static NSError *HHError(NSString *domain, NSInteger code) {
    return [NSError errorWithDomain:domain code:code userInfo:nil];
}

static NSString *HHNoDataErrorNotice = @"这里什么也没有~";
static NSString *HHNetworkErrorNotice = @"当前网络差, 请检查网络设置~";
static NSString *HHTimeoutErrorNotice = @"请求超时了~";
static NSString *HHDefaultErrorNotice = @"请求失败了~";
static NSString *HHNoMoreDataErrorNotice = @"没有更多了~";

typedef void(^HHNetworkTaskCompletionHander)(NSError *error,NSDictionary *result);
#endif 
