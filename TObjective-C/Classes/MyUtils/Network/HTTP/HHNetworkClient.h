//
//  HHNetworkClient.h
//  HeiHuaBaiHua
//
//  Created by HeiHuaBaiHua on 16/5/31.
//  Copyright © 2016年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHUploadFile.h"
#import "HHNetworkConfig.h"

@interface HHNetworkClient : NSObject

+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)dataTaskWithUrlPath:(NSString *)urlPath
                                     useHttps:(BOOL)useHttps
                                  requestType:(HHNetworkRequestType)requestType
                                       params:(NSDictionary *)params
                                       header:(NSDictionary *)header
                            completionHandler:(void (^)(NSURLResponse *response,id responseObject,NSError *error))completionHandler;

- (NSNumber *)dispatchTaskWithUrlPath:(NSString *)urlPath
                             useHttps:(BOOL)useHttps
                          requestType:(HHNetworkRequestType)requestType
                               params:(NSDictionary *)params
                               header:(NSDictionary *)header
                    completionHandler:(void (^)(NSURLResponse *response,id responseObject,NSError *error))completionHandler;

- (NSNumber *)dispatchTask:(NSURLSessionTask *)task;

- (NSNumber *)uploadDataWithUrlPath:(NSString *)urlPath
                           useHttps:(BOOL)useHttps
                             params:(NSDictionary *)params
                           contents:(NSArray<HHUploadFile *> *)contents
                             header:(NSDictionary *)header
                    progressHandler:(void(^)(NSProgress *))progressHandler
                  completionHandler:(void (^)(NSURLResponse *response,id responseObject,NSError *error))completionHandler;

- (void)cancelAllTask;
- (void)cancelTaskWithTaskIdentifier:(NSNumber *)taskIdentifier;

@end
