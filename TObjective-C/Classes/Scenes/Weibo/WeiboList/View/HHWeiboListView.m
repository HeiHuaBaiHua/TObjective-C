//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "HHFoundation.h"
#import "HHWeiboListView.h"

@interface HHWeiboListView ()

@property (nonatomic, strong) UIView<HHSegmentViewProtocol> *segmentView;

@property (nonatomic, strong) UITableView *followedWeiboListView;
@property (nonatomic, strong) UITableView *publicWeiboListView;

@end

@implementation HHWeiboListView

- (instancetype)init { return [self initWithFrame:CGRectZero]; }

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self configuration];
        
        [self layoutUI];
    }
    return self;
}

#pragma mark - Utils

- (void)configuration {
    self.backgroundColor = [UIColor whiteColor];
}

- (void)layoutUI {
    [self addSubview:self.segmentView];
    
    [self.segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - Getter

- (UIView<HHSegmentViewProtocol> *)segmentView {
    if (!_segmentView) {
        _segmentView = [HHUIBuilder segmentViewWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - TopBarHeight)];
    }
    return _segmentView;
}

- (UITableView *)followedWeiboListView {
    if (!_followedWeiboListView) {
        _followedWeiboListView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _followedWeiboListView.separatorStyle = UITableViewCellSelectionStyleNone;
        _followedWeiboListView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_followedWeiboListView neverAdjustScrollInsets];
    }
    return _followedWeiboListView;
}

- (UITableView *)publicWeiboListView {
    if (!_publicWeiboListView) {
        _publicWeiboListView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _publicWeiboListView.separatorStyle = UITableViewCellSelectionStyleNone;
        _publicWeiboListView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_publicWeiboListView neverAdjustScrollInsets];
    }
    return _publicWeiboListView;
}

@end

