//
//  HHWeiboDetailCell.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/17.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWeiboDetailCell.h"

#import "HHWeiboDetailCellInfoBinder.h"
@interface HHWeiboCell()

@property (nonatomic, strong) HHWeiboCellInfoBinder *infoBinder;

- (void)configuration;

@end

@implementation HHWeiboDetailCell

#pragma mark - Override

- (void)configuration {
    [super configuration];
    
    self.infoBinder = [HHWeiboDetailCellInfoBinder new];
}

@end
