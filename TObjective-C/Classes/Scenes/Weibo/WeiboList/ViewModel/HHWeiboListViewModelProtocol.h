//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHListBinderProtocol.h"

@class RACCommand;
@protocol HHWeiboListViewModelProtocol <NSObject>

- (NSArray *)titles;
- (NSDictionary *)titleAttributes:(BOOL)selected;

- (id<HHListViewModelProtocol>)publicWeiboListViewModel;
- (id<HHListViewModelProtocol>)followedWeiboListViewModel;
@end
        
