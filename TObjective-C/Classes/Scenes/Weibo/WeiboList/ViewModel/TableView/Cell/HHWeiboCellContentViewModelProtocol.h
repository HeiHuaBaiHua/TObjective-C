//
//  HHWeiboCellContentViewModelProtocol.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>

#import "HHWeibo.h"
@protocol HHWeiboCellContentViewModelProtocol <NSObject>

- (NSAttributedString *)text;
- (NSMutableArray<NSURL *> *)imageUrls;
- (NSMutableArray<MWPhoto *> *)largeImageUrls;
- (void)setOnClickHrefHandler:(void (^)(HHWeiboHrefType, NSString *))onClickHrefHandler;

- (CGFloat)contentHeight;

@end
