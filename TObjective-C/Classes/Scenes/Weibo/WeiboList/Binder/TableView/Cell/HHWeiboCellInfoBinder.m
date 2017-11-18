//
//  HHWeiboCellInfoBinder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "ReactiveCocoa.h"
#import "UIButton+WebCache.h"

#import "HHFoundation.h"

#import "HHWeiboCellInfoView.h"
#import "HHWeiboCellInfoBinder.h"
#import "HHWeiboCellInfoViewModelProtocol.h"

@interface HHWeiboCellInfoBinder ()

@property (nonatomic, strong) id<HHWeiboCellInfoViewModelProtocol> viewModel;

@end

@implementation HHWeiboCellInfoBinder

- (void)loadView {
    self.view = [HHWeiboCellInfoView IBInstance];
    
    HHWeiboCellInfoView *view = (HHWeiboCellInfoView *)self.view;
    RAC(view.nameLabel, text) = RACObserve(self, viewModel.name);
    RAC(view.sendDateLabel, text) = RACObserve(self, viewModel.createDate);
    RAC(view.likeButton, title) = RACObserve(self, viewModel.likesCount);
    RAC(view.repostButton, title) = RACObserve(self, viewModel.repostsCount);
    RAC(view.commentButton, title) = RACObserve(self, viewModel.commentsCount);
    RAC(view.likeButton, selected) = [RACObserve(self, viewModel.isLiked) ignore:nil];
    
    [RACObserve(self, viewModel.avatarUrl) subscribeNext:^(id x) {
        
        [view.avatarButton sd_setImageWithURL:x forState:UIControlStateNormal placeholderImage:[UIColor colorWithHex:0xe5e5e5].image];
    }];
    
    [view.likeButton addTarget:self action:@selector(onClickLikeButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindViewModel:(id<HHWeiboCellInfoViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
}

#pragma mark - Action

- (void)onClickLikeButton:(UIButton *)likeButton {
    if (!self.viewModel.isLiked) {
        
        UIImageView *likeIV = [[UIImageView alloc] initWithImage:@"weibo_like_selected".image];
        likeIV.center = likeButton.center;
        [self.view.superview addSubview:likeIV];
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        positionAnimation.toValue = @(likeIV.centerY - 30);
        
        CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.values = @[@(0.1),@(1.0),@(1.5)];
        scaleAnimation.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];

        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[positionAnimation, scaleAnimation];
        animationGroup.duration = 0.5;
        [likeIV.layer addAnimation:animationGroup forKey:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [likeIV removeFromSuperview];
        });
    }
    
    [[self.viewModel.likeCommand execute:nil] subscribeError:^(NSError *error) {
        [likeButton showToastWithText:error.domain];
    }];
}

@end
