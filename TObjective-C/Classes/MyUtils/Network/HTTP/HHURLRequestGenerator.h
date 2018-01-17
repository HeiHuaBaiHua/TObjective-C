//
//  HHURLRequestGenerator.h
//  HeiHuaBaiHua
//
//  Created by HeiHuaBaiHua on 16/5/31.
//  Copyright © 2016年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHUploadFile.h"
@interface HHURLRequestGenerator : NSObject

+ (instancetype)sharedInstance;

- (NSMutableURLRequest *)generateRequestWithUrlPath:(NSString *)urlPath
                                             method:(NSString *)method
                                             params:(NSDictionary *)params
                                             header:(NSDictionary *)header;

- (NSMutableURLRequest *)generateUploadRequestUrlPath:(NSString *)urlPath
                                               params:(NSDictionary *)params
                                             contents:(NSArray<HHUploadFile *> *)contents
                                               header:(NSDictionary *)header;

@end
