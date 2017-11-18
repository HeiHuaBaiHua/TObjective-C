//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"

#import "HHRegisterView.h"

@implementation HHRegisterView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.submitButton.backgroundImage = [UIColor colorWithHex:0xF14B5E].image;
    self.verifyCodeButton.backgroundImage = [UIColor colorWithHex:0xF14B5E].image;
    self.submitButton.disabledBackgroundImage = [UIColor colorWithHex:0xcccccc].image;
    self.verifyCodeButton.disabledBackgroundImage = [UIColor colorWithHex:0xcccccc].image;
}

@end
        
