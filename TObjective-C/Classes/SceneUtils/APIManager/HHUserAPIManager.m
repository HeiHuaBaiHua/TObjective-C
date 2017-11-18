//
//  HHUserAPIManager.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/17.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHUserAPIManager.h"

@implementation HHUserAPIManager

/** TODO: 获取验证码 */
- (RACSignal *)getVerifyCodeSignalWithPhoneNumber:(NSString *)phoneNumber {
    return arc4random() % 2 ? [RACSignal error:HHError(HHDefaultErrorNotice, 999)] : [RACSignal return:@YES];
}

/** TODO: 注册 */
- (RACSignal *)registerSignalWithAccount:(NSString *)account password:(NSString *)password verifyCode:(NSString *)verifyCode {
    return arc4random() % 2 ? [RACSignal error:HHError(HHDefaultErrorNotice, 999)] : [RACSignal return:@YES];
}

/** TODO: 登陆 */
- (RACSignal *)loginSignalWithAccount:(NSString *)account password:(NSString *)password {
    return [RACSignal return:@YES];
}

@end
