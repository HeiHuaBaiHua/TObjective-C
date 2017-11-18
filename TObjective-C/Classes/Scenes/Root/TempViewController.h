//
//  TempViewController.h
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TempViewController : UIViewController

- (instancetype)initWithTitle:(NSString *)title onClickHandler:(void(^)(void))onClickHandler;

@end
