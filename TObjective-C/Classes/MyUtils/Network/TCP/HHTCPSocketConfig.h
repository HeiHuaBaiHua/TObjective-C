//
//  HHTCPSocketConfig.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/1/17.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#ifndef HHTCPSocketConfig_h
#define HHTCPSocketConfig_h

typedef enum : NSUInteger {
    HHTCPSocketTaskSuccess = 200,
    HHTCPSocketTaskErrorLostConnection = 300,
    HHTCPSocketTaskErrorInvalidMsgLength = 301,
    HHTCPSocketTaskErrorLostPacket = 302,
    HHTCPSocketTaskErrorInvalidMsgFormat = 303,
    HHTCPSocketTaskErrorUndefinedMsgType = 401,
    HHTCPSocketTaskErrorEncodeProtobuf = 402,
    HHTCPSocketTaskErrorDatabaseException = 403,
    HHTCPSocketTaskErrorUnkonwn = 404,
    HHTCPSocketTaskErrorNoPermission = 405,
    HHTCPSocketTaskErrorNoMatchAdler = 455,
    HHTCPSocketTaskErrorNoProtobuf = 456
} HHTCPSocketTaskError;

static NSUInteger const HHMaxResponseLength = 20480;

#define kSocketSessionId @"xxx"

#define SessionIdLength 0/** SessionId的长度 */
#define MsgTypeLength 4/** 消息类型的长度 */
#define MsgSerialNumberLength 4/** 消息序号的长度 */
#define MsgResponseCodeLength 4/** 消息响应状态码的长度 */
#define MsgContentLength 4/** 消息有效载荷的长度 */
#define Adler32Length 0/** Adler32的长度 */
#define MsgResponseHeaderLength (MsgTypeLength + MsgSerialNumberLength + MsgResponseCodeLength + MsgContentLength)/** 消息响应的头部长度 */

#endif
