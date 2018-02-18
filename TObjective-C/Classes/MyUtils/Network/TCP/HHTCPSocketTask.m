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

@property (nonatomic, weak) id client;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) HHTCPSocketTaskState state;
@property (nonatomic, strong) HHTCPSocketRequest *request;
@property (nonatomic, copy) HHNetworkTaskCompletionHander completionHandler;

@property (nonatomic, strong) HHTCPSocketTask *keeper;
@end

@implementation HHTCPSocketTask

#pragma mark - Interface(Public)

+ (instancetype)taskWithRequest:(HHTCPSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    HHTCPSocketTask *task = [HHTCPSocketTask new];
    task.state = HHTCPSocketTaskStateSuspended;
    task.request = request;
    task.completionHandler = completionHandler;
    task.keeper = task;
    return task;
}

- (void)cancel {
    if (![self canResponse]) { return; }
    
    self.state = HHTCPSocketTaskStateCanceled;
    [self completeWithResult:nil error:[self taskErrorWithResponeCode:HHNetworkTaskErrorCanceled]];
}

- (void)resume {
    if (self.state != HHTCPSocketTaskStateSuspended) { return; }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.request.timeoutInterval target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    self.state = HHTCPSocketTaskStateRunning;
    [self.client resumeTask:self];
}

- (NSNumber *)taskIdentifier {
    return self.request.requestIdentifier;
}

#pragma mark - Interface(Friend)

- (void)completeWithResponse:(HHTCPSocketResponse *)response error:(NSError *)error {
    if (![self canResponse]) { return; }
    
    NSDictionary *result;
    if (error == nil) {
    
        if (response == nil) {
            error = [self taskErrorWithResponeCode:HHTCPSocketResponseCodeUnkonwn];
        } else {
            
            error = [self taskErrorWithResponeCode:response.statusCode];
            result = [NSJSONSerialization JSONObjectWithData:response.content options:0 error:nil];
        }
    }
    
    [self completeWithResult:result error:error];
}

#pragma mark - Action

- (void)requestTimeout {
    if (![self canResponse]) { return; }
    
    self.state = HHTCPSocketTaskStateCompleted;
    [self completeWithResult:nil error:[self taskErrorWithResponeCode:HHNetworkTaskErrorTimeOut]];
}

#pragma mark - Utils

- (void)completeWithResult:(id)result error:(NSError *)error {
    
    self.state = (self.state >= HHTCPSocketTaskStateCanceled ? self.state : HHTCPSocketTaskStateCompleted);
    [self.timer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        !self.completionHandler ?: self.completionHandler(error, result);
        self.completionHandler = nil;
        self.keeper = nil;
    });
}

- (NSError *)taskErrorWithResponeCode:(uint32_t)code {
    return [HHTCPSocketTask taskErrorWithResponeCode:code];
}

- (BOOL)canResponse {
    return self.state <= HHTCPSocketTaskStateRunning;
}

+ (NSError *)taskErrorWithResponeCode:(NSUInteger)code {
    
#define HHTaskErrorCase(responeCode, errorDomain) case responeCode: return HHError(errorDomain, code)
    switch (code) {
            
            HHTaskErrorCase(HHNetworkTaskErrorDefault, HHDefaultErrorNotice);
            HHTaskErrorCase(HHTCPSocketResponseCodeInvalidMsgLength, @"消息长度不合法");
            HHTaskErrorCase(HHTCPSocketResponseCodeLostPacket, @"后台Adler验证消息失败");
            HHTaskErrorCase(HHTCPSocketResponseCodeInvalidMsgFormat, @"消息格式不合法");
            HHTaskErrorCase(HHTCPSocketResponseCodeUndefinedMsgType, @"消息类型未找到");
            HHTaskErrorCase(HHTCPSocketResponseCodeEncodeProtobuf, @"protobuf解析失败");
            HHTaskErrorCase(HHTCPSocketResponseCodeDatabaseException, @"数据库操作异常");
            HHTaskErrorCase(HHTCPSocketResponseCodeUnkonwn, @"未知错误");
            HHTaskErrorCase(HHTCPSocketResponseCodeNoPermission, @"无权限");
            HHTaskErrorCase(HHNetworkTaskErrorCannotConnectedToInternet, HHNetworkErrorNotice);
            HHTaskErrorCase(HHTCPSocketResponseCodeLostConnection, @"Socket已断开");
            HHTaskErrorCase(HHNetworkTaskErrorTimeOut, HHTimeoutErrorNotice);
            HHTaskErrorCase(HHNetworkTaskErrorCanceled, @"任务已取消");
            HHTaskErrorCase(HHTCPSocketResponseCodeNoMatchAdler, @"前端Adler32验证失败");
            HHTaskErrorCase(HHTCPSocketResponseCodeNoProtobuf, @"protobufBody为空");
            HHTaskErrorCase(HHNetworkTaskErrorNoData, HHNoDataErrorNotice);
            HHTaskErrorCase(HHNetworkTaskErrorNoMoreData, HHNoMoreDataErrorNotice);
            
        default: return nil;
    }
}

@end
