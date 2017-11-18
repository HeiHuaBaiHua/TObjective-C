//
//  HHWeiboDetailViewModelProtocol.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/15.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHListBinderProtocol.h"

@protocol HHWeiboDetailViewModelProtocol <NSObject>

- (NSArray *)titles;
- (NSDictionary *)titleAttributes:(BOOL)selected;

- (HHListCellViewModel)weiboDetailCellViewModel;
- (id<HHListViewModelProtocol>)likesViewModel;
- (id<HHListViewModelProtocol>)repostsViewModel;
- (id<HHListViewModelProtocol>)commentsViewModel;
@end
