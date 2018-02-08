//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HHRegisterViewProtocol <NSObject>

- (UITextField *)accountTF;
- (UITextField *)passwordTF;
- (UITextField *)ensurePasswordTF;
- (UITextField *)verifyCodeTF;
- (UIButton *)verifyCodeButton;

- (UILabel *)errorLabel;
- (UIButton *)submitButton;

@end

@interface HHRegisterView : UIView<HHRegisterViewProtocol>



@end
        
