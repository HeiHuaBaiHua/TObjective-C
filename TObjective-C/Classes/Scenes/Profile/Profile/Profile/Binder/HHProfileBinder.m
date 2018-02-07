//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHProfileBinder.h"

@interface HHProfileBinder ()

@property (nonatomic, strong) UIView<HHProfileViewProtocol> *view;
@property (nonatomic, strong) id<HHProfileViewModelProtocol> viewModel;

@end

@implementation HHProfileBinder

- (instancetype)initWithView:(UIView<HHProfileViewProtocol> *)view {
    if (self = [super init]) {
        self.view = view;
    }
    return self;
}

- (void)bind:(id<HHProfileViewModelProtocol>)viewModel {
    self.viewModel = viewModel;
    
    [self bind];
}

#pragma mark - Bind

- (void)bind {
    
    
}

@end
        
