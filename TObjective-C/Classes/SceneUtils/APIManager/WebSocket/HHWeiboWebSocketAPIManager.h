//
//  HHWeiboWebSocketAPIManager.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/3.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWebSocketAPIManager.h"

#import "HHWeibo.h"
#import "HHWeiboComment.h"

#import "HHWebSocketAPIManager+RAC.h"
@interface HHWeiboWebSocketAPIManager : HHWebSocketAPIManager

/** TODO: 最新发布的微博列表 */
- (RACSignal *)publicWeiboListSignalWithPage:(int)page pageSize:(int)pageSize;

/** TODO: 我关注的用户发布的微博列表 */
- (RACSignal *)followedWeiboListSignalWithPage:(int)page pageSize:(int)pageSize;

/** TODO: 给某条微博点赞/取消赞 */
- (RACSignal *)switchLikeStatusSignalWithWeiboID:(NSString *)ID isLike:(BOOL)isLike;

@end
