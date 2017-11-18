//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHProfileBinderProtocol.h"
@interface HHProfileBinder : NSObject<HHProfileBinderProtocol>

- (instancetype)initWithView:(UIView<HHProfileViewProtocol> *)view;

@end
            