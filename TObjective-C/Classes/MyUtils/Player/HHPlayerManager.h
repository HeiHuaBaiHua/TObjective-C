//
//  HHPlayerManager.h
//  OneToSayApp
//
//  Created by HeiHuaBaiHua on 16/5/26.
//  Copyright © 2016年 excetop. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHPlayerState.h"

typedef enum : NSUInteger {
    HHPlayModeListLoop = 0,
    HHPlayModeSingleLoop,
    HHPlayModeRandom
} HHPlayMode;

typedef enum : NSUInteger {
    HHMediaSourceTypeAPP = 1,
    HHMediaSourceTypeLocal
} HHMediaSourceType;

/** 播放器缓冲、播放、暂停、打断的通知 */
extern NSString *const HHPlayerDidChangedStateNotification;
/** 播放器完成的通知 */
extern NSString *const HHPlayerDidFinishedPlayNotification;
/** 播放器切换歌曲通知 */
extern NSString *const HHPlayerDidSwitchedItemNotification;
extern NSString *const kHHPlayerFinishItemId;
extern NSString *const kHHPlayerFinishIsError;

extern NSString *const HHDidReceiveRemoteControlNotification;

@protocol HHPlayerManagerDelegate <NSObject>

- (void)playerDidSwitchToItemAtIndex:(NSUInteger)index;
- (void)playerWillBufferingForItemAtIndex:(NSUInteger)index;
- (void)playerDidReadyToPlayItemAtIndex:(NSUInteger)index;
- (void)playerDidPausedItemAtIndex:(NSUInteger)index;
- (void)playerDidUpdateCurrentTime:(CGFloat)time duration:(CGFloat)duration forItemAtIndex:(NSUInteger)index;;
- (void)playerDidFinishedPlayItemAtIndex:(NSUInteger)index withError:(NSError *)error;

@end

@protocol HHPlayerItem <NSObject>

- (BOOL)playEnable;
- (NSUInteger)ID;
- (NSURL *)playURL;

- (NSUInteger)hash;
- (BOOL)isEqual:(id)object;

@optional
- (HHMediaSourceType)sourceType;

@end

#define PlayerManager [HHPlayerManager sharedManager]

@interface HHPlayerManager : NSObject

@property (assign, nonatomic) BOOL isAutoPlay;
@property (assign, nonatomic) BOOL isAllowPlayInBackground;

+ (instancetype)sharedManager;
+ (instancetype)sharedManagerWithDelegate:(id<HHPlayerManagerDelegate>)delegate;

- (void)playWithUrl:(NSURL *)url;
- (void)playWithItem:(id)item;
- (void)playWithItemIndex:(NSUInteger)index;
- (void)playWithItemList:(NSArray *)itemList;
- (void)playWithItemList:(NSArray *)itemList currentItem:(id<HHPlayerItem>)item;
- (void)playWithItemList:(NSArray *)itemList atIndex:(NSUInteger)index;
- (void)playWithItemList:(NSArray *)itemList atIndex:(NSUInteger)index isAutoPlay:(BOOL)isAutoPlay;

- (void)addItem:(id<HHPlayerItem>)item;
- (void)addItems:(NSArray *)items;
- (BOOL)insertItem:(id<HHPlayerItem>)item atIndex:(NSUInteger)index;
- (void)insertItems:(NSArray *)items atIndex:(NSUInteger)index;
- (void)removeItem:(id<HHPlayerItem>)item;
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)removeItems:(NSArray *)items;
- (void)removeItemsWithRange:(NSRange)range;
- (void)replacePlayListWithItems:(NSArray *)items;
- (void)replacePlayListWithItems:(NSArray *)items atIndex:(NSUInteger)index;

- (void)pause;
- (void)resume;
- (void)seekToTime:(CGFloat)seconds;
- (void)stop;

- (BOOL)hasNextItem;
- (void)playNextItem;
- (BOOL)hasPreviousItem;
- (void)playPreviousItem;

- (BOOL)isPlaying;
- (HHPlayerState)playerState;

- (CGFloat)duration;
- (CGFloat)currentTime;
- (CGFloat)loadedProgress;

- (NSArray *)itemList;
- (NSInteger)currentItemIndex;
- (id<HHPlayerItem>)currentItem;

- (CGFloat)terminateTime;
- (NSInteger)terminateItemID;

@end
