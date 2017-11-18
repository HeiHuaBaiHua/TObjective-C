//
//  TempViewController.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HHFoundation.h"
#import "TempViewController.h"

@interface TempViewController ()

@end

@implementation TempViewController

- (instancetype)initWithTitle:(NSString *)title onClickHandler:(void (^)(void))onClickHandler {
    if (self = [super init]) {
        self.title = title;
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.view.backgroundColor = [UIColor colorWithHex:0xe5e5e5];
        
        UIButton *button = [self button];
        button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            !onClickHandler ?: onClickHandler();
            return [RACSignal empty];
        }];
        [self.view addSubview:button];
    }
    return self;
}

- (UIButton *)button {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 200, CGRectGetWidth([UIScreen mainScreen].bounds), 100);
    button.title = @"点一下";
    [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    return button;
}

@end
