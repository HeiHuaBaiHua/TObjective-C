//
//  HHURLRequestGenerator.m
//  HeiHuaBaiHua
//
//  Created by HeiHuaBaiHua on 16/5/31.
//  Copyright © 2016年 HeiHuaBaiHua. All rights reserved.
//
#import "HHNetworkConfig.h"

#import "HHService.h"
#import "HHURLRequestGenerator.h"
#import "AFURLRequestSerialization.h"

@interface HHURLRequestGenerator ()

@property (nonatomic, strong) HHService *service;
@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerialize;

@end

@implementation HHURLRequestGenerator

+ (instancetype)sharedInstance {
    
    static HHURLRequestGenerator *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[super allocWithZone:NULL] init];
        sharedInstance.service = [HHService serviceWithType:BulidService];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

#pragma mark - Interface

- (NSMutableURLRequest *)generateRequestWithUrlPath:(NSString *)urlPath method:(NSString *)method params:(NSDictionary *)params header:(NSDictionary *)header {
    
    NSString *urlString = [self urlStringWithPath:urlPath];
    NSMutableURLRequest *request = [self.requestSerialize requestWithMethod:method URLString:urlString parameters:params error:nil];
    request.timeoutInterval = RequestTimeoutInterval;
    [self setCommonRequestHeaderForRequest:request];
    [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    return request;
}

- (NSMutableURLRequest *)generateUploadRequestUrlPath:(NSString *)urlPath params:(NSDictionary *)params contents:(NSArray<HHUploadFile *> *)contents header:(NSDictionary *)header {
    
    NSString *urlString = [self urlStringWithPath:urlPath];
    NSMutableURLRequest *request = [self.requestSerialize multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [contents enumerateObjectsUsingBlock:^(HHUploadFile * _Nonnull file, NSUInteger idx, BOOL * _Nonnull stop) {
            [formData appendPartWithFileData:file.fileData name:file.uploadKey fileName:file.fileName mimeType:file.fileType];
        }];
        
    } error:nil];
    request.timeoutInterval = RequestTimeoutInterval * 2;
    [self setCookies];
    [self setCommonRequestHeaderForRequest:request];
    [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    return request;
}

#pragma mark - Utils

- (NSString *)urlStringWithPath:(NSString *)path {
    
    if ([path hasPrefix:@"http"]) {
        return path;
    }
    return [NSString stringWithFormat:@"%@%@", self.service.baseUrl, path];
}

- (void)setCookies {
    
}

- (NSMutableURLRequest *)setCommonRequestHeaderForRequest:(NSMutableURLRequest *)request {
    
//    在这里设置通用的请求头
//    [request setValue:@"xxx" forHTTPHeaderField:@"xxx"];
//    [request setValue:@"yyy" forHTTPHeaderField:@"yyy"];
    return  request;
}

#pragma mark - Getter

- (AFHTTPRequestSerializer *)requestSerialize {
    if (!_requestSerialize) {
        _requestSerialize = [AFHTTPRequestSerializer serializer];
    }
    return _requestSerialize;
}

@end
