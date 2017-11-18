//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHWeiboListViewProtocol.h"
#import "HHWeiboListViewModelProtocol.h"
@interface HHWeiboListBinder : NSObject<HHBinderProtocol>

- (UIView<HHWeiboListViewProtocol> *)view;

@end
            
