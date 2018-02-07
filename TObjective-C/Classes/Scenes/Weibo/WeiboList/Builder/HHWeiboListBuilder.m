//
//  HHWeiboListBuilder.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/5.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"

#import "HHWeiboListBuilder.h"

#import "HHWeiboListView.h"
#import "HHWeiboListViewModel.h"

#import "HHWeiboTableBinder.h"
#import "HHWeiboCellInfoView.h"
#import "HHWeiboCellInfoBinder.h"
#import "HHWeiboCellContentView.h"
#import "HHWeiboCellContentBinder.h"

@implementation HHWeiboListBuilder

/** TODO: 微博列表VC */
+ (UIView<HHWeiboListViewProtocol> *)weiboListView {
    return [[HHWeiboListView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

+ (id<HHWeiboListViewModelProtocol>)weiboListViewModel {
    return [HHWeiboListViewModel new];
}

/** TODO: 微博列表TableView */
+ (id<HHListBinderProtocol>)followedWeiboListBinderWithView:(UITableView *)view {
    return [[HHWeiboTableBinder alloc] initWithView:view];
}

+ (id<HHListBinderProtocol>)publicWeiboListBinderWithView:(UITableView *)view {
    return [[HHWeiboTableBinder alloc] initWithView:view];
}

/** TODO: 微博列表Cell */
+ (id<HHBinderProtocol>)weiboInfoBinder {
    HHWeiboCellInfoView *view = [HHWeiboCellInfoView IBInstance];
    HHWeiboCellInfoBinder *binder = [[HHWeiboCellInfoBinder alloc] initWithView:view];
    return binder;
}

+ (id<HHBinderProtocol>)weiboContentBinder {
    HHWeiboCellContentView *view = [[HHWeiboCellContentView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    HHWeiboCellContentBinder *binder = [[HHWeiboCellContentBinder alloc] initWithView:view];
    return binder;
}

@end
