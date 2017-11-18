//
//  HHWeiboDetailViewController.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/15.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HHFoundation.h"

#import "HHWeiboDetailView.h"
#import "HHWeiboDetailBinder.h"
#import "HHWeiboDetailViewModel.h"

#import "HHWeiboDetailViewController.h"

/** 实际开发中 view/ViewModel/binder都是通过Builder生成的 这样使用者只用关注viewProtocol/ViewModelProtocol/binderProtocol或.h的接口声明 而不必关注具体实现 */
@interface HHWeiboDetailViewController ()
/** 这个HHWeiboDetailBinder其实就是HHWeiboDetailViewController本身 */
@property (nonatomic, strong) HHWeiboDetailBinder *binder;

@end

@implementation HHWeiboDetailViewController

- (instancetype)initWithWeibo:(HHWeibo *)weibo {
    if (self = [super init]) {
        
        HHWeiboDetailView *view = [[HHWeiboDetailView alloc] initWithFrame:ScreenBounds];
        HHWeiboDetailViewModel *viewModel = [[HHWeiboDetailViewModel alloc] initWithObject:weibo];
        self.binder = [[HHWeiboDetailBinder alloc] initWithView:view viewModel:viewModel];
        
        self.view = self.binder.view;
        self.title = @"TWeiboDetail";
    }
    return self;
}

@end
