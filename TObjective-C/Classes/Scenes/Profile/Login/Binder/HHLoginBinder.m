//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHLoginView.h"
#import "HHLoginBinder.h"
#import "HHLoginViewModelProtocol.h"

@interface HHLoginBinder ()

@property (nonatomic, strong) HHLoginView *view;
@property (nonatomic, strong) id<HHLoginViewModelProtocol> viewModel;

@end

@implementation HHLoginBinder

- (instancetype)initWithView:(HHLoginView *)view {
    if (self = [super init]) {
        self.view = view;
    }
    return self;
}

- (void)bind:(id<HHLoginViewModelProtocol>)viewModel {
    
    self.viewModel = viewModel;
    
    [self bind];
}

#pragma mark - Bind

- (void)bind {
    
    
}

@end
        
