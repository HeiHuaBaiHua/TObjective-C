//
//  HHPlayerManager.m
//  OneToSayApp
//
//  Created by HeiHuaBaiHua on 16/5/26.
//  Copyright © 2016年 excetop. All rights reserved.
//

#import <YYModel/YYModel.h>
#import <MediaPlayer/MediaPlayer.h>
#import <SDWebImage/SDWebImageManager.h>
#import <RealReachability/RealReachability.h>

#import "HHPlayer.h"
#import "HHPlayerManager.h"

NSString *const HHPlayerDidChangedStateNotification = @"HHPlayerDidChangedStateNotification";
NSString *const HHPlayerDidFinishedPlayNotification = @"HHPlayerDidFinishedPlayNotification";
NSString *const HHPlayerDidSwitchedItemNotification = @"HHPlayerDidSwitchedItemNotification";
NSString *const kHHPlayerFinishItemId = @"kHHPlayerFinishItemId";
NSString *const kHHPlayerFinishIsError = @"kHHPlayerFinishIsError";

NSString *const HHDidReceiveRemoteControlNotification = @"HHDidReceiveRemoteControlNotification";

static NSString *const kVoiceList =  @"VoiceList";
static NSString *const kVoiceIndex =  @"VoiceIndex";
static NSString *const kTerminateItemID =  @"terminateItemID";
static NSString *const kTerminateTime =  @"terminateTime";

#define UserDefaults [NSUserDefaults standardUserDefaults]

@interface HHPlayerManager ()<HHPlayerDelegate>

@property (weak, nonatomic) id<HHPlayerManagerDelegate> delegate;

@property (strong, nonatomic) HHPlayer *player;
@property (assign, nonatomic) HHPlayerState playerState;

@property (assign, nonatomic) NSInteger playingItemIndex;
@property (strong, nonatomic) NSMutableArray< id<HHPlayerItem> > *playerItemList;

@property (strong, nonatomic) NSTimer *delayTimer;

@end

@implementation HHPlayerManager

+ (instancetype)sharedManager {
    
    static HHPlayerManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[super allocWithZone:NULL] init];
    });
    return sharedManager;
}

+ (instancetype)sharedManagerWithDelegate:(id<HHPlayerManagerDelegate>)delegate {
    
    HHPlayerManager *manager = [self sharedManager];
    manager.delegate = delegate;
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedManager];
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.player = [HHPlayer new];
        self.player.delegate = self;
        self.isAutoPlay = self.isAllowPlayInBackground = YES;
        self.playerItemList = [NSMutableArray array];
        
        NSArray *array = [self getVoiceListModelArrayAndIndex];
        if (array) {
            [self.playerItemList addObjectsFromArray:array[0]];
            self.playingItemIndex = [array[1] integerValue];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteControlNotification:) name:HHDidReceiveRemoteControlNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savePlayState) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

#pragma mark - HHPlayerDelegate

- (void)player:(HHPlayer *)player didChangePlayState:(HHPlayerState)state {
    
    HHPlayerState oldState = self.playerState;
    self.playerState = state;
    
    switch (state) {
        case HHPlayerStateBuffering: {
            
            if ([self.delegate respondsToSelector:@selector(playerWillBufferingForItemAtIndex:)]) {
                [self.delegate playerWillBufferingForItemAtIndex:self.playingItemIndex];
            }
        }   break;
            
        case HHPlayerStatePlaying: {
            
            if (oldState == HHPlayerStateBuffering && [self.delegate respondsToSelector:@selector(playerDidReadyToPlayItemAtIndex:)]) {
                
                NSNumber *terminateItemID = [UserDefaults objectForKey:kTerminateItemID];
                if (terminateItemID && [terminateItemID integerValue] == self.currentItem.ID) {
                    [self seekToTime:[[UserDefaults objectForKey:kTerminateTime] floatValue]];
                    [UserDefaults removeObjectForKey:kTerminateItemID];
                }
                [self.delegate playerDidReadyToPlayItemAtIndex:self.playingItemIndex];
            }
        }   break;
            
        case HHPlayerStatePaused: {
            
            if ([self.delegate respondsToSelector:@selector(playerDidPausedItemAtIndex:)]) {
                [self.delegate playerDidPausedItemAtIndex:self.playingItemIndex];
            }
        }   break;
            
        case HHPlayerStateFailed:
        case HHPlayerStateFinished: {
            
            if ([self.delegate respondsToSelector:@selector(playerDidFinishedPlayItemAtIndex:withError:)]) {
                
                NSError *error = (state == HHPlayerStateFailed ? [NSError new] : nil);
                [self.delegate playerDidFinishedPlayItemAtIndex:self.playingItemIndex withError:error];
            }
            
        }   break;
            
        default:break;
    }
    
//    NSString *toast = [NSString stringWithFormat:@"oldState = %ld __ state = %ld",oldState,state];
//    [[UIApplication sharedApplication].keyWindow makeToast:toast duration:3 position:CSToastPositionCenter];
    
    id<HHPlayerItem> item = self.currentItem;
    if (state == HHPlayerStateFailed || state == HHPlayerStateFinished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HHPlayerDidFinishedPlayNotification
                                                            object:nil
                                                          userInfo:@{kHHPlayerFinishItemId : @(item.ID),
                                                                     kHHPlayerFinishIsError : @(state == HHPlayerStateFailed)}];

        if (oldState != HHPlayerStatePaused && self.isAutoPlay && [self hasNextItem]) {
            
            id<HHPlayerItem> nextItem = self.playerItemList[self.playingItemIndex + 1];
            if ([nextItem.playURL.scheme isEqualToString:@"file" ] || [self isNetworkReachable]) {
                [self playNextItem];
            }
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:HHPlayerDidChangedStateNotification
                                                            object:nil
                                                          userInfo:@{kHHPlayerFinishItemId : @(item.ID)}];
    }
    
}

- (void)player:(HHPlayer *)player didUpdateCurrentTime:(CGFloat)time duration:(CGFloat)duration {
    
    if ([self.delegate respondsToSelector:@selector(playerDidUpdateCurrentTime:duration:forItemAtIndex:)]) {
        [self.delegate playerDidUpdateCurrentTime:time duration:duration forItemAtIndex:self.playingItemIndex];
    }
}

#pragma mark - Interface(Play)

- (void)playWithUrl:(NSURL *)url {
    [self.player playWithUrl:url];
}

- (void)playWithItem:(id)item {
    
    if (item != nil) {
        
        if ([self.playerItemList containsObject:item]) {
            
            [self.playerItemList enumerateObjectsUsingBlock:^(id<HHPlayerItem> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isEqual:item]) {
                    
                    *stop = YES;
                    [self playWithItemIndex:idx];
                }
            }];
        } else {
            
            [self playWithItemList:@[item] atIndex:0 isAutoPlay:YES];
        }
    }
}

- (void)playWithItemIndex:(NSUInteger)index {
    
    if (self.playerItemList.count > 0 && index < self.playerItemList.count) {
        
        self.playingItemIndex = index;
        [self playCurrentItem];
    }
}

- (void)playWithItemList:(NSArray *)itemList {
    [self playWithItemList:itemList atIndex:0 isAutoPlay:YES];
}

- (void)playWithItemList:(NSArray *)itemList currentItem:(id<HHPlayerItem>)item {
    [self playWithItemList:itemList atIndex:[itemList indexOfObject:item] isAutoPlay:YES];
}

- (void)playWithItemList:(NSArray *)itemList atIndex:(NSUInteger)index {
    [self playWithItemList:itemList atIndex:index isAutoPlay:YES];
}

- (void)playWithItemList:(NSArray *)itemList atIndex:(NSUInteger)index isAutoPlay:(BOOL)isAutoPlay {
    
    if (itemList.count > 0 && index < itemList.count) {
        
        [self replacePlayListWithItems:itemList];
        self.isAutoPlay = isAutoPlay;
        self.playingItemIndex = index;
        
        [self playCurrentItem];
    }
}

#pragma mark - Interface(CRUD)

- (void)addItem:(id)item {
    
    [self insertItem:item atIndex:self.playerItemList.count];
}
- (void)addItems:(NSArray *)items {
    
    [self insertItems:items atIndex:self.playerItemList.count];
}

- (BOOL)insertItem:(id)item atIndex:(NSUInteger)index {
    
//  似乎并不要求去重 先关掉
    if (/* DISABLES CODE */ (YES) || ![self.playerItemList containsObject:item]) {
        
        if (self.playerItemList.count > 0) {
            index = index < self.playerItemList.count ? index : self.playerItemList.count;
        } else {
            index = 0;
        }
        [self.playerItemList insertObject:item atIndex:index];
        if (index <= self.playingItemIndex) {
            self.playingItemIndex++;
        }
        
        return YES;
    }
    return NO;
}

- (void)insertItems:(NSArray *)items atIndex:(NSUInteger)index {
    for (id item in items) {
        if ([self insertItem:item atIndex:index]) {
            index++;
        }
    }
}

- (void)removeItem:(id)item {

    __block NSInteger index = -1;
    [self.playerItemList enumerateObjectsUsingBlock:^(id<HHPlayerItem>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:item]) {
            
            index = idx;
            *stop = YES;
        }
    }];
    if (index != -1) {
        [self removeItemAtIndex:index];
    }
}

- (void)removeItemAtIndex:(NSUInteger)index {
    
    if (index < self.playerItemList.count) {
        [self.playerItemList removeObjectAtIndex:index];
        
        if (index > 0 && index <= self.playingItemIndex) {
            self.playingItemIndex--;
        }
    }
}

- (void)removeItemsWithRange:(NSRange)range {
    
    NSInteger maxIndex = MAX(self.playerItemList.count - 1, 0);
    NSUInteger location = range.location;
    if (location < maxIndex) {
        
        NSUInteger length = (range.length <= self.playerItemList.count - location ? range.length : self.playerItemList.count - location);
        [self.playerItemList removeObjectsInRange:NSMakeRange(location, length)];
        
        if (self.playingItemIndex >= location) {
         
            if (self.playingItemIndex <= location + length - 1) {
                self.playingItemIndex = location - 1;
            } else {
                self.playingItemIndex -= length;
            }
        }
    }
}

- (void)removeItems:(NSArray *)items {
    
    if (items.count == 0) { return; }
    
    __block NSInteger previousItemsCount = 0;
    NSMutableArray *itemIds = [NSMutableArray array];
    for (id<HHPlayerItem> item in items) { [itemIds addObject:@(item.ID)]; }
    [self.playerItemList enumerateObjectsUsingBlock:^(id<HHPlayerItem>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([itemIds containsObject:@(obj.ID)]) {
            
            if (self.playingItemIndex >= idx) { previousItemsCount++; }
            [itemIds removeObject:@(obj.ID)];
            if (itemIds.count == 0) { *stop = YES; }
        }
    }];
    self.playingItemIndex -= previousItemsCount;
    [self.playerItemList removeObjectsInArray:items];
}

- (void)replacePlayListWithItems:(NSArray *)items {
    
    id<HHPlayerItem> playItem = self.currentItem;
    if ([items containsObject:playItem]) {
        self.playingItemIndex = [items indexOfObject:playItem];
    } else {
        self.playingItemIndex = 0;
    }
    
    [self.playerItemList removeAllObjects];
    [self.playerItemList addObjectsFromArray:items];
    self.isAutoPlay = YES;
}

- (void)replacePlayListWithItems:(NSArray *)items atIndex:(NSUInteger)index {
    
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx + index < self.playerItemList.count) {
            self.playerItemList[idx + index] = obj;
        } else {
            [self.playerItemList addObject:obj];
        }
    }];
}

#pragma mark - Interface(Action)

- (void)savePlayState {
    
    NSMutableArray *dicArray = [NSMutableArray array];
    for (id model in self.itemList) {
        NSDictionary *dic = [model yy_modelToJSONObject];
        [dicArray addObject:dic];
    }
    [UserDefaults setObject:dicArray forKey:kVoiceList];
    [UserDefaults setObject:[NSString stringWithFormat:@"%ld", self.playingItemIndex] forKey:kVoiceIndex];
    [UserDefaults setObject:@(self.currentTime) forKey:kTerminateTime];
    [UserDefaults setObject:@(self.currentItem.ID) forKey:kTerminateItemID];
    [UserDefaults synchronize];

}

- (void)pause {
    [self.player pause];
}

- (void)resume {
    if (!self.player.playerItem) {
        
        [self playWithItemIndex:self.playingItemIndex];
    } else if (self.player.state == HHPlayerStateFailed || self.player.state == HHPlayerStateFinished){
        
        [self playCurrentItem];
    } else {
        
        [self.player resume];
    }
}

- (void)seekToTime:(CGFloat)seconds {
    [self.player seekToTime:seconds];
}

- (void)stop {
    [self.player stop];
}

- (BOOL)hasNextItem {
    
    NSInteger maxIndex = self.playerItemList.count - 1;
    return self.playingItemIndex < maxIndex;
}

- (void)playNextItem {
    
    if ([self hasNextItem]) {
        
        self.playingItemIndex++;
        [self playCurrentItem];
    }
}

- (BOOL)hasPreviousItem {
    return self.playingItemIndex > 0 && self.playingItemIndex < self.playerItemList.count;
}

- (void)playPreviousItem {
    
    if ([self hasPreviousItem]) {
        
        self.playingItemIndex--;
        [self playCurrentItem];
    }
}

#pragma mark - Interface(Data)

- (CGFloat)duration {
    return self.player.duration;
}

- (CGFloat)currentTime {
    return self.player.currentTime;
}

- (CGFloat)loadedProgress {
    return self.player.downloadedProgress;
}

- (NSArray *)itemList {
    return [self.playerItemList copy];
}

- (id<HHPlayerItem>)currentItem {
    
    id<HHPlayerItem> currentItem;
    if (self.playerItemList.count > 0) {
        
        NSInteger maxIndex = self.playerItemList.count - 1;
        self.playingItemIndex = MAX(0, self.playingItemIndex);
        self.playingItemIndex = MIN(maxIndex, self.playingItemIndex);
        currentItem = self.playerItemList[self.playingItemIndex];
    }
    return currentItem;
}

- (NSInteger)currentItemIndex {
    return self.playingItemIndex;
}

- (BOOL)isPlaying {
    return self.playerState == HHPlayerStatePlaying;
}

- (CGFloat)terminateTime {
    return [[UserDefaults objectForKey:kTerminateTime] floatValue];
}

- (NSInteger)terminateItemID {
    return [[UserDefaults objectForKey:kTerminateItemID] integerValue];
}

#pragma mark - Notification

- (void)didReceiveRemoteControlNotification:(NSNotification *)notification {
    UIEventSubtype type = (UIEventSubtype)[notification.object integerValue];
    switch (type) {
        case UIEventSubtypeRemoteControlPlay: {
            [self resume];
        }   break;
            
        case UIEventSubtypeRemoteControlPause: {
            [self pause];
        }   break;
            
        case UIEventSubtypeRemoteControlStop: {
            [self.player stop];
        }   break;

        case UIEventSubtypeRemoteControlTogglePlayPause: {
            if (self.playerState == HHPlayerStatePlaying) {
                [self pause];
            } else {
                [self resume];
            }
        }   break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:{
            [self playPreviousItem];
        }   break;

        case UIEventSubtypeRemoteControlNextTrack:{
            [self playNextItem];
        }   break;
            
        default:break;
    }
}

#pragma mark - Utils

- (void)play {
    
    id<HHPlayerItem> item = self.currentItem;
    if (item && [item playEnable]) {
        NSLog(@"url = %@",item.playURL);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HHPlayerDidSwitchedItemNotification object:nil userInfo:nil];
        if ([self.delegate respondsToSelector:@selector(playerDidSwitchToItemAtIndex:)]) {
            [self.delegate playerDidSwitchToItemAtIndex:self.playingItemIndex];
        }
        
        [self.player playWithUrl:item.playURL];
        
        //保存锁屏页的信息
        [self configNowPlayingVoice:(id )self.playerItemList[self.playingItemIndex]];
        
        [self saveVoiceListModelArray:self.playerItemList withIndex:self.playingItemIndex];
    }
}

- (void)playCurrentItem {
    
    [self.delayTimer invalidate];
    self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(play) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.delayTimer forMode:NSRunLoopCommonModes];
}

/** 存储声音信息模型数组及数据在数组中的序号 */
- (void)saveVoiceListModelArray:(NSArray *)array withIndex:(NSInteger)index {
    
    NSMutableArray *dicArray = [NSMutableArray array];
    for (id model in array) {
        NSDictionary *dic = [model yy_modelToJSONObject];
        [dicArray addObject:dic];
    }
    [UserDefaults setObject:dicArray forKey:kVoiceList];
    [UserDefaults setObject:[NSString stringWithFormat:@"%ld", index] forKey:kVoiceIndex];
    [UserDefaults synchronize];
}

/** TODO: 获取声音信息模型数组及序号 HHVoice */
- (NSArray *)getVoiceListModelArrayAndIndex {
//    NSMutableArray *modelArray = [NSMutableArray array];
//    NSArray *array = [UserDefaults objectForKey:kVoiceList];
//    for (NSDictionary *dic in array) {
//        id voice = [HHVoice objectWithKeyValues:dic];
//        [modelArray addObject:voice];
//    }
//
//    if (modelArray.count) {
//        NSArray *returnArray = @[modelArray, [UserDefaults objectForKey:kVoiceIndex]];
//        return returnArray;
//    }
    return nil;
}

/** TODO: 设置锁屏状态，显示的歌曲信息 HHVoice */
- (void)configNowPlayingVoice:(id )voiceModel {
    //为了避免了版本兼容问题，这个API貌似只出现在iOS5之后
//    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
//        
//        SDWebImageManager *manager = [SDWebImageManager sharedManager];
//        [manager downloadImageWithURL:voiceModel.voiceFirstPicUrl options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//            [dict setObject:voiceModel.voiceName ?: @"一说" forKey:MPMediaItemPropertyTitle];
//            voiceModel.nickname = voiceModel.nickname == nil ? @"一说":voiceModel.nickname;
//            [dict setObject:voiceModel.nickname forKey:MPMediaItemPropertyArtist];
//            if (voiceModel.voiceLength == 0) {
//                AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:voiceModel.voicePath.HHVoicePathUrl options:nil];
//                voiceModel.voiceLength = CMTimeGetSeconds(audioAsset.duration);
//            }
//            [dict setObject:@(voiceModel.voiceLength) forKey:MPMediaItemPropertyPlaybackDuration];
//            //专辑缩略图
//            image = image == nil ? kCoverImageLock:image;
//            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
//            [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
//            //设置锁屏状态下屏幕显示播放音乐信息
//            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
//        }];
//    }
}

#pragma mark - Setter

- (void)setIsAllowPlayInBackground:(BOOL)isAllowPlayInBackground {
    
    _isAllowPlayInBackground = isAllowPlayInBackground;
    self.player.isAllowPlayInBackground = isAllowPlayInBackground;
}

- (BOOL)isNetworkReachable {
    
    ReachabilityStatus status = GLobalRealReachability.currentReachabilityStatus;
    return status == RealStatusViaWWAN || status == RealStatusViaWiFi;
}

@end
