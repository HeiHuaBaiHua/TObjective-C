//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//
#import <Masonry/Masonry.h>

#import "HHFoundation.h"

#import "HHWeiboListBuilder.h"
#import "HHWeiboListViewController.h"

@interface HHWeiboListViewController ()<HHSegmentViewDelegate, HHSegmentViewDataSource>

@property (nonatomic, strong) id<HHWeiboListViewModelProtocol> viewModel;

@property (nonatomic, strong) id<HHListBinderProtocol> publicWeiboListBinder;
@property (nonatomic, strong) id<HHListBinderProtocol> followedWeiboListBinder;
@end

@implementation HHWeiboListViewController

- (void)loadView {
    
    UIView<HHWeiboListViewProtocol> *view = [HHWeiboListBuilder weiboListView];
    self.publicWeiboListBinder = [HHWeiboListBuilder publicWeiboListBinderWithView:view.publicWeiboListView];
    self.followedWeiboListBinder = [HHWeiboListBuilder followedWeiboListBinderWithView:view.followedWeiboListView];
    
    self.view = view;
    self.title = @"TWeibo";
    [self bind:[HHWeiboListBuilder weiboListViewModel]];
}

#pragma mark - Bind

- (void)bind:(id<HHWeiboListViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
    
    HH_Bind(self.publicWeiboListBinder, viewModel.publicWeiboListViewModel);
    HH_Bind(self.followedWeiboListBinder, viewModel.followedWeiboListViewModel);
    [self bindSegmentView];
}

- (void)bindSegmentView {
    
    UIView<HHWeiboListViewProtocol> *view = (UIView<HHWeiboListViewProtocol> *)self.view;
    [view.segmentView setDelegate:self];
    [view.segmentView setDataSource:self];
    [view.segmentView setHeaderBackgroundColor:[UIColor colorWithHex:0xf4f4f7]];
}

#pragma mark - SegmentViewDelegate

- (NSUInteger)numberOfItemsInSegmentView:(UIView *)segmentView {
    return self.viewModel.titles.count;
}

- (UIView *)segmentView:(UIView *)segmentView itemViewAtIndex:(NSUInteger)index {
    
    switch (index) {
        case 0: return self.followedWeiboListBinder.view;
        case 1: return self.publicWeiboListBinder.view;
    }
    return nil;
}

- (NSString *)segmentView:(UIView *)segmentView titleForItemAtIndex:(NSUInteger)index {
    return self.viewModel.titles[index];
}

- (NSDictionary *)segmentView:(UIView *)segmentView attributesForTitleAtIndex:(NSUInteger)index selected:(BOOL)selected {
    return [self.viewModel titleAttributes:selected];
}

- (void)segmentView:(UIView *)segmentView didScrollToItemAtIndex:(NSUInteger)index {
    
    switch (index) {
        case 0: { [self.followedWeiboListBinder becomeFirstListBinder]; }   break;
        case 1: { [self.publicWeiboListBinder becomeFirstListBinder]; }   break;
    }
}


@end
        
