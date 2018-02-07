//
//  HHWeiboDetailBuilder.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/6.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"
#import "HHWeiboDetailBuilder.h"

#import "HHWeiboDetailView.h"
#import "HHWeiboDetailViewModel.h"

#import "HHWeiboDetailCell.h"
#import "HHWeiboCellInfoView.h"

#import "HHWeiboDetailLikesBinder.h"
#import "HHWeiboDetailRepostsBinder.h"
#import "HHWeiboDetailCommentsBinder.h"
@implementation HHWeiboDetailBuilder

/** TODO: 微博详情页面 */
+ (UIView<HHWeiboDetailViewProtocol> *)weiboDetailView {
    return [[HHWeiboDetailView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

+ (id<HHWeiboDetailViewModelProtocol>)weiboDetailViewModelWithWeibo:(HHWeibo *)weibo {
    return [[HHWeiboDetailViewModel alloc] initWithObject:weibo];
}

+ (id<HHBinderProtocol>)weiboDetailInfoBinder {
    HHWeiboCellInfoView *view = [HHWeiboCellInfoView IBInstance];
    HHWeiboDetailCellInfoBinder *binder = [[HHWeiboDetailCellInfoBinder alloc] initWithView:view];
    return binder;
}

/** TODO: 微博详情 点赞/转发/评论列表 */
+ (id<HHListBinderProtocol>)weiboLikesBinderWithView:(UITableView *)view {
    return [[HHWeiboDetailLikesBinder alloc] initWithView:view];
}

+ (id<HHListBinderProtocol>)weiboRepostsBinderWithView:(UITableView *)view {
    return [[HHWeiboDetailRepostsBinder alloc] initWithView:view];
}

+ (id<HHListBinderProtocol>)weiboCommentsBinderWithView:(UITableView *)view {
    return [[HHWeiboDetailCommentsBinder alloc] initWithView:view];
}

@end
