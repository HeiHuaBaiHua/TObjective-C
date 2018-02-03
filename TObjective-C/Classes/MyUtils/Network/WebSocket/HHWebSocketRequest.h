//
//  HHWebSocketRequest.h
//  HHvce
//
//  Created by HeiHuaBaiHua on 2017/9/28.
//  Copyright © 2017年 tiger. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    WEBSOCKET_heatbeat = 0x00000001,
    WEBSOCKET_notification_xxx = 0x00000002,
    WEBSOCKET_notification_yyy = 0x00000003,
    WEBSOCKET_notification_zzz = 0x00000004,
    
    /* ========== */
    WEBSOCKET_max_notification = 0x00000400,
    /* ========== */
    
    WEBSOCKET_login = 0x00000401,
    WEBSOCKET_weibo_list_public = 0x00000402,
    WEBSOCKET_weibo_list_followed = 0x00000403,
    WEBSOCKET_weibo_like = 0x00000404
} HHWebSocketRequestURL;

@interface HHWebSocketRequest : NSObject

@property (nonatomic, assign) NSUInteger timeoutInterval;

+ (instancetype)requestWithURL:(HHWebSocketRequestURL)url parameters:(NSDictionary *)parameters header:(NSDictionary *)header;;

- (id)requestData;
- (NSNumber *)requestIdentifier;

@end
