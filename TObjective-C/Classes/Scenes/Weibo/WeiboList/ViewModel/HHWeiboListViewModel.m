//
//  Python3
//  MakeOCFiles
//
//  Created by HeiHuaBaiHua 
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"

#import "HHWeiboListViewModel.h"
#import "HHPublicWeiboListViewModel.h"
#import "HHFollowedWeiboListViewModel.h"

@interface HHWeiboListViewModel ()

@property (nonatomic, strong) NSArray *titles;
/** 协议还是.h 在runtime的加持下区别极小 都只是接口声明 随意选择 */
@property (nonatomic, strong) id<HHListViewModelProtocol> publicWeiboListViewModel;
@property (nonatomic, strong) id<HHListViewModelProtocol> followedWeiboListViewModel;

@end

@implementation HHWeiboListViewModel

- (instancetype)init {
    if (self = [super init]) {
        
        self.titles = @[@"关注", @"最新"];
        self.publicWeiboListViewModel = [HHPublicWeiboListViewModel new];
        self.followedWeiboListViewModel = [HHFollowedWeiboListViewModel new];
    }
    return self;
}

- (NSDictionary *)titleAttributes:(BOOL)selected {
    
    UIColor *color = [UIColor colorWithHex:selected ? 0x252525 : 0x999999];
    return @{NSFontAttributeName : [UIFont fontOfCode:2], NSForegroundColorAttributeName : color};
}

@end
        
