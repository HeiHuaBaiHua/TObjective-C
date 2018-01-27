//
//  HHTCPSocketRequest.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHTCPSocketConfig.h"
#import "HHDataFormatter.h"
#import "GeneratedMessage.h"

typedef enum : NSUInteger {
    HHTCPSocketRequestTypeHearbeat = 0,
    HHTCPSocketRequestTypePush,
    HHTCPSocketRequestTypeCancel
} HHTCPSocketRequestType;

/** URL类型肯定都是后台定义的 直接copy过来即可 命名用后台的 方便调试时比对 */
typedef enum : NSUInteger {
    LOGIN = 0x0001,
    WEIBO_LIST = 0x0008
} HHTCPSocketRequestURL;

@interface HHTCPSocketRequest : NSObject

@property (assign, nonatomic) NSUInteger timeoutInterval;

+ (instancetype)heartbeatRequestWithAckNum:(int)ackNum;/**< 心跳任务请求 */
+ (instancetype)requestWithURL:(HHTCPSocketRequestURL)url message:(PBGeneratedMessage *)message header:(NSDictionary *)header;/**< 数据任务请求(protobuf版) */
+ (instancetype)requestWithURL:(HHTCPSocketRequestURL)url parameters:(NSDictionary *)parameters header:(NSDictionary *)header;/**< 数据任务请求(json版) */

- (NSNumber *)requestIdentifier;

@end
