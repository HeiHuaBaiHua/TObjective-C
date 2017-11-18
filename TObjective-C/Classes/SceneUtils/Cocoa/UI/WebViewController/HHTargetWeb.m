//
//  HHTargetWeb.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHTargetWeb.h"

#import "HHWebViewController.h"
@implementation HHTargetWeb

- (UIViewController *)webVCWithParams:(NSDictionary *)params {
    NSString *url = params[@"url"];
    if (!url) { return nil; }
    
    UIViewController *webVC = [[HHWebViewController alloc] initWithURL:url];
    webVC.title = params[@"title"];
    return webVC;
}

@end
