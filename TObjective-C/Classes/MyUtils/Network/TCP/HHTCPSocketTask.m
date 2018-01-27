//
//  HHTCPSocketTask.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <YYModel/YYModel.h>

#import "HHTCPSocketTask.h"
#import "HHTCPSocketClient.h"

@interface HHTCPSocketRequest ()

- (NSData *)requestData;

@end

@interface HHTCPSocketClient ()

- (void)resumeTask:(HHTCPSocketTask *)task;

@end

@interface HHTCPSocketTask ()

@property (weak, nonatomic) id client;
@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) HHTCPSocketTaskState state;
@property (strong, nonatomic) HHTCPSocketRequest *request;
@property (copy, nonatomic) HHNetworkTaskCompletionHander completionHandler;

@end

@implementation HHTCPSocketTask

#pragma mark - Interface(Public)

+ (instancetype)taskWithRequest:(HHTCPSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    HHTCPSocketTask *task = [HHTCPSocketTask new];
    task.state = HHTCPSocketTaskStateSuspended;
    task.request = request;
    if (completionHandler != nil) {
        task.completionHandler = ^(NSError *error, id result) {
            
            completionHandler(error, result);
            task.state = task.state >= HHTCPSocketTaskStateCanceled ? task.state : HHTCPSocketTaskStateCompleted;
        };
    }
    return task;
}

+ (NSError *)taskErrorWithResponeCode:(NSUInteger)code {
    
#define HHTaskErrorCase(responeCode, errorDomain) case responeCode: return HHError(errorDomain, code)
    switch (code) {
            
            HHTaskErrorCase(HHNetworkTaskErrorDefault, HHDefaultErrorNotice);
            HHTaskErrorCase(HHTCPSocketTaskErrorInvalidMsgLength, @"消息长度不合法");
            HHTaskErrorCase(HHTCPSocketTaskErrorLostPacket, @"后台Adler验证消息失败(丢包)");
            HHTaskErrorCase(HHTCPSocketTaskErrorInvalidMsgFormat, @"消息格式不合法");
            HHTaskErrorCase(HHTCPSocketTaskErrorUndefinedMsgType, @"消息类型未找到");
            HHTaskErrorCase(HHTCPSocketTaskErrorEncodeProtobuf, @"protobuf解析失败");
            HHTaskErrorCase(HHTCPSocketTaskErrorDatabaseException, @"数据库操作异常");
            HHTaskErrorCase(HHTCPSocketTaskErrorUnkonwn, @"未知错误");
            HHTaskErrorCase(HHTCPSocketTaskErrorNoPermission, @"无权限");
            HHTaskErrorCase(HHNetworkTaskErrorCannotConnectedToInternet, HHNetworkErrorNotice);
            HHTaskErrorCase(HHTCPSocketTaskErrorLostConnection, @"长连接断开连接");
            HHTaskErrorCase(HHNetworkTaskErrorTimeOut, HHTimeoutErrorNotice);
            HHTaskErrorCase(HHNetworkTaskErrorCanceled, @"任务已取消");
            HHTaskErrorCase(HHTCPSocketTaskErrorNoMatchAdler, @"前端Adler32验证失败");
            HHTaskErrorCase(HHTCPSocketTaskErrorNoProtobuf, @"protobufBody为空");
            HHTaskErrorCase(HHNetworkTaskErrorNoData, HHNoDataErrorNotice);
            HHTaskErrorCase(HHNetworkTaskErrorNoMoreData, HHNoMoreDataErrorNotice);
            
        default: return nil;
    }
}

- (void)cancel {
    
    if (self.state <= HHTCPSocketTaskStateRunning) {
        
        [self completeWithResult:nil error:[self taskErrorWithResponeCode:HHNetworkTaskErrorCanceled]];
        self.state = HHTCPSocketTaskStateCanceled;
    }
}

- (void)resume {

    if (self.state == HHTCPSocketTaskStateSuspended) {
     
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.request.timeoutInterval target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
        self.state = HHTCPSocketTaskStateRunning;
        [self.client resumeTask:self];
    }
}

- (NSNumber *)taskIdentifier {
    return self.request.requestIdentifier;
}

#pragma mark - Interface(Friend)

- (NSData *)taskData {
    return self.request.requestData;
}

//- (void)completeWithResponseData:(NSData *)responseData error:(NSError *)error {
//
//    if (self.state <= HHTCPSocketTaskStateRunning) {
//
//        NSData *responseContent;
//        if (responseData == nil) {
//            error = [self taskErrorWithResponeCode:HHTCPSocketTaskErrorUnkonwn];
//        } else {
//
//            int responseCode = [HHTCPSocketResponseFormatter responseCodeFromData:responseData];
//            int responseContentLength = [HHTCPSocketResponseFormatter responseContentLengthFromData:responseData];
//            NSData *responseAdler = [HHTCPSocketResponseFormatter responseAdlerFromData:responseData];
//
//            responseContent = [HHTCPSocketResponseFormatter responseContentFromData:responseData];
//            NSData *adler = [HHDataFormatter adler32ToDataWithProtoBuffByte:(Byte *)responseContent.bytes length:responseContentLength];
//
//            error = [self taskErrorWithResponeCode:([responseAdler isEqual:adler] ? responseCode : HHTCPSocketTaskErrorNoMatchAdler)];
//        }
//        [self completeWithResult:responseContent error:error];
//        error ? NSLog(@"socket请求失败: %ld %@",error.code, error.domain) : nil;
//    }
//}

- (void)completeWithResponseData:(NSData *)responseData error:(NSError *)error {
    
    if (self.state <= HHTCPSocketTaskStateRunning) {
        
        NSDictionary *result;
        if (responseData == nil) {
            error = [self taskErrorWithResponeCode:HHTCPSocketTaskErrorUnkonwn];
        } else {
            
            int responseCode = [HHTCPSocketResponseFormatter responseCodeFromData:responseData];
            NSData *responseContent = [HHTCPSocketResponseFormatter responseContentFromData:responseData];
            error = [self taskErrorWithResponeCode:(responseCode)];
            result = [NSJSONSerialization JSONObjectWithData:responseContent options:0 error:nil];
        }
        [self completeWithResult:result error:error];
    }
}

- (void)printData:(NSData *)data {
    
    for (int i = 0 ; i < data.length; i++) {
        printf("%d ", ((char *)data.bytes)[i]);
    }
    printf("\n");
}

#pragma mark - Action

- (void)requestTimeout {
    
    if (self.state <= HHTCPSocketTaskStateRunning) {
        NSLog(@"requestTimeout");
        self.state = HHTCPSocketTaskStateCanceled;
        [self completeWithResult:nil error:[self taskErrorWithResponeCode:HHNetworkTaskErrorTimeOut]];
    }
}

#pragma mark - Utils

- (void)completeWithResult:(id)result error:(NSError *)error {
    
    [self.timer invalidate];
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        !self.completionHandler ?: self.completionHandler(error, result);
        self.completionHandler = nil;
    });
}

- (NSError *)taskErrorWithResponeCode:(int)code {
    return [HHTCPSocketTask taskErrorWithResponeCode:code];
}

@end
