//
//  HHNavigationController.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/9/7.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//


#import "HHFoundation.h"
#import "HHNavigationController.h"

@interface HHNavigationController ()

@end

@implementation HHNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].translucent = NO;
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    UIImage *backgroundImage = [UIColor colorWithHex:0x2f2e3d].image;
    [[UINavigationBar appearance] setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    UIImage *backItemImage = @"UI_backIcon".image;
    [UINavigationBar appearance].backIndicatorImage = backItemImage;
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = backItemImage;
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]} forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor clearColor]} forState:UIControlStateHighlighted];
}


@end



