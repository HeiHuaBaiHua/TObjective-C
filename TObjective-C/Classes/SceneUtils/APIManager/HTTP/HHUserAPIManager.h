//
//  HHUserAPIManager.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/17.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHAPIManager+RAC.h"

@interface HHUserAPIManager : HHAPIManager

/** TODO: 获取验证码 */
- (RACSignal *)getVerifyCodeSignalWithPhoneNumber:(NSString *)phoneNumber;

/** TODO: 注册 */
- (RACSignal *)registerSignalWithAccount:(NSString *)account password:(NSString *)password verifyCode:(NSString *)verifyCode;

/** TODO: 登陆 */
- (RACSignal *)loginSignalWithAccount:(NSString *)account password:(NSString *)password;
@end
