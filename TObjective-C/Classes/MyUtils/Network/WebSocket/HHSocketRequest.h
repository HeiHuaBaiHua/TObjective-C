//
//  HHSocketRequest.h
//  HHvce
//
//  Created by leihaiyin on 2017/9/28.
//  Copyright © 2017年 tiger. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    HHSocketURLLogin,/** 登陆 */
    HHSocketURLSubscribe,/** 订阅 */
    HHSocketURLUnsubscribe,/** 取消订阅 */
} HHSocketRequestURL;

@interface HHSocketRequest : NSObject

@property (assign, nonatomic) NSUInteger timeoutInterval;

- (instancetype)initWithURL:(HHSocketRequestURL)url parameters:(NSDictionary *)parameters;

- (id)requestBody;
- (NSNumber *)requestIdentifier;

@end
