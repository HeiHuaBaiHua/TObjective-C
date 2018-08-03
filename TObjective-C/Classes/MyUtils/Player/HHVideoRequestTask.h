//
//  HHVideoRequestTask.h
//  OneToSayApp
//
//  Created by Dong on 16/4/10.
//  Copyright © 2016年 excetop. All rights reserved.
//

/// 这个task的功能是从网络请求数据，并把数据保存到本地的一个临时文件，网络请求结束的时候，如果数据完整，则把数据缓存到指定的路径，不完整就删除
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class HHVideoRequestTask;
@protocol HHVideoRequestTaskDelegate <NSObject>

- (void)task:(HHVideoRequestTask *)task didReceiveVideoLength:(NSUInteger)ideoLength mimeType:(NSString *)mimeType;
- (void)didReceiveVideoDataWithTask:(HHVideoRequestTask *)task;
- (void)didFinishLoadingWithTask:(HHVideoRequestTask *)task;
- (void)didFailLoadingWithTask:(HHVideoRequestTask *)task WithError:(NSInteger )errorCode;

@end

@interface HHVideoRequestTask : NSObject
/** 正在加载的请求 */
@property (nonatomic, strong, readonly) NSURL *url;
/** 请求数据的偏移量，即Range的开始位置 */
@property (nonatomic, readonly) NSUInteger offset;
/** 音视频的数据量大小 */
@property (nonatomic, readonly) NSUInteger videoLength;
/** 已下载的数据量大小 */
@property (nonatomic, readonly) NSUInteger downLoadingOffset;
/** 音视频类型 */
@property (nonatomic, strong, readonly) NSString *mimeType;
/** 是否完成加载 */
@property (nonatomic, assign) BOOL isFinishLoad;
/** 请求的代理 */
@property (nonatomic, weak) id <HHVideoRequestTaskDelegate> delegate;

/** 请求的url和range位置 */
- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset;
/** 停止加载 */
- (void)cancel;
/** 继续加载 */
- (void)continueLoading;
/** 清除缓存数据 */
- (void)clearData;


@end

