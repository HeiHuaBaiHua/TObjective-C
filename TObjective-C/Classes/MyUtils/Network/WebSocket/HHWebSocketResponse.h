//
//  HHWebSocketResponse.h
//  TObjective-C
//
//  Created by 黑花白花 on 2018/2/18.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHWebSocketRequest.h"
@interface HHWebSocketResponse : NSObject

+ (instancetype)responseWithData:(id)data;

- (HHWebSocketRequestURL)url;

- (uint32_t)serNum;
- (NSDictionary *)content;

@end
