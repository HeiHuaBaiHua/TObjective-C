//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHUIBuilder.h"
@protocol HHWeiboListViewProtocol <NSObject>

- (UIView<HHSegmentViewProtocol> *)segmentView;
- (UITableView *)followedWeiboListView;
- (UITableView *)publicWeiboListView;

@end
        
