//
//  HHWeiboAPIManager.h
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWeibo.h"
#import "HHWeiboComment.h"

#import "HHAPIManager+RAC.h"
@interface HHWeiboAPIManager : HHAPIManager

/** TODO: 最新发布的微博列表 */
- (RACSignal *)publicWeiboListSignalWithPage:(int)page pageSize:(int)pageSize;

/** TODO: 我关注的用户发布的微博列表 */
- (RACSignal *)followedWeiboListSignalWithPage:(int)page pageSize:(int)pageSize;

/** TODO: 某条微博的转发列表 */
- (RACSignal *)weiboRepostListSignalWithWeiboID:(NSString *)ID page:(int)page pageSize:(int)pageSize;

/** TODO: 某条微博的评论列表 */
- (RACSignal *)weiboCommentListSignalWithWeiboID:(NSString *)ID page:(int)page pageSize:(int)pageSize;

/** TODO: 某条微博的点赞列表 */
- (RACSignal *)weiboLikeListSignalWithWeiboID:(NSString *)ID page:(int)page pageSize:(int)pageSize;
@end
