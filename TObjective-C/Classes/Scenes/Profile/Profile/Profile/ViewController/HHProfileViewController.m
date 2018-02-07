//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"

#import "HHProfileViewController.h"

#import "HHRegisterView.h"
#import "HHRegisterBinder.h"
#import "HHRegisterViewModel.h"
@interface HHProfileViewController ()

//@property (nonatomic, strong) id<HHProfileBinderProtocol> binder;

@property (nonatomic, strong) HHRegisterBinder *binder;

@end

@implementation HHProfileViewController

- (void)loadView {
    
//    self.binder = [HHProfileBuilder <#function#>];
//    self.view = self.binder.view;
    
    self.binder = [[HHRegisterBinder alloc] initWithView:[HHRegisterView IBInstance]];
    HH_Bind(self.binder, [HHRegisterViewModel new]);
    self.view = self.binder.view;
}

@end
        
