//
//  HHWeiboDetailBinder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HHWeiboDetailBinder.h"

#import "HHWeiboDetailLikesBinder.h"
#import "HHWeiboDetailRepostsBinder.h"
#import "HHWeiboDetailCommentsBinder.h"
@interface HHWeiboDetailBinder ()<UITableViewDelegate, UITableViewDataSource, HHSegmentViewDataSource, HHSegmentViewDelegate>

@property (nonatomic, strong) UIView<HHWeiboDetailViewProtocol> *view;
@property (nonatomic, strong) id<HHWeiboDetailViewModelProtocol> viewModel;

@property (nonatomic, strong) HHTableBinder *likesBinder;
@property (nonatomic, strong) HHTableBinder *repostsBinder;
@property (nonatomic, strong) HHTableBinder *commentsBinder;

@end

@implementation HHWeiboDetailBinder

- (instancetype)initWithView:(UIView<HHWeiboDetailViewProtocol> *)view viewModel:(id<HHWeiboDetailViewModelProtocol>)viewModel {
    if (self = [super init]) {
        self.view = view;
        
        self.likesBinder = [[HHWeiboDetailLikesBinder alloc] initWithView:view.likesListView viewModel:viewModel.likesViewModel];
        self.repostsBinder = [[HHWeiboDetailRepostsBinder alloc] initWithView:view.repostsListView viewModel:viewModel.repostsViewModel];
        self.commentsBinder = [[HHWeiboDetailCommentsBinder alloc] initWithView:view.commentsListView viewModel:viewModel.commentsViewModel];
        
        [self bindViewModel:viewModel];
    }
    return self;
}

- (void)bindViewModel:(id<HHWeiboDetailViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
    
    [self bindListView];
    [self bindSegmentView];
    [self bindScrollResponder];
}

#pragma mark - Bind

- (void)bindListView {
    
    UITableView *listView = self.view.mainListView;
    listView.delegate = self;
    listView.dataSource = self;
    /** 头部Cell */
    HH_Bind(self.view.weiboDetailCell, self.viewModel.weiboDetailCellViewModel);
    
    @weakify(self);
    listView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self.listBinders[self.view.segmentView.selectedIndex] refreshData];
    }];
    for (HHTableBinder *binder in self.listBinders) {
        
        HHViewModel listViewModel = binder.viewModel;
        [listViewModel.refreshCommand.executionSignals subscribeNext:^(id x) {
            [listView.mj_header endRefreshing];
        }];
        [listViewModel.refreshCommand.errors subscribeNext:^(id x) {
            [listView.mj_header endRefreshing];
        }];
    }
}

- (void)bindSegmentView {
    
    [self.view.segmentView setDelegate:self];
    [self.view.segmentView setDataSource:self];
    [self.view.segmentView setHeaderBackgroundColor:[UIColor purpleColor]];
}

- (void)bindScrollResponder {

    @weakify(self);
    [[RACSignal merge:@[RACObserve(self.view.likesListView, contentOffset),
                        RACObserve(self.view.repostsListView, contentOffset),
                        RACObserve(self.view.commentsListView, contentOffset)]] subscribeNext:^(id offset) {
        @strongify(self);
        if (!self.view.mainListView.isFirstScrollResponder &&
            [offset CGPointValue].y <= 0) {
            
            [self switchScrollResponder:YES];
            self.view.likesListView.contentOffset = self.view.repostsListView.contentOffset = self.view.commentsListView.contentOffset = CGPointZero;
        }/** subListView下滑到了subListView的顶部位置 移交滑动权给mainListView*/
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    UITableView *listView = self.view.mainListView;
    CGFloat weiboStatusCellTop = [listView rectForSection:1].origin.y;
    if (listView.contentOffset.y >= weiboStatusCellTop &&
        listView.isFirstScrollResponder) {
        [self switchScrollResponder:NO];
    }/** mainListView上滑到了subListView的顶部位置 移交滑动权给subListView*/
    
    if (listView.contentOffset.y >= weiboStatusCellTop ||
        !listView.isFirstScrollResponder) {
        listView.contentOffset = CGPointMake(0, weiboStatusCellTop);
    }
    listView.showsVerticalScrollIndicator = listView.isFirstScrollResponder;
}

#pragma mark - SegmentViewDelegate

- (NSUInteger)numberOfItemsInSegmentView:(UIView *)segmentView {
    return self.viewModel.titles.count;
}

- (NSString *)segmentView:(UIView *)segmentView titleForItemAtIndex:(NSUInteger)index {
    return self.viewModel.titles[index];
}

- (NSDictionary *)segmentView:(UIView *)segmentView attributesForTitleAtIndex:(NSUInteger)index selected:(BOOL)selected {
    return [self.viewModel titleAttributes:selected];
}

- (UIView *)segmentView:(UIView *)segmentView itemViewAtIndex:(NSUInteger)index {
    return self.listBinders[index].view;
}

- (void)segmentView:(UIView *)segmentView didScrollToItemAtIndex:(NSUInteger)index {
    [self.listBinders[index] becomeFirstListBinder];
}

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? self.viewModel.weiboDetailCellViewModel.cellHeight : ScreenMinusTopHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? self.view.weiboDetailCell : self.view.weiboStatusCell;
}

#pragma mark - Utils

- (NSArray<HHTableBinder *> *)listBinders {
    return @[self.repostsBinder, self.commentsBinder, self.likesBinder];
}

- (void)switchScrollResponder:(BOOL)toMainList {
    
    self.view.mainListView.isFirstScrollResponder = toMainList;
    self.view.likesListView.isFirstScrollResponder = !toMainList;
    self.view.repostsListView.isFirstScrollResponder = !toMainList;
    self.view.commentsListView.isFirstScrollResponder = !toMainList;
}

@end
