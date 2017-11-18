//
//  HHWeiboDetailRepostsCell.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HHWeiboDetailRepostsCell.h"

#import "HHWeiboDetailRepostsCellViewModelProtocol.h"
@interface HHWeiboDetailRepostsCell ()

@property (nonatomic, strong) id<HHWeiboDetailRepostsCellViewModelProtocol> viewModel;

@end

@implementation HHWeiboDetailRepostsCell

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
    RAC(self.textLabel, text) = RACObserve(self, viewModel.text);
    RAC(self.imageView, image) = RACObserve(self, viewModel.image);
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
