//
//  HHWeiboDetailCell.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/17.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWeiboDetailBuilder.h"

#import "HHWeiboDetailCell.h"
#import "HHWeiboCellInfoViewModelProtocol.h"

@interface HHWeiboCell()

@property (nonatomic, strong) HHWeiboCellInfoBinder *infoBinder;

- (void)configuration;

@end

@implementation HHWeiboDetailCell

#pragma mark - Override

- (void)configuration {
    [super configuration];
    
    /** 微博详情头部没有点赞/评论/转发按钮 */
    self.infoBinder = [HHWeiboDetailBuilder weiboDetailInfoBinder];
}

@end

#pragma mark - HHWeiboDetailCellInfoBinder

@interface HHWeiboCellInfoBinder ()
- (void)bind:(id)viewModel;
@end

@implementation HHWeiboDetailCellInfoBinder

#pragma mark - Override

- (void)bind:(id<HHWeiboCellInfoViewModelProtocol>)viewModel {
    [super bind:viewModel];
    
    UIView<HHWeiboCellInfoViewProtocol> *view = (UIView<HHWeiboCellInfoViewProtocol> *)self.view;
    view.likeButton.hidden = view.repostButton.hidden = view.commentButton.hidden = YES;
    
    viewModel.contentHeight -= 33;
}

@end
