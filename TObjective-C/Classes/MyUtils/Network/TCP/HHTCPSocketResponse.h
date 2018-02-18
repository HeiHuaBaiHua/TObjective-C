//
//  HHTCPSocketResponse.h
//  TObjective-C
//
//  Created by 黑花白花 on 2018/2/18.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHTCPSocketRequest.h"

typedef enum : NSUInteger {
    HHTCPSocketResponseCodeSuccess = 200,
    HHTCPSocketResponseCodeLostConnection = 300,
    HHTCPSocketResponseCodeInvalidMsgLength = 301,
    HHTCPSocketResponseCodeLostPacket = 302,
    HHTCPSocketResponseCodeInvalidMsgFormat = 303,
    HHTCPSocketResponseCodeUndefinedMsgType = 401,
    HHTCPSocketResponseCodeEncodeProtobuf = 402,
    HHTCPSocketResponseCodeDatabaseException = 403,
    HHTCPSocketResponseCodeUnkonwn = 404,
    HHTCPSocketResponseCodeNoPermission = 405,
    HHTCPSocketResponseCodeNoMatchAdler = 455,
    HHTCPSocketResponseCodeNoProtobuf = 456
} HHTCPSocketResponseCode;

@interface HHTCPSocketResponse : NSObject

+ (instancetype)responseWithData:(NSData *)data;

- (HHTCPSocketRequestURL)url;

- (NSData *)content;
- (uint32_t)serNum;
- (uint32_t)statusCode;
@end
