//
//  HHLoaderURLConnection.h
//  OneToSayApp
//
//  Created by Dong on 16/4/10.
//  Copyright © 2016年 excetop. All rights reserved.
//

/// 这个connenction的功能是把task缓存到本地的临时数据根据播放器需要的 offset和length去取数据并返回给播放器
/// 如果视频文件比较小，就没有必要存到本地，直接用一个变量存储即可
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class HHVideoRequestTask;

@protocol HHloaderURLConnectionDelegate <NSObject>

- (void)didFinishLoadingWithTask:(HHVideoRequestTask *)task;
- (void)didFailLoadingWithTask:(HHVideoRequestTask *)task WithError:(NSInteger )errorCode;

@end

@interface HHLoaderURLConnection : NSURLConnection <AVAssetResourceLoaderDelegate>

/** 请求任务 */
@property (nonatomic, strong) HHVideoRequestTask *task;
/** 自身代理 */
@property (nonatomic, weak) id<HHloaderURLConnectionDelegate> delegate;

/** 转换音视频URL制式 */
- (NSURL *)getSchemeVideoURL:(NSURL *)url;

@end

