//
//  HHWeiboDetailCellInfoBinder.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/17.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWeiboDetailCellInfoBinder.h"

#import "HHWeiboCellInfoView.h"
#import "HHWeiboCellInfoViewModelProtocol.h"
@interface HHWeiboCellInfoBinder ()
- (void)bindViewModel:(id)viewModel;
@end

@implementation HHWeiboDetailCellInfoBinder

#pragma mark - Override

- (void)bindViewModel:(id<HHWeiboCellInfoViewModelProtocol>)viewModel {
    [super bindViewModel:viewModel];
    
    HHWeiboCellInfoView *view = (HHWeiboCellInfoView *)self.view;
    view.likeButton.hidden = view.repostButton.hidden = view.commentButton.hidden = YES;
    
    viewModel.contentHeight -= 33;
}

@end
