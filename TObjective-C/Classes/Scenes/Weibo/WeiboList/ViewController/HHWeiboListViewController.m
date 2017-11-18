//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//
#import <Masonry/Masonry.h>

#import "HHWeiboListViewController.h"

#import "HHWeiboListView.h"
#import "HHWeiboListBinder.h"
#import "HHWeiboListViewModel.h"

/** 实际开发中 view/ViewModel/binder都是通过Builder生成的 这样使用者只用关注viewProtocol/ViewModelProtocol/binderProtocol或.h的接口声明 而不必关注具体实现 */
@interface HHWeiboListViewController ()
/** 这个HHWeiboListBinder其实就是HHWeiboListViewController本身 */
@property (nonatomic, strong) HHWeiboListBinder *binder;

@end

@implementation HHWeiboListViewController

- (void)loadView {
    
    HHWeiboListView *view = [[HHWeiboListView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    HHWeiboListViewModel *viewModel = [HHWeiboListViewModel new];
    self.binder = [[HHWeiboListBinder alloc] initWithView:view viewModel:viewModel];
    
    self.view = self.binder.view;
    self.title = @"TWeibo";
}

@end
        
