//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"

#import "HHRegisterView.h"
#import "HHRegisterBinder.h"
#import "HHRegisterViewModelProtocol.h"

@interface HHRegisterBinder ()

@property (nonatomic, strong) HHRegisterView *view;
@property (nonatomic, strong) id<HHRegisterViewModelProtocol> viewModel;

@end

@implementation HHRegisterBinder

- (instancetype)initWithView:(HHRegisterView *)view viewModel:(id)viewModel {
    if (self = [super init]) {
        self.view = view;
        
        [self bindViewModel:viewModel];
    }
    return self;
}

- (void)bindViewModel:(id<HHRegisterViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
    
    [self bind];
}

#pragma mark - Bind

- (void)bind {
    
    [self.viewModel setAccountInput:self.view.accountTF.rac_textSignal passwordInput:self.view.passwordTF.rac_textSignal ensurePasswordInput:self.view.ensurePasswordTF.rac_textSignal verifyCodeInput:self.view.verifyCodeTF.rac_textSignal];
    
    RAC(self.view.accountTF, text) = self.viewModel.validAccountSignal;
    RAC(self.view.passwordTF, text) = self.viewModel.validPasswordSignal;
    RAC(self.view.ensurePasswordTF, text) = self.viewModel.validEnsurePasswordSignal;
    
    RAC(self.view.errorLabel, text) = [RACObserve(self, viewModel.error) skip:1];
    RAC(self.view.verifyCodeTF, text) = self.viewModel.validVerifyCodeSignal;
    RAC(self.view.verifyCodeButton, title) = RACObserve(self, viewModel.verifyCodeText);
    
    self.view.submitButton.rac_command = self.viewModel.submitCommand;
    self.view.verifyCodeButton.rac_command = self.viewModel.getVerifyCodeCommand;
    
    @weakify(self);
    [[RACSignal merge:@[self.viewModel.submitCommand.errors, self.viewModel.getVerifyCodeCommand.errors]] subscribeNext:^(NSError *error) {
        @strongify(self);
        [self.view showToastWithText:error.domain];
    }];
    
    [[self.viewModel.submitCommand.executionSignals switchToLatest] subscribeNext:^(id x) {
        @strongify(self);
        
        [self.view showToastWithText:@"注册成功"];
        [self.view.navigationController popViewControllerAnimated:YES];
    }];
}

@end
        
