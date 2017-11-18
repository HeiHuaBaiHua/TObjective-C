//
//  HHWeiboDetailView.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/15.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "HHWeiboDetailView.h"

@interface HHWeiboDetailView ()

@property (nonatomic, strong) UITableView *mainListView;
@property (nonatomic, strong) HHWeiboCell *weiboDetailCell;

@property (nonatomic, strong) UITableViewCell *weiboStatusCell;
@property (nonatomic, strong) UIView<HHSegmentViewProtocol> *segmentView;
@property (nonatomic, strong) UITableView *repostsListView;
@property (nonatomic, strong) UITableView *commentsListView;
@property (nonatomic, strong) UITableView *likesListView;

@property (nonatomic, strong) UIButton *repostButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *likeButton;

@end

@implementation HHWeiboDetailView

- (instancetype)init { return [self initWithFrame:CGRectZero]; }
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self layoutUI];
        [self configuration];
    }
    return self;
}

- (void)configuration {
    self.backgroundColor = [UIColor whiteColor];
}

- (void)layoutUI {
    
    [self addSubview:self.mainListView];
    [self addSubview:self.repostButton];
    [self addSubview:self.commentButton];
    [self addSubview:self.likeButton];
    
    [self.weiboStatusCell addSubview:self.segmentView];
    
    CGFloat statusButtonHeight = 33;
    [self.mainListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 0, statusButtonHeight, 0));
    }];

    [self.segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.weiboStatusCell).insets(UIEdgeInsetsZero);
    }];
    
    [self.repostButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.333);
        make.height.mas_equalTo(statusButtonHeight);
    }];
    
    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.centerX.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.333);
        make.height.mas_equalTo(statusButtonHeight);
    }];
    
    [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.333);
        make.height.mas_equalTo(statusButtonHeight);
    }];
    
    void (^addLineView)(void(^)(MASConstraintMaker *)) = ^(void(^block)(MASConstraintMaker *) ){
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [UIColor colorWithHex:0xe5e5e5];
        [self addSubview:lineView];
        [lineView mas_makeConstraints:block];
    };
    
    addLineView(^(MASConstraintMaker *make) {
        make.top.equalTo(self.commentButton);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(1);
    });
    
    addLineView(^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self.commentButton);
        make.size.mas_equalTo(CGSizeMake(0.5, 20));
    });
    
    addLineView(^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(self.commentButton);
        make.size.mas_equalTo(CGSizeMake(0.5, 20));
    });
}

#pragma mark - Getter

- (UITableView *)mainListView {
    if (!_mainListView) {
        _mainListView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _mainListView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _mainListView.gestureChoiceHandler = ^BOOL(id _, id __) { return YES; };
        [_mainListView neverAdjustScrollInsets];
    }
    return _mainListView;
}

- (HHWeiboCell *)weiboDetailCell {
    if (!_weiboDetailCell) {
        _weiboDetailCell = [[HHWeiboDetailCell alloc] initWithStyle:0 reuseIdentifier:@"weiboDetailCell"];
    }
    return _weiboDetailCell;
}

- (UITableViewCell *)weiboStatusCell {
    if (!_weiboStatusCell) {
        _weiboStatusCell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:@"weiboStatusCell"];
        _weiboStatusCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return _weiboStatusCell;
}

- (UITableView *)repostsListView {
    if (!_repostsListView) {
        _repostsListView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _repostsListView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _repostsListView.isFirstScrollResponder = NO;
        [_repostsListView neverAdjustScrollInsets];
    }
    return _repostsListView;
}

- (UITableView *)commentsListView {
    if (!_commentsListView) {
        _commentsListView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _commentsListView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _commentsListView.isFirstScrollResponder = NO;
        [_commentsListView neverAdjustScrollInsets];
    }
    return _commentsListView;
}

- (UITableView *)likesListView {
    if (!_likesListView) {
        _likesListView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _likesListView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _likesListView.isFirstScrollResponder = NO;
        [_likesListView neverAdjustScrollInsets];
    }
    return _likesListView;
}

- (UIView<HHSegmentViewProtocol> *)segmentView {
    if (!_segmentView) {
        _segmentView = [HHUIBuilder segmentViewWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenMinusTopHeight)];
    }
    return _segmentView;
}

- (UIButton *)repostButton {
    if (!_repostButton) {
        _repostButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _repostButton.titleLabel.font = [UIFont fontOfCode:3];
        _repostButton.backgroundColor = [UIColor whiteColor];
        _repostButton.image = @"weibo_forward".image;
        _repostButton.title = @"转发";
        [_repostButton setTitleColor:[UIColor colorWithHex:0x888888] forState:UIControlStateNormal];
    }
    return _repostButton;
}

- (UIButton *)commentButton {
    if (!_commentButton) {
        _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _commentButton.titleLabel.font = [UIFont fontOfCode:3];
        _commentButton.backgroundColor = [UIColor whiteColor];
        _commentButton.image = @"weibo_comment".image;
        _commentButton.title = @"评论";
        [_commentButton setTitleColor:[UIColor colorWithHex:0x888888] forState:UIControlStateNormal];
    }
    return _commentButton;
}

- (UIButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.titleLabel.font = [UIFont fontOfCode:3];
        _likeButton.backgroundColor = [UIColor whiteColor];
        _likeButton.image = @"weibo_like".image;
        _likeButton.title = @"赞";
        [_likeButton setTitleColor:[UIColor colorWithHex:0x888888] forState:UIControlStateNormal];
    }
    return _likeButton;
}

@end
