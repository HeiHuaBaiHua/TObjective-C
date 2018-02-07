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

@protocol _HHListBinderProtocol <NSObject>

- (Class)cellClass;

@optional
- (NSInteger)indexInPath:(NSIndexPath *)path;

@end

@protocol HHListBinderProtocol <HHBinderProtocol>

- (id<HHListViewModelProtocol>)viewModel;

@optional
- (void)becomeFirstListBinder;

@end



@protocol HHTableBinderProtocol <_HHListBinderProtocol, HHListBinderProtocol, UITableViewDelegate, UITableViewDataSource>

- (UITableView *)tableView;

@end




@protocol HHCollectionBinderProtocol <_HHListBinderProtocol, HHListBinderProtocol, UICollectionViewDelegate, UICollectionViewDataSource>
@end
