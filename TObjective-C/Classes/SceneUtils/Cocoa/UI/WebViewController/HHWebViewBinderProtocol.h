//
//  HHWebViewBinderProtocol.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/10/23.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHWebViewModelProtocol.h"
@protocol HHWebViewBinderProtocol <NSObject>

- (WKWebView *)webView;
- (UIBarButtonItem *)backItem;

- (void)bindViewModel:(id<HHWebViewModelProtocol>)viewModel;

@end
