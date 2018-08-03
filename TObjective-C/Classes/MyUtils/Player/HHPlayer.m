//
//  HHPlayer.m
//  OneToSay
//
//  Created by HeiHuaBaiHua on 16/6/7.
//  Copyright © 2016年 Excetop. All rights reserved.
//

#import "HHPlayer.h"
#import "HHVideoRequestTask.h"
#import "HHLoaderURLConnection.h"

@interface HHPlayer ()<HHloaderURLConnectionDelegate>

@property (strong, nonatomic) AVAsset *videoAsset;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) NSObject *playbackTimeObserver;
@property (strong, nonatomic) AVURLAsset *videoURLAsset;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) HHLoaderURLConnection *resouerLoader;
@property (assign, nonatomic) NSInteger lastDownloadedLength;

@property (assign, nonatomic) HHPlayerState state;
@property (assign, nonatomic) HHPlayerState interruptState;
@property (assign, nonatomic) CGFloat downloadedProgress;
@property (assign, nonatomic) CGFloat duration;
@property (assign, nonatomic) CGFloat currentTime;
@property (assign, nonatomic) BOOL isPausedByUser;

@end

@implementation HHPlayer

- (instancetype)init {
    if (self = [super init]) {
        
        self.isAllowPlayInBackground = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHandleInterreption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHandleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAppEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAppEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - HHVideoRequestTaskDelegate

- (void)didFinishLoadingWithTask:(HHVideoRequestTask *)task {
    
    self.lastDownloadedLength = 0;
}

- (void)didFailLoadingWithTask:(HHVideoRequestTask *)task WithError:(NSInteger)errorCode {
    
    [self.player pause];
    self.state = HHPlayerStateFailed;
}

#pragma mark - Interface
- (void)stop {
    if (!self.playerItem) {
        return;
    }
    
    [self reset];
    self.state = HHPlayerStateFinished;
}

- (void)pause {
    if (!self.playerItem) {
        return;
    }
    self.isPausedByUser = YES;
    
    [self.player pause];
    self.state = HHPlayerStatePaused;
}

- (void)resume {
    if (!self.playerItem) {
        return;
    }
    self.isPausedByUser = NO;
    
    [self.player play];
    self.state = HHPlayerStatePlaying;
}

- (void)playWithUrl:(NSURL *)url {
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [self.player pause];
    [self releasePlayer];
    self.isPausedByUser = NO;
    self.duration = self.currentTime = self.downloadedProgress = 0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 || ![url.absoluteString hasPrefix:@"http"]) {
        
        self.videoAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        self.playerItem = [AVPlayerItem playerItemWithAsset:self.videoAsset];
        self.player = nil;
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    } else {
        
        self.resouerLoader = [HHLoaderURLConnection new];
        self.resouerLoader.delegate = self;
        
        NSURL *playUrl = [self.resouerLoader getSchemeVideoURL:url];
        self.videoURLAsset = [AVURLAsset URLAssetWithURL:playUrl options:nil];
        [self.videoURLAsset.resourceLoader setDelegate:self.resouerLoader queue:dispatch_get_main_queue()];
        
        self.playerItem = [AVPlayerItem playerItemWithAsset:self.videoURLAsset];
        self.player = nil;
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    }
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    self.state = [url.scheme isEqualToString:@"file"] ? HHPlayerStatePlaying : HHPlayerStateBuffering;
}

- (void)seekToTime:(CGFloat)seconds {
    
    if (self.state == HHPlayerStateFinished) {
        return;
    }
    self.isPausedByUser = NO;
    
    seconds = MAX(0, seconds);
    seconds = MIN(seconds, self.duration);
    
    [self.player pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        
        [self.player play];
        self.state = self.playerItem.isPlaybackLikelyToKeepUp ? HHPlayerStateBuffering : HHPlayerStatePlaying;
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            
            [self monitoringPlayback:playerItem];
        } else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {
            
            [self reset];
            self.state = HHPlayerStateFailed;
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度
        
        [self calculateDownloadProgress:playerItem];
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        
        if (playerItem.isPlaybackBufferEmpty) {
            
            [self bufferingSomeSecond];
        }
    }
}

#pragma mark - Notification

//TODO: 处理中断事件
- (void)didHandleInterreption:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        
        self.interruptState = self.state;
        [self pause];
    } else {
        
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            
            if (self.interruptState == HHPlayerStatePlaying) {
                [self resume];
            } else {
                [self pause];
            }
        }
    }
}

//TODO: 处理输出线路改变
- (void)didHandleRouteChange:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {  //旧音频设备断开
        //获取上一线路描述信息
        AVAudioSessionRouteDescription *previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey];
        //获取上一线路的输出设备类型
        AVAudioSessionPortDescription *previousOutput = previousRoute.outputs[0];
        NSString *portType = previousOutput.portType;
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {//判断是否从耳机拔出
            if (self.state == HHPlayerStatePlaying) {
                [self resume];
            } else {
                [self pause];
            }
        }
    }
}

//TODO: 应用进入后台
- (void)didAppEnterBackground {
    if (!self.isAllowPlayInBackground) {
        [self pause];
        self.isPausedByUser = NO;
    }
}

//TODO: 应用进入前台
- (void)didAppEnterPlayground {
    if (!self.isPausedByUser && self.state == HHPlayerStatePaused) {
        [self resume];
    }
}

//TODO: 播放完成
- (void)playerItemDidPlayToEnd:(NSNotification *)notification {
    
    [self stop];
}

#pragma mark - Utils

//TODO: 播放器准备好之后开始播放
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    self.duration = playerItem.duration.value / playerItem.duration.timescale; //视频总时间
    if ([self.delegate respondsToSelector:@selector(player:didUpdateCurrentTime:duration:)]) {
        [self.delegate player:self didUpdateCurrentTime:0 duration:self.duration];
    }
    
    if (self.isPausedByUser && self.state == HHPlayerStatePaused) { return; }
    
    self.state = HHPlayerStateBuffering;
    [self.player play];
    
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        CGFloat currentTime = playerItem.currentTime.value / playerItem.currentTime.timescale;
        if (!strongSelf.isPausedByUser) {
            strongSelf.state = HHPlayerStatePlaying;
        }
        // 不相等的时候才更新，并发通知，否则seek时会继续跳动
        if (strongSelf.currentTime != currentTime) {
            strongSelf.currentTime = currentTime;
            if (strongSelf.currentTime > strongSelf.duration) {
                strongSelf.duration = strongSelf.currentTime;
            }
        }
        if ([strongSelf.delegate respondsToSelector:@selector(player:didUpdateCurrentTime:duration:)]) {
            [strongSelf.delegate player:strongSelf didUpdateCurrentTime:currentTime duration:strongSelf.duration];
        }
    }];
}

//TODO: 播放器进入播放状态 计算下载进度
- (void)calculateDownloadProgress:(AVPlayerItem *)playerItem {
    
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange range = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(range.start);
    float durationSeconds = CMTimeGetSeconds(range.duration);
    NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
    CMTime duration = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    self.downloadedProgress = timeInterval / totalDuration;
}

//TODO: 播放器进入缓冲状态
- (void)bufferingSomeSecond {
    
    //playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    if (self.lastDownloadedLength == 0) {
        self.lastDownloadedLength = self.resouerLoader.task.downLoadingOffset;
    }
    static BOOL isBuffering = NO;
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    
    [self.player pause];
    self.state = HHPlayerStateBuffering;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        isBuffering = NO;
        // 如果此时用户已经暂停了，则不再需要恢复播放了
        if (self.isPausedByUser) {
            return;
        }
        
        // 缓冲多于300k或者下载完成恢复播放 否则继续缓冲
        if (self.resouerLoader.task.isFinishLoad || self.resouerLoader.task.downLoadingOffset - self.lastDownloadedLength >= 300 * 1024) {
            
            [self.player play];
            self.state = HHPlayerStatePlaying;
            self.lastDownloadedLength = 0;
        } else {
            
            [self bufferingSomeSecond];
        }
    });
}

- (void)releasePlayer {
    if (!self.playerItem) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    [self.resouerLoader.task cancel];
    self.resouerLoader.delegate = nil;
    self.resouerLoader = nil;
    
    [self.videoURLAsset cancelLoading];
    self.videoURLAsset = nil;
    
    [self.playerItem cancelPendingSeeks];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    self.playerItem = nil;
    
    [self.player removeTimeObserver:self.playbackTimeObserver];
    self.playbackTimeObserver = nil;
    
    self.lastDownloadedLength = 0;
}

- (void)reset {
    
    [self.player pause];
    [self releasePlayer];
    self.isPausedByUser = YES;
    self.duration = self.currentTime = self.downloadedProgress = 0;
}

#pragma mark - Setter

- (void)setState:(HHPlayerState)state {
    
//    if (_state == state) {
//        return;
//    }
    
    _state = state;
    if ([self.delegate respondsToSelector:@selector(player:didChangePlayState:)]) {
        [self.delegate player:self didChangePlayState:state];
    }
}

@end
