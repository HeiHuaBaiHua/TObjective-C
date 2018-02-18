//
//  HHTCPSocketResponse.m
//  TObjective-C
//
//  Created by 黑花白花 on 2018/2/18.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHDataFormatter.h"
#import "HHTCPSocketResponse.h"

@interface HHTCPSocketResponse ()

@property (nonatomic, strong) NSData *data;

@property (nonatomic, assign) uint32_t serNum;
@property (nonatomic, assign) uint32_t statusCode;
@property (nonatomic, assign) HHTCPSocketRequestURL url;

@end

@implementation HHTCPSocketResponse

+ (instancetype)responseWithData:(NSData *)data {
    if (data.length < [HHTCPSocketResponseParser responseHeaderLength]) {
        return nil;
    }
    
    HHTCPSocketResponse *response = [HHTCPSocketResponse new];
    response.data = data;
    return response;
}

- (HHTCPSocketRequestURL)url {
    if (_url == 0) {
        _url = [HHTCPSocketResponseParser responseURLFromData:self.data];
    }
    return _url;
}

- (uint32_t)serNum {
    if (_serNum == 0) {
        _serNum = [HHTCPSocketResponseParser responseSerialNumberFromData:self.data];
    }
    return _serNum;
}

- (uint32_t)statusCode {
    if (_statusCode == 0) {
        _statusCode = [HHTCPSocketResponseParser responseCodeFromData:self.data];
    }
    return _statusCode;
}

- (NSData *)content {
    return [HHTCPSocketResponseParser responseContentFromData:self.data];
}

@end
