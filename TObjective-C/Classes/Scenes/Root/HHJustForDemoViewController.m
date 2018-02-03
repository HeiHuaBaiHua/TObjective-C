//
//  HHJustForDemoViewController.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/2.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"

#import "HHAPIManger_JustForDemo.h"
#import "HHJustForDemoViewController.h"

@interface HHJustForDemoViewController ()

@property (nonatomic, copy) void(^onClickHandler)(void);

@end

@implementation HHJustForDemoViewController

+ (instancetype)instanceWithOnClickHandler:(void (^)(void))onClickHandler {
    HHJustForDemoViewController *vc = [HHJustForDemoViewController IBInstance];
    vc.onClickHandler = onClickHandler;
    return vc;
}

- (IBAction)pushToTargetVC:(UIButton *)sender {
    APIType = sender.tag;
    !self.onClickHandler ?: self.onClickHandler();
}

@end
