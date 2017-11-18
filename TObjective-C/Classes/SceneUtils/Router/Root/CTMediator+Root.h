//
//  CTMediator+Root.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "CTMediator.h"

@interface CTMediator (Root)

- (UITabBarController *)tabbarViewController;

- (UIViewController *)tempViewControllerWithTitle:(NSString *)title onClickHandler:(void(^)(void))onClickHandler;

@end
