//
//  HHListViewModel.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHBinderProtocol.h"

#pragma mark - ListCellViewModel

@class RACCommand;
@protocol HHListCellViewModelProtocol <NSObject>

@optional
- (instancetype)initWithObject:(id)object;

- (id)rawValue;
- (CGSize)cellSize;
- (CGFloat)cellHeight;

@end
typedef id<HHListCellViewModelProtocol> HHListCellViewModel;


#pragma mark - ListViewModel

@protocol HHListViewModelProtocol <NSObject>

- (NSMutableArray<HHListCellViewModel> *)allData;
- (RACCommand *)refreshCommand;
@optional
- (RACCommand *)loadMoreCommand;

@end


#pragma mark - ListBinder

@protocol HHListBinderProtocol <HHBinderProtocol>

- (Class)cellClass;
- (NSInteger)indexInPath:(NSIndexPath *)path;
- (id<HHListViewModelProtocol>)viewModel;

- (void)becomeFirstListBinder;
@end



@protocol HHTableBinderProtocol <HHListBinderProtocol, UITableViewDelegate, UITableViewDataSource>
@end




@protocol HHCollectionBinderProtocol <HHListBinderProtocol, UICollectionViewDelegate, UICollectionViewDataSource>
@end
