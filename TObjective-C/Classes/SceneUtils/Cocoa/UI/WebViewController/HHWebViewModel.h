//
//  HHWebViewModel.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/10/23.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHWebViewModelProtocol.h"
@interface HHWebViewModel : NSObject<HHWebViewModelProtocol>

- (instancetype)initWithURL:(NSString *)url;

@end
