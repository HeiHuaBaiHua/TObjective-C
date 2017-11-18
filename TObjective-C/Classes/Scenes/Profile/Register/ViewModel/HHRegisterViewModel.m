//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <MSWeakTimer/MSWeakTimer.h>

#import "HHFoundation.h"

#import "HHRegisterViewModel.h"
#import "HHUserAPIManager.h"
@interface HHRegisterViewModel ()

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *accountError;
@property (nonatomic, strong) RACSignal *validAccountSignal;

@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *passwordError;
@property (nonatomic, strong) RACSignal *validPasswordSignal;

@property (nonatomic, copy) NSString *ensurePassword;
@property (nonatomic, strong) RACSignal *validEnsurePasswordSignal;

@property (nonatomic, copy) NSString *verifyCode;
@property (nonatomic, copy) NSString *verifyCodeError;
@property (nonatomic, strong) RACSignal *validVerifyCodeSignal;

@property (nonatomic, copy) NSString *error;

@property (nonatomic, strong) MSWeakTimer *timer;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, strong) NSString *verifyCodeText;
@property (nonatomic, strong) RACCommand *getVerifyCodeCommand;

@property (nonatomic, strong) RACCommand *submitCommand;

@end

@implementation HHRegisterViewModel

- (instancetype)init {
    if (self = [super init]) {
        self.time = 60;
        self.error = @"";
        self.verifyCodeText = @"验证码";
    }
    return self;
}

- (void)setAccountInput:(RACSignal *)account passwordInput:(RACSignal *)password ensurePasswordInput:(RACSignal *)ensurePassword verifyCodeInput:(RACSignal *)verifyCode {
    
    [self validAcountInput:account];
    [self validPasswordInput:password];
    [self validEnsurePasswordInput:ensurePassword];
    [self validVerifyCodeInput:verifyCode];
    
    [self enableSubmit];
    [self enableGetVerifyCode];
}

- (void)validAcountInput:(RACSignal *)input {
    @weakify(self);
    self.validAccountSignal = [input map:^id(NSString *value) {
        @strongify(self);
        
        self.account = value.length > 11 ? [value substringToIndex:11] : value;
        self.accountError = ![self.account isValidPhoneNum] ? @"手机号格式不正确" : @"";
        return self.account;
    }];
}

- (void)validPasswordInput:(RACSignal *)input {
    @weakify(self);
    self.validPasswordSignal = [input map:^id(NSString *value) {
        @strongify(self);
        
        self.password = value.length > 16 ? [value substringToIndex:16] : value;
        NSPredicate *isValidPassword = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^(?=.*[a-zA-Z0-9].*)(?=.*[a-zA-Z\\W].*)(?=.*[0-9\\W].*).{6,16}$"];
        self.passwordError = ![isValidPassword evaluateWithObject:self.password] ? @"密码格式不正确" : nil;
        return self.password;
    }];
}

- (void)validEnsurePasswordInput:(RACSignal *)input {
    @weakify(self);
    self.validEnsurePasswordSignal = [input map:^id(NSString *value) {
        @strongify(self);
        
        self.ensurePassword = value.length > 16 ? [value substringToIndex:16] : value;
        return self.ensurePassword;
    }];
}

- (void)validVerifyCodeInput:(RACSignal *)input {
    @weakify(self);
    self.validVerifyCodeSignal = [input map:^id(NSString *value) {
        @strongify(self);
        
        self.verifyCode = value.length > 6 ? [value substringToIndex:6] : value;
        NSPredicate *isValidCode = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"\\w+"];
        self.verifyCodeError = ![isValidCode evaluateWithObject:self.verifyCode] ? @"验证码格式不正确" : nil;
        return self.verifyCode;
    }];
}

- (void)enableSubmit {
    
    @weakify(self);
    RACSignal *enableSignal = [RACSignal combineLatest:
  @[self.validAccountSignal, self.validPasswordSignal, self.validEnsurePasswordSignal, self.validVerifyCodeSignal] reduce:^id(NSString *account, NSString *password, NSString *ensurePassword, NSString *verifyCode){
      @strongify(self);

      if (self.accountError.length > 0) {
          self.error = self.accountError;
      } else if (self.passwordError) {
          self.error = self.passwordError;
      } else if (![self.ensurePassword isEqualToString:self.password]) {
          self.error = @"两次输入的密码不一致";
      } else if (self.verifyCodeError) {
          self.error = self.verifyCodeError;
      } else {
          self.error = nil;
      }
      return @(self.error.length == 0);
      
    }];
    self.submitCommand = [[RACCommand alloc] initWithEnabled:enableSignal signalBlock:^RACSignal *(id input) {
        @strongify(self);
        return [self registerSignal];
    }];
}

- (void)enableGetVerifyCode {
    
    RACSignal *enableSignal = [RACSignal combineLatest:
  @[RACObserve(self, time), RACObserve(self, accountError)] reduce:^id(NSNumber *time, NSString *accountError){
        return @(accountError.length == 0 &&
        (time.intValue <= 0 || time.intValue >= 60));
    }];
    @weakify(self);
    self.getVerifyCodeCommand = [[RACCommand alloc] initWithEnabled:enableSignal signalBlock:^RACSignal *(id input) {
        @strongify(self);
        return [self getVerifyCodeSignal];
    }];
}

#pragma mark - Utils

- (RACSignal *)getVerifyCodeSignal{
    @weakify(self);
    return [[[HHUserAPIManager new] getVerifyCodeSignalWithPhoneNumber:self.account] doNext:^(id x) {
        @strongify(self);
        
        [self.timer invalidate];
        self.time = 60;
        self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeDown) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    }];
}

- (RACSignal *)registerSignal {
    @weakify(self);
    return [[[HHUserAPIManager new] registerSignalWithAccount:self.account password:self.password verifyCode:self.verifyCode] doNext:^(id x) {
        @strongify(self);
        
        [self.timer invalidate];
        //注册成功 保存用户信息
    }];
}

- (void)timeDown {
    if (self.time > 0) {
        self.verifyCodeText = [NSString stringWithFormat:@"%zds", self.time];
    } else {
        
        [self.timer invalidate];
        self.verifyCodeText = @"验证码";
    }
    self.time--;
}

@end
        
