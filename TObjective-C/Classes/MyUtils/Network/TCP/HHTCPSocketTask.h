//
//  HHTCPSocketTask.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHNetworkConfig.h"
#import "HHNetworkTaskError.h"

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

typedef enum : NSUInteger {
    HHTCPSocketTaskStateSuspended = 0,
    HHTCPSocketTaskStateRunning = 1,
    HHTCPSocketTaskStateCanceled = 2,
    HHTCPSocketTaskStateCompleted = 3
} HHTCPSocketTaskState;

@interface HHTCPSocketTask : NSObject

- (void)cancel;
- (void)resume;

- (HHTCPSocketRequest *)request;
- (HHTCPSocketTaskState)state;
- (NSNumber *)taskIdentifier;

@end
