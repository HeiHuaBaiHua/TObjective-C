//
//  HHWeiboListBuilder.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/5.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHBinderProtocol.h"
#import "HHListBinderProtocol.h"

#import "HHWeiboListViewProtocol.h"
#import "HHWeiboListViewModelProtocol.h"

@interface HHWeiboListBuilder : NSObject

/** TODO: 微博列表VC */
+ (UIView<HHWeiboListViewProtocol> *)weiboListView;
+ (id<HHWeiboListViewModelProtocol>)weiboListViewModel;

/** TODO: 微博列表TableView */
+ (id<HHListBinderProtocol>)publicWeiboListBinderWithView:(UITableView *)view;
+ (id<HHListBinderProtocol>)followedWeiboListBinderWithView:(UITableView *)view;

/** TODO: 微博列表Cell */
+ (id<HHBinderProtocol>)weiboInfoBinder;
+ (id<HHBinderProtocol>)weiboContentBinder;
@end
