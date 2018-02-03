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

@interface HHWeiboListViewController ()

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
        
