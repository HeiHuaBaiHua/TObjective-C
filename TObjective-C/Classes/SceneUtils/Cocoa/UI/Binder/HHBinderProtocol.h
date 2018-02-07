//
//  HHBinderProtocol.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACCommand;
@protocol HHViewModelProtocol <NSObject>

- (id)rawValue;
- (RACCommand *)refreshCommand;

@end
typedef id<HHViewModelProtocol> HHViewModel;





@protocol HHBinderProtocol <NSObject>

- (id)initWithView:(UIView *)view;
- (void)bind:(id)viewModel;

@optional
- (UIView *)view;
- (id)viewModel;

- (void)refreshData;
@end

#define HHDefaultRawValue (@YES)

#define HH_Bind(aBinder, aViewModel) do {\
id binder = (aBinder);\
id bindedVM = (aViewModel);\
SEL sel = NSSelectorFromString(@"bind:");\
if ([binder respondsToSelector:sel]) {\
    _Pragma("clang diagnostic push")\
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")\
    [binder performSelector:sel withObject:bindedVM];\
    _Pragma("clang diagnostic pop")\
}\
} while (0);


