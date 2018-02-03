//
//  HHTCPSocketRequest.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <YYModel/YYModel.h>

#import "HHTCPSocketRequest.h"
@interface HHTCPSocketRequest ()

@property (nonatomic, strong) NSNumber *requestIdentifier;
@property (nonatomic, strong) NSMutableData *formattedData;

@end

@implementation HHTCPSocketRequest

- (instancetype)init {
    if (self = [super init]) {
        self.formattedData = [NSMutableData data];
    }
    return self;
}

+ (uint32_t)currentRequestIdentifier {
    
    static uint32_t currentRequestIdentifier;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        currentRequestIdentifier = TCP_max_notification;
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    if (currentRequestIdentifier + 1 == 0xffffffff) {
        currentRequestIdentifier = TCP_max_notification;
    }
    currentRequestIdentifier += 1;
    dispatch_semaphore_signal(lock);
    
    return currentRequestIdentifier;
}

#pragma mark - Interface(Public)

//+ (instancetype)requestWithURL:(HHTCPSocketRequestURL)url parameters:(PBGeneratedMessage *)parameters header:(NSDictionary *)header {
//
//    uint32_t requestIdentifier = [self currentRequestIdentifier];
//    uint32_t messageContentLength = (uint32_t)parameters.data.length;
//    NSString *sessionId = header[@"sessionId"] ?: @"xxx";
//
//    HHTCPSocketRequest *request = [HHTCPSocketRequest new];
//    request.requestIdentifier = @(requestIdentifier);
//    [request.formattedData appendData:[sessionId dataUsingEncoding:NSUTF8StringEncoding]];
//    [request.formattedData appendData:[HHDataFormatter msgTypeDataFromInteger:url]];/** 请求URL */
//    [request.formattedData appendData:[HHDataFormatter msgVersionDataFromInteger:1]];/** 版本号 */
//    [request.formattedData appendData:[HHDataFormatter msgSerialNumberDataFromInteger:requestIdentifier]];/** 请求序列号 */
//    [request.formattedData appendData:[HHDataFormatter msgContentLengthDataFromInteger:messageContentLength]];/** 请求体长度 */
//
//    [request.formattedData appendData:parameters.data];/** 请求体 */
//
//    [request.formattedData appendData:[HHDataFormatter adler32ToDataWithProtoBuffByte:(Byte *)parameters.data.bytes length:messageContentLength]];/** 数据校验 */
//    return request;
//}

/** demo用简化版 json代替protobuf 无版本号 无sessionId 无校验 */
+ (instancetype)requestWithURL:(HHTCPSocketRequestURL)url parameters:(NSDictionary *)parameters header:(NSDictionary *)header {
    
    if (url == TCP_heatbeat) { return [self heartbeatRequestWithParameters:parameters]; }
    
    NSData *content = [parameters yy_modelToJSONData];
    uint32_t requestIdentifier = [self currentRequestIdentifier];
    
    HHTCPSocketRequest *request = [HHTCPSocketRequest new];
    request.requestIdentifier = @(requestIdentifier);
    [request.formattedData appendData:[HHDataFormatter msgTypeDataFromInteger:url]];
    [request.formattedData appendData:[HHDataFormatter msgSerialNumberDataFromInteger:requestIdentifier]];
    [request.formattedData appendData:[HHDataFormatter msgContentLengthDataFromInteger:(uint32_t)content.length]];
    
    [request.formattedData appendData:content];
    return request;
}

+ (instancetype)heartbeatRequestWithParameters:(NSDictionary *)parameters {
    uint32_t ackNum = (uint32_t)[parameters[@"ackNum"] integerValue];
    
    HHTCPSocketRequest *request = [HHTCPSocketRequest new];
    request.requestIdentifier = @(TCP_heatbeat);
    [request.formattedData appendData:[HHDataFormatter msgTypeDataFromInteger:TCP_heatbeat]];
    [request.formattedData appendData:[HHDataFormatter msgSerialNumberDataFromInteger:ackNum]];
    [request.formattedData appendData:[HHDataFormatter msgContentLengthDataFromInteger:0]];
    
    return request;
}

- (NSData *)requestData {
    return [self.formattedData copy];
}

#pragma mark - Getter

- (NSUInteger)timeoutInterval {
    return _timeoutInterval > 0 ? _timeoutInterval : 6;
}

@end
