//
//  HHWeiboDetailTableBinder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/17.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//
#import <MJRefresh/MJRefresh.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HHFoundation.h"

#import "HHWeiboDetailTableBinder.h"

@interface HHWeiboDetailTableBinder ()

@end

@implementation HHWeiboDetailTableBinder

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UITableView *listView = self.view;
    if (!listView.isFirstScrollResponder ||
        listView.contentOffset.y <= 0) {
        listView.contentOffset = CGPointZero;
    }
    listView.showsVerticalScrollIndicator = listView.isFirstScrollResponder;
}

#pragma mark - Override

- (void)refreshData {
    
    if (self.viewModel.allData.count == 0) {
        [self.view showHUD];
    }
    [self.viewModel.refreshCommand execute:nil];
}

- (void)bindTableHeader {
    
    @weakify(self);
    [[self.viewModel.refreshCommand.executionSignals switchToLatest] subscribeNext:^(id x) {
        @strongify(self);
        
        self.view.errorView.hidden = YES;
        [self.view hideHUD];
        [self.view.mj_footer resetNoMoreData];
        [self.view reloadData];
    }];
    
    [self.viewModel.refreshCommand.errors subscribeNext:^(NSError *error) {
        @strongify(self);
        [self.view hideHUD];
    }];
}

@end
