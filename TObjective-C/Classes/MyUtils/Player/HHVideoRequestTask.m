//
//  HHVideoRequestTask.m
//  OneToSayApp
//
//  Created by Dong on 16/4/10.
//  Copyright © 2016年 excetop. All rights reserved.
//

#import "HHVideoRequestTask.h"

@interface HHVideoRequestTask () <NSURLConnectionDataDelegate, NSURLConnectionDelegate, AVAssetResourceLoaderDelegate>
/** 正在加载的请求 */
@property (nonatomic, strong) NSURL *url;
/** 请求数据的偏移量，即Range的开始位置 */
@property (nonatomic, assign) NSUInteger offset;
/** 音视频的数据量大小 */
@property (nonatomic, assign) NSUInteger videoLength;
/** 音视频类型 */
@property (nonatomic, strong) NSString *mimeType;
/** url的连接 */
@property (nonatomic, strong) NSURLConnection *connection;
/** 是否完成加载 */
@property (nonatomic, strong) NSURLSessionTask *sessionTask;
/** 请求连接的数组 */
@property (nonatomic, strong) NSMutableArray *taskArr;
/** 已下载的数据量大小 */
@property (nonatomic, assign) NSUInteger downLoadingOffset;
/** 是否已连接过一次 */
@property (nonatomic, assign) BOOL once;
/** 文件数据流操作 */
@property (nonatomic, strong) NSFileHandle *fileHandle;
/** 临时存储路径 */
@property (nonatomic, strong) NSString *tempPath;

@end

@implementation HHVideoRequestTask

- (instancetype)init {
    self = [super init];
    if (self) {
        _taskArr = [NSMutableArray array];
        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        _tempPath =  [document stringByAppendingPathComponent:@"temp.mp3"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_tempPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_tempPath error:nil];
            [[NSFileManager defaultManager] createFileAtPath:_tempPath contents:nil attributes:nil];
        } else {
            [[NSFileManager defaultManager] createFileAtPath:_tempPath contents:nil attributes:nil];
        }
    }
    return self;
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _isFinishLoad = NO;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *dic = (NSDictionary *)[httpResponse allHeaderFields] ;
//    NSLog(@"responseCode = %d, responeDic = %@", httpResponse.statusCode, dic);
    if (httpResponse.statusCode >= 400 ) {
        if ([self.delegate respondsToSelector:@selector(didFailLoadingWithTask:WithError:)]) {
            [self.delegate didFailLoadingWithTask:self WithError:httpResponse.statusCode];
        }
        return;
    }
    NSString *content = [dic valueForKey:@"Content-Range"];
    NSArray *array = [content componentsSeparatedByString:@"/"];
    NSString *length = array.lastObject;
    
    NSUInteger videoLength;
    if ([length integerValue] == 0) {
        videoLength = (NSUInteger)httpResponse.expectedContentLength;
    } else {
        videoLength = [length integerValue];
    }
    
    self.videoLength = videoLength;
    self.mimeType = dic[@"Content-Type"];
    if ([self.delegate respondsToSelector:@selector(task:didReceiveVideoLength:mimeType:)]) {
        [self.delegate task:self didReceiveVideoLength:self.videoLength mimeType:self.mimeType];
    }
    [self.taskArr addObject:connection];
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_tempPath];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.fileHandle seekToEndOfFile];
    [self.fileHandle writeData:data];
    _downLoadingOffset += data.length;
    if ([self.delegate respondsToSelector:@selector(didReceiveVideoDataWithTask:)]) {
        [self.delegate didReceiveVideoDataWithTask:self];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.taskArr.count < 2) {
        _isFinishLoad = YES;
        //这里自己写需要保存数据的路径
        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString *movePath =  [document stringByAppendingPathComponent:@"saveVoice.mp3"];
        
        BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:_tempPath toPath:movePath error:nil];
        if (isSuccess) {
            NSLog(@"rename success");
        } else {
            NSLog(@"rename fail");
        }
    }
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingWithTask:)]) {
        [self.delegate didFinishLoadingWithTask:self];
    }
}

#pragma mark -  NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //请求超时：-1001, 找不到服务器：-1003, 服务器内部错误：-1004, 网络中断：-1005, 无网络连接：-1009
    if (error.code == -1001 && !_once) {      //网络超时，重连一次
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self continueLoading];
//        });
    }
    if ([self.delegate respondsToSelector:@selector(didFailLoadingWithTask:WithError:)]) {
        [self.delegate didFailLoadingWithTask:self WithError:error.code];
    }
    if (error.code == -1009) {
        NSLog(@"无网络连接");
    }
}

#pragma mark - Interface
- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset {
    _url = url;
    _offset = offset;
    //如果建立第二次请求，先移除原来文件，再创建新的
    if (self.taskArr.count >= 1) {
        [[NSFileManager defaultManager] removeItemAtPath:_tempPath error:nil];
        [[NSFileManager defaultManager] createFileAtPath:_tempPath contents:nil attributes:nil];
    }
    _downLoadingOffset = 0;
    NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    if ([url.path hasPrefix:@"https"]) {
        actualURLComponents.scheme = @"https";
    } else {
        actualURLComponents.scheme = @"http";
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[actualURLComponents URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    if (offset > 0 && self.videoLength > 0) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",(unsigned long)offset, (unsigned long)self.videoLength - 1] forHTTPHeaderField:@"Range"];
    }
    NSLog(@"播放器的第一次请求 = %@", request.allHTTPHeaderFields);
    [self.connection cancel];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
    [self.connection start];
}

- (void)cancel {
    [self.connection cancel];
}

- (void)continueLoading {
    _once = YES;
    NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:_url resolvingAgainstBaseURL:NO];
    actualURLComponents.scheme = @"http";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[actualURLComponents URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",(unsigned long)_downLoadingOffset, (unsigned long)self.videoLength - 1] forHTTPHeaderField:@"Range"];
    NSLog(@"播放器的第二次请求 = %@", request.allHTTPHeaderFields);
    [self.connection cancel];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
    [self.connection start];
}

- (void)clearData {
    [self.connection cancel];
    //移除文件
    [[NSFileManager defaultManager] removeItemAtPath:_tempPath error:nil];
}

@end

