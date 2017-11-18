//
//  CTMediator+Weibo.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "CTMediator.h"

@interface CTMediator (Weibo)

- (void)pushToWeiboListVC;

- (void)pushToWeiboDetailVCWithWeiboJson:(NSDictionary *)json;
@end
