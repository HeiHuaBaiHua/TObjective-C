//
//  HHWeiboCellViewProtocol.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/6.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HHWeiboCellViewProtocol <NSObject>
@end

@protocol HHWeiboCellInfoViewProtocol <NSObject>

- (UIButton *)avatarButton;
- (UIImageView *)vipImageView;

- (UILabel *)nameLabel;
- (UIImageView *)hotImageView;
- (UIImageView *)levelImageView;

- (UILabel *)sendDateLabel;

- (UIButton *)likeButton;
- (UIButton *)repostButton;
- (UIButton *)commentButton;

@end

@protocol HHWeiboCellContentViewProtocol <NSObject>

- (UILabel *)textLabel;
- (NSArray<UIButton *> *)imageButtons;

@end
