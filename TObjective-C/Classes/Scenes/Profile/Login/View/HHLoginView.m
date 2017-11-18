//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"

#import "HHLoginView.h"

@implementation HHLoginView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.submitButton.backgroundImage = [UIColor colorWithHex:0xF14B5E].image;
    self.submitButton.disabledBackgroundImage = [UIColor colorWithHex:0xcccccc].image;
}

@end
        
