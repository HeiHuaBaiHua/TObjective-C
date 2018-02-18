//
//  HHWebSocketResponse.m
//  TObjective-C
//
//  Created by 黑花白花 on 2018/2/18.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWebSocketResponse.h"

@interface HHWebSocketResponse ()

@property (nonatomic, strong) NSDictionary *responseJson;

@end

@implementation HHWebSocketResponse

+ (instancetype)responseWithData:(id)data {
    if (data == nil) { return nil; }
    if ([data isKindOfClass:[NSString class]]) {
        data = [(NSString *)data dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if (responseJson == nil) { return nil; }
    
    HHWebSocketResponse *response = [HHWebSocketResponse new];
    response.responseJson = responseJson;
    return response;
}

- (HHWebSocketRequestURL)url {
    return [self.responseJson[@"url"] integerValue];
}

- (uint32_t)serNum {
    return [self.responseJson[@"serNum"] intValue];
}

- (NSDictionary *)content {
    return self.responseJson[@"response"];
}

@end
