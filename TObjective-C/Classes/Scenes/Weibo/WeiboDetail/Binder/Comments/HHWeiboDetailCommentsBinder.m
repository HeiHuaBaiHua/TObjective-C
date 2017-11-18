//
//  HHWeiboDetailCommentsBinder.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HHWeiboDetailCommentsBinder.h"

#import "HHFoundation.h"
#import "HHWeiboDetailCommentsCell.h"
@interface HHWeiboDetailCommentsBinder ()

@end

@implementation HHWeiboDetailCommentsBinder

- (Class)cellClass {
    return [HHWeiboDetailCommentsCell class];
}

@end
