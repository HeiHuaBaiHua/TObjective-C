//
//  HHTCPSocketRequest.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ProtocolBuffers/GeneratedMessage.h>

#import "HHDataFormatter.h"

/** URL类型肯定都是后台定义的 直接copy过来即可 命名用后台的 方便调试时比对 */
typedef enum : NSUInteger {
    TCP_heatbeat = 0x00000001,
    TCP_notification_xxx = 0x00000002,
    TCP_notification_yyy = 0x00000003,
    TCP_notification_zzz = 0x00000004,
    
    /* ========== */
    TCP_max_notification = 0x00000400,
    /* ========== */
    
    TCP_login = 0x00000401,
    TCP_weibo_list_public = 0x00000402,
    TCP_weibo_list_followed = 0x00000403,
    TCP_weibo_like = 0x00000404
} HHTCPSocketRequestURL;

@interface HHTCPSocketRequest : NSObject

@property (nonatomic, assign) NSUInteger timeoutInterval;

//+ (instancetype)requestWithURL:(HHTCPSocketRequestURL)url parameters:(PBGeneratedMessage *)parameters header:(NSDictionary *)header;/**< 数据任务请求(protobuf版) */
+ (instancetype)requestWithURL:(HHTCPSocketRequestURL)url parameters:(NSDictionary *)parameters header:(NSDictionary *)header;/**< 数据任务请求(json版) */

- (NSData *)requestData;
- (NSNumber *)requestIdentifier;

@end
