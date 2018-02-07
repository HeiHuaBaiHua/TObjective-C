//
//  HHWeiboDetailBuilder.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/6.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHBinderProtocol.h"
#import "HHListBinderProtocol.h"

#import "HHWeiboDetailViewProtocol.h"
#import "HHWeiboDetailViewModelProtocol.h"

@interface HHWeiboDetailBuilder : NSObject

/** TODO: 微博详情页面 */
+ (UIView<HHWeiboDetailViewProtocol> *)weiboDetailView;
+ (id<HHWeiboDetailViewModelProtocol>)weiboDetailViewModelWithWeibo:(HHWeibo *)weibo;

+ (id<HHBinderProtocol>)weiboDetailInfoBinder;

/** TODO: 微博详情 点赞/转发/评论列表 */
+ (id<HHListBinderProtocol>)weiboLikesBinderWithView:(UITableView *)view;
+ (id<HHListBinderProtocol>)weiboRepostsBinderWithView:(UITableView *)view;
+ (id<HHListBinderProtocol>)weiboCommentsBinderWithView:(UITableView *)view;
@end
