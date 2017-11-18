//
//  HHWeiboCellInfoBinder.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SDWebImage/UIButton+WebCache.h>

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
    
    [RACObserve(self, viewModel.avatarUrl) subscribeNext:^(id x) {
        
        [view.avatarButton sd_setImageWithURL:x forState:UIControlStateNormal placeholderImage:[UIColor colorWithHex:0xe5e5e5].image];
    }];
}

- (void)bindViewModel:(id<HHWeiboCellInfoViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
}

@end
