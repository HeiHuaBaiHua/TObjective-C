//
//  HHWeiboDetailViewProtocol.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHFoundation.h"

#import "HHWeiboDetailCell.h"
#import "HHUIBuilder.h"
@protocol HHWeiboDetailViewProtocol <NSObject>

- (UITableView *)mainListView;

- (HHWeiboDetailCell *)weiboDetailCell;

- (UITableViewCell *)weiboStatusCell;
- (UIView<HHSegmentViewProtocol> *)segmentView;
- (UITableView *)repostsListView;
- (UITableView *)commentsListView;
- (UITableView *)likesListView;

- (UIButton *)repostButton;
- (UIButton *)commentButton;
- (UIButton *)likeButton;

@end
