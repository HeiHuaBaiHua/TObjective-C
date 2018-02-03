//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"

#import "HHWeiboListBinder.h"
#import "HHWeiboTableBinder.h"
@interface HHWeiboListBinder ()<HHSegmentViewDelegate, HHSegmentViewDataSource>

@property (nonatomic, strong) UIView<HHWeiboListViewProtocol> *view;
@property (nonatomic, strong) id<HHWeiboListViewModelProtocol> viewModel;

@property (nonatomic, strong) HHWeiboTableBinder *followedWeiboListBinder;
@property (nonatomic, strong) HHWeiboTableBinder *publicWeiboListBinder;
@end

@implementation HHWeiboListBinder

- (instancetype)initWithView:(UIView<HHWeiboListViewProtocol> *)view viewModel:(id<HHWeiboListViewModelProtocol>)viewModel {
    if (self = [super init]) {
        self.view = view;
        
        self.followedWeiboListBinder = [[HHWeiboTableBinder alloc] initWithView:view.followedWeiboListView viewModel:viewModel.followedWeiboListViewModel];
        self.publicWeiboListBinder = [[HHWeiboTableBinder alloc] initWithView:view.publicWeiboListView viewModel:viewModel.publicWeiboListViewModel];
        
        [self bindViewModel:viewModel];
    }
    return self;
}

- (void)bindViewModel:(id<HHWeiboListViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
    
    [self bindSegmentView];
}

#pragma mark - Bind

- (void)bindSegmentView {
    
    [self.view.segmentView setDelegate:self];
    [self.view.segmentView setDataSource:self];
    [self.view.segmentView setHeaderBackgroundColor:[UIColor colorWithHex:0xf4f4f7]];
}

#pragma mark - SegmentViewDelegate

- (NSUInteger)numberOfItemsInSegmentView:(UIView *)segmentView {
    return self.viewModel.titles.count;
}

- (UIView *)segmentView:(UIView *)segmentView itemViewAtIndex:(NSUInteger)index {
    switch (index) {
        case 0: return self.view.followedWeiboListView;
        case 1: return self.view.publicWeiboListView;
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
        
