//
//  HHPlayer.h
//  OneToSay
//
//  Created by HeiHuaBaiHua on 16/6/7.
//  Copyright © 2016年 Excetop. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "HHPlayerState.h"

@class HHPlayer;
@protocol HHPlayerDelegate <NSObject>

@optional
- (void)player:(HHPlayer *)player didChangePlayState:(HHPlayerState)state;//偷个懒 状态让外部自己判断 反正错误信息也不明确
- (void)player:(HHPlayer *)player didUpdateCurrentTime:(CGFloat)time duration:(CGFloat)duration;

@end

@interface HHPlayer : NSObject

@property (assign, nonatomic) BOOL isAllowPlayInBackground;
@property (weak, nonatomic) id<HHPlayerDelegate> delegate;

- (void)stop;
- (void)pause;
- (void)resume;
- (void)playWithUrl:(NSURL *)url;
- (void)seekToTime:(CGFloat)seconds;

- (HHPlayerState)state;
- (CGFloat)duration;
- (CGFloat)currentTime;
- (CGFloat)downloadedProgress;
- (AVPlayerItem *)playerItem;

@end
