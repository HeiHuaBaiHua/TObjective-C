//
//  HHBinder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "ReactiveCocoa.h"

#import "HHBinder.h"
#import "UIView+ErrorView.h"

@interface HHBinder ()

@property (nonatomic, strong) HHViewModel viewModel;

@end

@implementation HHBinder

- (void)loadView{}

- (instancetype)initWithView:(UIView *)view viewModel:(HHViewModel)viewModel {
    if (self = [super init]) {
        
        self.view = view;
        [self bindViewModel:viewModel];
    }
    return self;
}

- (void)bindViewModel:(HHViewModel)viewModel {
    self.viewModel = viewModel;
    
    [self bindErrorView];
}

- (void)bindErrorView {
    @weakify(self);
    [[self.viewModel.refreshCommand.executionSignals switchToLatest] subscribeNext:^(id x) {
        @strongify(self);
        self.view.errorView.hidden = YES;
    }];
    
    [self.viewModel.refreshCommand.errors subscribeNext:^(NSError *error) {
        @strongify(self);
        
        if (self.viewModel.rawValue == nil) {
            
            self.view.errorView.hidden = NO;
            self.view.errorView.error = error;
        }
    }];
}

- (void)refreshData {
    [self.viewModel.refreshCommand execute:nil];
}

@end
