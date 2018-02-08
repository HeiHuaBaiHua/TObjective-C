//
//  HHRegisterViewController.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/8.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHProfileBuilder.h"
#import "HHRegisterViewController.h"

@interface HHRegisterViewController ()

@property (nonatomic, strong) id<HHBinderProtocol> binder;

@end

@implementation HHRegisterViewController

- (void)loadView {
    
    self.binder = [HHProfileBuilder registerBinder];
    HH_Bind(self.binder, [HHProfileBuilder registerViewModel]);
    
    self.view = self.binder.view;
    self.title = @"注册";
}

@end
