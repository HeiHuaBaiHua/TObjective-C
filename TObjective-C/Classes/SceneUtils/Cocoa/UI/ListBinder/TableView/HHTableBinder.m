//
//  HHTableBinder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HHTableBinder.h"
#import "UIView+ErrorView.h"
#import "HHNetworkTaskError.h"

@interface HHTableBinder ()

@property (nonatomic, strong) UITableView *view;
@property (nonatomic, strong) id<HHListViewModelProtocol> viewModel;

@end

@implementation HHTableBinder

@synthesize view = _tableView;

- (void)loadView{}

- (instancetype)initWithView:(UITableView *)view viewModel:(id<HHListViewModelProtocol>)viewModel {
    if (self = [super init]) {
        self.view = view;
        [self bindViewModel:viewModel];
    }
    return self;
}

- (void)refreshData {
    [self.view.mj_header beginRefreshing];
}

- (void)becomeFirstListBinder {
    
    self.view.delegate = self;
    self.view.dataSource = self;
    self.view.errorView.hidden = YES;
    if (self.viewModel.allData.count == 0) {
        [self refreshData];
    }
}

#pragma mark - Bind

- (void)bindViewModel:(id<HHListViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
    
    self.view.delegate = self;
    self.view.dataSource = self;
    [self.view registerClass:self.cellClass forCellReuseIdentifier:[self.cellClass description]];
    
    [self bindErrorView];
    [self bindTableHeader];
    [self bindTableFooter];
}

- (void)bindErrorView {
    
    @weakify(self);
    [[self.viewModel.refreshCommand.executionSignals switchToLatest] subscribeNext:^(id x) {
        @strongify(self);
        
        self.view.scrollEnabled = YES;
        self.view.errorView.hidden = YES;
    }];
    
    [self.viewModel.refreshCommand.errors subscribeNext:^(NSError *error) {
        @strongify(self);
        
        if (self.viewModel.allData.count == 0) {
            
            self.view.scrollEnabled = NO;
            self.view.errorView.hidden = NO;
            self.view.errorView.error = error;
            self.view.errorView.errorTextButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
                @strongify(self);
                [self refreshData];
                return [RACSignal empty];
            }];
        }
    }];
}

- (void)bindTableHeader {
    
    @weakify(self);
    self.view.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [[self.viewModel refreshCommand] execute:nil];
    }];
    
    [[self.viewModel.refreshCommand.executionSignals switchToLatest] subscribeNext:^(id x) {
        @strongify(self);
        
        self.view.errorView.hidden = YES;
        [self.view.mj_header endRefreshing];
        [self.view.mj_footer resetNoMoreData];
        [self.view reloadData];
    }];
    
    [self.viewModel.refreshCommand.errors subscribeNext:^(NSError *error) {
        @strongify(self);
        [self.view.mj_header endRefreshing];
    }];
}

- (void)bindTableFooter {
    if (![self.viewModel respondsToSelector:@selector(loadMoreCommand)] ||
        self.viewModel.loadMoreCommand == nil) {
        return;
    }
    
    @weakify(self);
    self.view.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        
        [[self.viewModel.loadMoreCommand execute:nil] subscribeNext:^(id x) {
            
            [self.view.mj_footer endRefreshing];
            [self.view reloadData];
        } error:^(NSError *error) {
            
            if (error.code == HHNetworkTaskErrorNoMoreData) {
                [self.view.mj_footer endRefreshingWithNoMoreData];
            } else {
                [self.view.mj_footer endRefreshing];
            }
        }];
    }];
    
    [self.view.mj_footer endRefreshingWithNoMoreData];
    [RACObserve(self.view, contentSize) subscribeNext:^(NSNumber *contentSize) {
        @strongify(self);
        self.view.mj_footer.hidden = [contentSize CGSizeValue].height < self.view.mj_h;
    }];
}

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)indexInPath:(NSIndexPath *)path {
    return path.row;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.allData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.viewModel.allData[[self indexInPath:indexPath]].cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self.cellClass description]];
    HH_Bind(cell, self.viewModel.allData[[self indexInPath:indexPath]])
    return cell;
}

@end
