//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@protocol HHRegisterViewModelProtocol <NSObject>

- (void)setAccountInput:(RACSignal *)account passwordInput:(RACSignal *)password ensurePasswordInput:(RACSignal *)ensurePassword verifyCodeInput:(RACSignal *)verifyCode;

- (RACSignal *)validAccountSignal;
- (RACSignal *)validPasswordSignal;
- (RACSignal *)validEnsurePasswordSignal;
- (RACSignal *)validVerifyCodeSignal;

- (NSString *)error;

- (NSString *)verifyCodeText;
- (RACCommand *)getVerifyCodeCommand;

- (RACCommand *)submitCommand;

@end
        
