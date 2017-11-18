//
//  HHTargetWeibo.h
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHTargetWeibo : NSObject

- (UIViewController *)weiboListVC;

- (UIViewController *)weiboDetailVCWithPramas:(NSDictionary *)params;
@end
