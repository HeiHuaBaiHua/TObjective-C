//
//  HHWeiboTableBinder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <YYModel/YYModel.h>

#import "CTMediator+Weibo.h"

#import "HHWeiboCell.h"
#import "HHWeiboTableBinder.h"

@implementation HHWeiboTableBinder

- (Class)cellClass {
    return [HHWeiboCell class];
}

- (NSInteger)indexInPath:(NSIndexPath *)path {
    return path.section;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ((id<HHListViewModelProtocol>)self.viewModel).allData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = [self indexInPath:indexPath];
    HHListCellViewModel cellModel = ((id<HHListViewModelProtocol>)self.viewModel).allData[index];
    [CTRouter pushToWeiboDetailVCWithWeiboJson:[cellModel.rawValue yy_modelToJSONObject]];
}

@end
