//
//  HHTabBarViewController.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHUIBuilder.h"
#import "HHFoundation.h"
#import "HHTabBarViewController.h"

#import "CTMediator+Web.h"
#import "CTMediator+Chat.h"
#import "CTMediator+Root.h"
#import "CTMediator+Music.h"
#import "CTMediator+Weibo.h"
#import "CTMediator+Compose.h"
#import "CTMediator+Profile.h"

#import "HHWeiboTCPAPIManager.h"
@interface HHTabBarViewController ()

@end

@implementation HHTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
    [self configuration];
}

- (void)layoutUI {
    
    void(^configTabBarItem)(UITabBarItem *, NSArray *) = ^(UITabBarItem *item, NSArray<NSString *> *config) {
        
        item.title = config.firstObject;
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateNormal];
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateSelected];
        
        item.image = [config[1].image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [config[2].image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    };
    
    UINavigationController *weiboNavVC = [HHUIBuilder navigationControllerWithRootVC:[CTRouter tempViewControllerWithTitle:@"WeiBo" onClickHandler:^{
        [CTRouter pushToWeiboListVC];
    }]];
    
    UINavigationController *chatNavVC = [HHUIBuilder navigationControllerWithRootVC:[CTRouter tempViewControllerWithTitle:@"Chat" onClickHandler:^{
        [self showToastWithText:@"留个坑 明天写"];
        
        [[[HHWeiboTCPAPIManager new] publicWeiboListSignalWithPage:0 pageSize:20] subscribeNext:^(id x) {
            NSLog(@"xxx: %@", x);
        } error:^(NSError *error) {
            NSLog(@"xxx: %@", error);
        }];
    }]];
    
    UINavigationController *composeNavVC = [HHUIBuilder navigationControllerWithRootVC:[CTRouter tempViewControllerWithTitle:@"Compose" onClickHandler:^{
        [self showToastWithText:@"留个坑 明天写"];
    }]];
    
    UINavigationController *musicNavVC = [HHUIBuilder navigationControllerWithRootVC:[CTRouter tempViewControllerWithTitle:@"Music" onClickHandler:^{
        [self showToastWithText:@"留个坑 明天写"];
    }]];
    
    UINavigationController *profileNavVC = [HHUIBuilder navigationControllerWithRootVC:[CTRouter tempViewControllerWithTitle:@"Profile" onClickHandler:^{
        [CTRouter pushToProfileVC];
    }]];
    self.viewControllers = @[weiboNavVC, chatNavVC, composeNavVC, musicNavVC, profileNavVC];
    
    NSArray *itemConfig = @[@[@"微博", @"tabbar_home", @"tabbar_home_selected"],
                            @[@"消息", @"tabbar_message_center",  @"tabbar_message_center_selected"],
                            @[@"", @"tabbar_compose_background_icon_add",  @"tabbar_compose_background_icon_add"],
                            @[@"音乐", @"tabbar_discover", @"tabbar_discover_selected"],
                            @[@"我", @"tabbar_profile", @"tabbar_profile_selected"]];
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UINavigationController * _Nonnull navVC, NSUInteger idx, BOOL * _Nonnull stop) {
        
        navVC.navigationBar.translucent = NO;
        configTabBarItem(navVC.tabBarItem, itemConfig[idx]);
    }];
}

- (void)configuration {
    
    self.selectedIndex = 0;
    self.tabBar.translucent = NO;
}
@end
