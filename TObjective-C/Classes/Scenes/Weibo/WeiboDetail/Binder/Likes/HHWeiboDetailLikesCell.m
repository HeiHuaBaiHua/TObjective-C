//
//  HHWeiboDetailLikesCell.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "ReactiveCocoa.h"

#import "HHWeiboDetailLikesCell.h"

#import "HHWeiboDetailLikesCellViewModelProtocol.h"

@interface HHWeiboDetailLikesCell ()

@property (nonatomic, strong) id<HHListCellViewModelProtocol> viewModel;

@end

@implementation HHWeiboDetailLikesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self configuration];
        
        [self layoutUI];
        
        [self bind];
    }
    return self;
}

- (void)bindViewModel:(id)viewModel {
    self.viewModel = viewModel;
}

- (void)bind {
    
}

#pragma mark - Utils

- (void)configuration {
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutUI {
    
//    [self.contentView addSubview:self.view];
//    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsZero);
//    }];
}

#pragma mark - Getter

//- (UIView<<#Protocol#>> *)view {
//    if (!_view) {
//        _view = [<#View#> new];
//    }
//    return _view;
//}

@end
