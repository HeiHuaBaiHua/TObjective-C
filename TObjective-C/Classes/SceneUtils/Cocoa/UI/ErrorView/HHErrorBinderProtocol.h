//
//  HHErrorBinderProtocol.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/9/26.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HHErrorBinderProtocol <NSObject>

- (void)setError:(NSError *)error;

- (UIButton *)errorTextButton;
- (UIImageView *)errorImageView;

@end
