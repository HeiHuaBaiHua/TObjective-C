//
//  HHWeiboDetailCommentsCellViewModelProtocol.h
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHListBinderProtocol.h"
@protocol HHWeiboDetailCommentsCellViewModelProtocol <HHListCellViewModelProtocol>

- (NSString *)text;
- (UIImage *)image;

@end
