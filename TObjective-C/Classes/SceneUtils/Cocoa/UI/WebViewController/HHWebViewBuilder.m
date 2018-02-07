//
//  HHWebViewBuilder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/10/26.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWebViewBuilder.h"

#import "HHWebViewModel.h"
#import "HHWebViewBinder.h"
@implementation HHWebViewBuilder

+ (id<HHWebViewBinderProtocol>)webViewWithURL:(NSString *)url {
    HHWebViewBinder *binder = [HHWebViewBinder new];
    HHWebViewModel *viewModel = [[HHWebViewModel alloc] initWithURL:url];
    [binder bind:viewModel];
    return binder;
}

+ (id<HHWebViewModelProtocol>)webViewModelWithURL:(NSString *)url {
    return [[HHWebViewModel alloc] initWithURL:url];
}

+ (id<HHWebViewBinderProtocol>)webViewWithViewModel:(id<HHWebViewModelProtocol>)viewModel {
    
    HHWebViewBinder *binder = [HHWebViewBinder new];
    [binder bind:viewModel];
    return binder;
}

@end
