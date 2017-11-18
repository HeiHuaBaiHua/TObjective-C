//
//  CTMediator+Web.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "CTMediator+Web.h"

static NSString *const TargetWeb = @"HHTargetWeb";

@implementation CTMediator (Web)

- (void)pushToWebVCWithURL:(NSString *)url title:(NSString *)title {
    if (url.length == 0) { return; }
    
    NSDictionary *params = @{@"url": url,
                             @"title": title ?: @""};
    UIViewController *webVC = [self performTarget:TargetWeb action:@"webVCWithParams:" params:params shouldCacheTarget:NO];
    [self.currentNavVC pushViewController:webVC animated:YES];
}

@end
