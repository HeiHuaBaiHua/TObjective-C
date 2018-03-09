//
//  HHListViewModel.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"

#import "HHListBinderProtocol.h"
@interface HHListViewModel : NSObject<HHListViewModelProtocol>

- (int)startPage;
- (void)handleResult:(NSArray *)result;
- (RACSignal *)fetchDataSignalWithPage:(int)page;

@end
