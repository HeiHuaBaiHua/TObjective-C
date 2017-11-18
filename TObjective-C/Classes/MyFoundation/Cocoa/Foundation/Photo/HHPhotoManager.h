//
//  HHPhotoManager.h
//  Test
//
//  Created by leihaiyin on 2017/11/9.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//
#import <Photos/Photos.h>
#import <Foundation/Foundation.h>

#import "HHPhotoHeader.h"
@interface HHPhotoManager : NSObject

+ (instancetype)sharedManager;

- (void)checkAuthorizationStatusWithCompletionHandler:(void(^)(BOOL isAuthorized))handler;

- (NSArray<PHAssetCollection *> *)allPhotoAlbums;

- (NSArray<PHAsset *> *)allPhotos;
- (NSArray<PHAsset *> *)photosInAlbum:(PHAssetCollection *)album;
@end

#pragma mark - PHAsset Image
@interface PHAsset (Image)

- (UIImage *)originImage;
- (UIImage *)previewImage;
- (UIImage *)thumbnailImage:(CGSize)size;

- (NSInteger)requestOriginImageWithProgressHandler:(PHAssetImageProgressHandler)progressHandler completionHandler:(void (^)(UIImage *image, NSDictionary<NSString *, id> *info))completionHandler;

- (NSInteger)requestPreviewImageWithProgressHandler:(PHAssetImageProgressHandler)progressHandler completionHandler:(void (^)(UIImage *image, NSDictionary<NSString *, id> *info))completionHandler;

- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completionHandler:(void (^)(UIImage *image, NSDictionary<NSString *, id> *info))completionHandler;

- (void)requestImageInfo:(void (^)(NSDictionary *))completionHandler;
@end
