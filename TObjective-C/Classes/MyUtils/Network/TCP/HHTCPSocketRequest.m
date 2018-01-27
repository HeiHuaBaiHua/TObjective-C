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

@property (strong, nonatomic) NSNumber *requestIdentifier;
@property (strong, nonatomic) NSMutableData *formattedData;

@end

#define TimeoutInterval 8
#define HHTCPSocketTaskInitialSerialNumber 50
@implementation HHTCPSocketRequest

- (instancetype)init {
    if (self = [super init]) {
        
        self.formattedData = [NSMutableData data];
        self.timeoutInterval = TimeoutInterval;
    }
    return self;
}

+ (int)currentRequestIdentifier {
    
    static int currentRequestIdentifier;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        currentRequestIdentifier = HHTCPSocketTaskInitialSerialNumber;
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    currentRequestIdentifier += 1;
    dispatch_semaphore_signal(lock);
    
    return currentRequestIdentifier;
}

#pragma mark - Interface(Public)

+ (instancetype)heartbeatRequestWithAckNum:(int)ackNum {
    
    int messageType = HHTCPSocketRequestTypeHearbeat;
    HHTCPSocketRequest *request = [HHTCPSocketRequest new];
    request.requestIdentifier = @-1;
    [request.formattedData appendData:[self.sessionId dataUsingEncoding:NSUTF8StringEncoding]];
    [request.formattedData appendData:[HHDataFormatter msgTypeDataFromInteger:messageType]];/** 请求URL */
    [request.formattedData appendData:[HHDataFormatter msgSerialNumberDataFromInteger:ackNum]];/** 请求序列号 */
    
    [request.formattedData appendData:[HHDataFormatter msgContentLengthDataFromInteger:0]];
    return request;
}

+ (instancetype)requestWithURL:(HHTCPSocketRequestURL)url message:(PBGeneratedMessage *)message header:(NSDictionary *)header {
    
    int requestIdentifier = [self currentRequestIdentifier];
    int messageLength = (int)message.data.length;
    
    HHTCPSocketRequest *request = [HHTCPSocketRequest new];
    request.requestIdentifier = @(requestIdentifier);
    [request.formattedData appendData:[self.sessionId dataUsingEncoding:NSUTF8StringEncoding]];
    [request.formattedData appendData:[HHDataFormatter msgTypeDataFromInteger:url]];/** 请求URL */
    [request.formattedData appendData:[HHDataFormatter msgSerialNumberDataFromInteger:requestIdentifier]];/** 请求序列号 */
    [request.formattedData appendData:[HHDataFormatter msgContentLengthDataFromInteger:messageLength]];/** 请求体长度 */
    
    [request.formattedData appendData:message.data];/** 请求体 */
    
    [request.formattedData appendData:[HHDataFormatter adler32ToDataWithProtoBuffByte:(Byte *)message.data.bytes length:messageLength]];/** 数据校验 */
    return request;
}

/** demo用简化版 json代替protobuf 无sessionId 无校验 */
+ (instancetype)requestWithURL:(HHTCPSocketRequestURL)url parameters:(NSDictionary *)parameters header:(NSDictionary *)header {
    
    int requestIdentifier = [self currentRequestIdentifier];
    NSData *data = [parameters yy_modelToJSONData];
    int contentLength = (int)data.length;
    
    HHTCPSocketRequest *request = [HHTCPSocketRequest new];
    request.requestIdentifier = @(requestIdentifier);
    [request.formattedData appendData:[HHDataFormatter msgTypeDataFromInteger:url]];
    [request.formattedData appendData:[HHDataFormatter msgSerialNumberDataFromInteger:requestIdentifier]];
    [request.formattedData appendData:[HHDataFormatter msgContentLengthDataFromInteger:contentLength]];
    
    [request.formattedData appendData:data];
    
//    [request printData];
    return request;
}

- (void)printData {
    
    NSData *data = [self.formattedData copy];
    for (int i = 0 ; i < data.length; i++) {
        printf("%d ", ((char *)data.bytes)[i]);
    }
    printf("\n");
}

#pragma mark - Interface(Friend)

- (NSData *)requestData {
    return self.formattedData;
}

#pragma mark - Utils

+ (NSString *)sessionId {
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:kSocketSessionId];
    return sessionId.length > 0 ? sessionId : @"xxx";
}

@end
