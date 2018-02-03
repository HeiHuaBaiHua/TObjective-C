//
//  HHJustForDemoViewController.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/2.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHJustForDemoViewController : UIViewController

+ (instancetype)instanceWithOnClickHandler:(void(^)(void))onClickHandler;

@end
