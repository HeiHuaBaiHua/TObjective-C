//
//  HHWebViewBuilder.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/10/26.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHWebViewModelProtocol.h"
#import "HHWebViewBinderProtocol.h"
@interface HHWebViewBuilder : NSObject

+ (id<HHWebViewBinderProtocol>)webViewWithURL:(NSString *)url;

+ (id<HHWebViewModelProtocol>)webViewModelWithURL:(NSString *)url;
+ (id<HHWebViewBinderProtocol>)webViewWithViewModel:(id<HHWebViewModelProtocol>)viewModel;
@end

