//
//  HHWeiboDetailViewController.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/15.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HHFoundation.h"

#import "HHWeiboDetailBuilder.h"
#import "HHWeiboDetailViewController.h"

@interface HHWeiboDetailViewController ()<UITableViewDelegate, UITableViewDataSource, HHSegmentViewDataSource, HHSegmentViewDelegate>

@property (nonatomic, strong) id<HHWeiboDetailViewModelProtocol> viewModel;

@property (nonatomic, strong) id<HHListBinderProtocol> likesBinder;
@property (nonatomic, strong) id<HHListBinderProtocol> repostsBinder;
@property (nonatomic, strong) id<HHListBinderProtocol> commentsBinder;

@end

@implementation HHWeiboDetailViewController

- (instancetype)initWithWeibo:(HHWeibo *)weibo {
    if (self = [super init]) {
        
        UIView<HHWeiboDetailViewProtocol> *view = [HHWeiboDetailBuilder weiboDetailView];
        
        self.likesBinder = [HHWeiboDetailBuilder weiboLikesBinderWithView:view.likesListView];
        self.repostsBinder = [HHWeiboDetailBuilder weiboRepostsBinderWithView:view.repostsListView];
        self.commentsBinder = [HHWeiboDetailBuilder weiboCommentsBinderWithView:view.commentsListView];
        
        self.view = view;
        self.title = @"TWeiboDetail";
        [self bind:[HHWeiboDetailBuilder weiboDetailViewModelWithWeibo:weibo]];
    }
    return self;
}

- (UIView<HHWeiboDetailViewProtocol> *)myView {
    return (UIView<HHWeiboDetailViewProtocol> *)self.view;
}

#pragma mark - Bind

- (void)bind:(id<HHWeiboDetailViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
    
    HH_Bind(self.likesBinder, viewModel.likesViewModel);
    HH_Bind(self.repostsBinder, viewModel.repostsViewModel);
    HH_Bind(self.commentsBinder, viewModel.commentsViewModel);
    HH_Bind(self.myView.weiboDetailCell, viewModel.weiboDetailCellViewModel);
    
    [self bindListView];
    [self bindSegmentView];
    [self bindScrollResponder];
}

- (void)bindListView {
    
    UITableView *listView = self.myView.mainListView;
    listView.delegate = self;
    listView.dataSource = self;
    
    @weakify(self);
    listView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self.listBinders[self.myView.segmentView.selectedIndex] refreshData];
    }];
    for (id<HHListBinderProtocol> binder in self.listBinders) {
        [binder.viewModel.refreshCommand.executionSignals subscribeNext:^(id x) {
            [listView.mj_header endRefreshing];
        }];
        [binder.viewModel.refreshCommand.errors subscribeNext:^(id x) {
            [listView.mj_header endRefreshing];
        }];
    }
}

- (void)bindSegmentView {
    
    [self.myView.segmentView setDelegate:self];
    [self.myView.segmentView setDataSource:self];
    [self.myView.segmentView setHeaderBackgroundColor:[UIColor purpleColor]];
}

- (void)bindScrollResponder {
    
    @weakify(self);
    [[RACSignal merge:@[RACObserve(self.myView.likesListView, contentOffset),
                        RACObserve(self.myView.repostsListView, contentOffset),
                        RACObserve(self.myView.commentsListView, contentOffset)]] subscribeNext:^(id offset) {
        @strongify(self);
        if (!self.myView.mainListView.isFirstScrollResponder &&
            [offset CGPointValue].y <= 0) {
            
            [self switchScrollResponder:YES];
            self.myView.likesListView.contentOffset = self.myView.repostsListView.contentOffset = self.myView.commentsListView.contentOffset = CGPointZero;
        }/** subListView下滑到了subListView的顶部位置 移交滑动权给mainListView*/
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UITableView *listView = self.myView.mainListView;
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
    return indexPath.section == 0 ? self.myView.weiboDetailCell : self.myView.weiboStatusCell;
}

#pragma mark - Utils

- (NSArray<id<HHListBinderProtocol>> *)listBinders {
    return @[self.repostsBinder, self.commentsBinder, self.likesBinder];
}

- (void)switchScrollResponder:(BOOL)toMainList {
    
    self.myView.mainListView.isFirstScrollResponder = toMainList;
    self.myView.likesListView.isFirstScrollResponder = !toMainList;
    self.myView.repostsListView.isFirstScrollResponder = !toMainList;
    self.myView.commentsListView.isFirstScrollResponder = !toMainList;
}

@end
