//
//  HHWeiboCellViewModelProtocol.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHListBinderProtocol.h"
#import "HHWeiboCellInfoViewModelProtocol.h"
#import "HHWeiboCellContentViewModelProtocol.h"
@protocol HHWeiboCellViewModelProtocol <HHListCellViewModelProtocol>

- (id<HHWeiboCellInfoViewModelProtocol>)weiboInfoVM;
- (id<HHWeiboCellContentViewModelProtocol>)weiboContentVM;
- (id<HHWeiboCellContentViewModelProtocol>)retweetedWeiboContentVM;

@end
