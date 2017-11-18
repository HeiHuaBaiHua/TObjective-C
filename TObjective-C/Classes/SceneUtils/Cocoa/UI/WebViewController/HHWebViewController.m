//
//  HHWebViewController.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/10/26.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//
#import <Masonry/Masonry.h>

#import "HHWebViewBuilder.h"
#import "HHWebViewController.h"
@interface HHWebViewController ()

@property (nonatomic, strong) id<HHWebViewBinderProtocol> binder;

@end

@implementation HHWebViewController

- (instancetype)initWithURL:(NSString *)url {
    if (self = [super init]) {
        
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.binder = [HHWebViewBuilder webViewWithURL:url];
        
        self.navigationItem.leftBarButtonItem = self.binder.backItem;
        [self.view addSubview:self.binder.webView];
        [self.binder.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsZero);
        }];
    }
    return self;
}

@end
