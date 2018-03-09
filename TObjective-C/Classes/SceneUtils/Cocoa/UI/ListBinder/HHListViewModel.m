//
//  HHListViewModel.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHListViewModel.h"

@interface HHListViewModel ()

@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSMutableArray<HHListCellViewModel> *allData;
@property (nonatomic, strong) RACCommand *refreshCommand;
@property (nonatomic, strong) RACCommand *loadMoreCommand;

@end

@implementation HHListViewModel

- (RACCommand *)refreshCommand {
    if (!_refreshCommand) {
        @weakify(self);
        _refreshCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            
            int startPage = self.startPage;
            return [[self fetchDataSignalWithPage:startPage] doNext:^(id x) {
                
                self.page = startPage + 1;
                [self.allData removeAllObjects];
                [self handleResult:x];
            }];
        }];
    }
    return _refreshCommand;
}

- (RACCommand *)loadMoreCommand {
    if (!_loadMoreCommand) {
        @weakify(self);
        _loadMoreCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            
            return [[self fetchDataSignalWithPage:self.page] doNext:^(id x) {
                
                self.page += 1;
                [self handleResult:x];
            }];
        }];
    }
    return _loadMoreCommand;
}

- (void)handleResult:(NSArray *)result {
    [self.allData addObjectsFromArray:result];
}

- (int)startPage {
    return 0;
}

#pragma mark - Network

- (RACSignal *)fetchDataSignalWithPage:(int)page {
    return [RACSignal empty];
}

- (NSMutableArray<HHListCellViewModel> *)allData {
    if (!_allData) {
        _allData = [NSMutableArray array];
    }
    return _allData;
}

@end
