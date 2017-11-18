//
//  HHWeiboCell.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "HHFoundation.h"

#import "HHWeiboCell.h"
#import "HHWeiboCellInfoBinder.h"
#import "HHWeiboCellContentBinder.h"

#import "HHWeiboCellViewModelProtocol.h"
@interface HHWeiboCell ()

@property (nonatomic, strong) id<HHWeiboCellViewModelProtocol> viewModel;

@property (nonatomic, strong) HHWeiboCellInfoBinder *infoBinder;
@property (nonatomic, strong) HHWeiboCellContentBinder *contentBinder;
@property (nonatomic, strong) HHWeiboCellContentBinder *retweetedWeiboBinder;

@end

@implementation HHWeiboCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self configuration];
        
        [self layoutUI];
    }
    return self;
}

- (void)bindViewModel:(id<HHWeiboCellViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
    
    /** 头像+三个按钮 */
    HH_Bind(self.infoBinder, viewModel.weiboInfoVM);
    
    {/** 微博内容 */
        HH_Bind(self.contentBinder, viewModel.weiboContentVM);
        [self.contentBinder.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(viewModel.weiboContentVM.contentHeight);
        }];
    }
    
    {/** 微博转发内容 */
        self.retweetedWeiboBinder.view.hidden = (viewModel.retweetedWeiboContentVM == nil);
        if (!self.retweetedWeiboBinder.view.isHidden) {
            
            HH_Bind(self.retweetedWeiboBinder, viewModel.retweetedWeiboContentVM);
            [self.retweetedWeiboBinder.view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(viewModel.retweetedWeiboContentVM.contentHeight + Interval);
            }];
        }
    }
}

#pragma mark - Utils

- (void)configuration {
    
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.infoBinder = [HHWeiboCellInfoBinder new];
    self.contentBinder = [HHWeiboCellContentBinder new];
    self.retweetedWeiboBinder = [HHWeiboCellContentBinder new];
}

- (void)layoutUI {
    
    [self.contentView addSubview:self.infoBinder.view];
    [self.contentView addSubview:self.contentBinder.view];
    [self.contentView addSubview:self.retweetedWeiboBinder.view];
    self.retweetedWeiboBinder.view.backgroundColor = [UIColor colorWithHex:0xf5f5f5];
    
    [self.infoBinder.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsZero);
    }];
    
    CGFloat userInfoHeight = 54;
    [self.contentBinder.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(userInfoHeight);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    [self.retweetedWeiboBinder.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentBinder.view.mas_bottom).offset(Interval * 0.5);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
}

@end
