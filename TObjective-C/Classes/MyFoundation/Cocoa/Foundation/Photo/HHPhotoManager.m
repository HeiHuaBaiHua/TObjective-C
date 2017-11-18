//
//  HHPhotoManager.m
//  Test
//
//  Created by leihaiyin on 2017/11/9.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHPhotoManager.h"

@interface HHPhotoManager ()

@property (nonatomic, assign) BOOL isAuthorized;

@end

@implementation HHPhotoManager

+ (instancetype)sharedManager {
    static HHPhotoManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [super allocWithZone:NULL];
    });
    return sharedManager;
}

- (void)checkAuthorizationStatusWithCompletionHandler:(void(^)(BOOL))handler {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    self.isAuthorized = (status == PHAuthorizationStatusAuthorized);
    if (status != PHAuthorizationStatusNotDetermined) {
        !handler ?: handler(self.isAuthorized);
    } else {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
            
            self.isAuthorized = (authorizationStatus == PHAuthorizationStatusAuthorized);
            !handler ?: handler(self.isAuthorized);
        }];
    }
}

#pragma mark - Albums

- (NSArray<PHAssetCollection *> *)allPhotoAlbums {
    if (!self.isAuthorized) { return nil; }
    
    NSArray *firstAlbums = @[NSLocalizedString(HHPhotoAlbumAllPhotos, @""),
                             NSLocalizedString(HHPhotoAlbumCameraRoll, @"")];
    NSArray *ignoreAlbums = @[NSLocalizedString(HHPhotoAlbumHidden, @""),
                              NSLocalizedString(HHPhotoAlbumRecentlyDeleted, @"")];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *topLevelAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    NSMutableArray *albums = [NSMutableArray array];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.estimatedAssetCount == 0 ||
            [ignoreAlbums containsObject:obj.localizedTitle]) { return; }
        
        if (albums.count > 0 && [firstAlbums containsObject:obj.localizedTitle]) {
            [albums insertObject:obj atIndex:0];
        } else {
            [albums addObject:obj];
        }
    }];
    [topLevelAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.estimatedAssetCount == 0) { return ; }
        
        [albums addObject:obj];
    }];
    return albums;
}

#pragma mark - Photos

- (NSArray<PHAsset *> *)allPhotos {
    if (!self.isAuthorized) { return nil; }
    
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    return (NSArray *)[PHAsset fetchAssetsWithOptions:options];
}

- (NSArray<PHAsset *> *)photosInAlbum:(PHAssetCollection *)album {
    if (!self.isAuthorized || !album) { return nil; }
    
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    return (NSArray *)[PHAsset fetchAssetsInAssetCollection:album options:options];
}

@end

#pragma mark - PHAsset Image
@implementation PHAsset(Image)

- (UIImage *)originImage {
    if (![self isImage]) { return nil; }
    
    __block UIImage *image = nil;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    [[PHCachingImageManager defaultManager] requestImageForAsset:self targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        image = result;
    }];
    return image;
}

- (UIImage *)previewImage {
    if (![self isImage]) { return nil; }
    
    __block UIImage *image = nil;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    [[PHCachingImageManager defaultManager] requestImageForAsset:self targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        image = result;
    }];
    return image;
}

- (UIImage *)thumbnailImage:(CGSize)size {
    if (![self isImage]) { return nil; }
    
    __block UIImage *image = nil;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    CGFloat scale = [UIScreen mainScreen].scale;
    [[PHCachingImageManager defaultManager] requestImageForAsset:self targetSize:CGSizeMake(size.width * scale, size.height * scale) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        image = result;
    }];
    return image;
}

- (NSInteger)requestOriginImageWithProgressHandler:(PHAssetImageProgressHandler)progressHandler completionHandler:(void (^)(UIImage *, NSDictionary<NSString *,id> *))completionHandler {
    if (!completionHandler) { return -1; }
    if (![self isImage]) {
        completionHandler(nil, nil); return -1;
    }
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.progressHandler = progressHandler;
    return [[PHCachingImageManager defaultManager] requestImageForAsset:self targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        !completionHandler ?: completionHandler(result, info);
    }];
}

- (NSInteger)requestPreviewImageWithProgressHandler:(PHAssetImageProgressHandler)progressHandler completionHandler:(void (^)(UIImage *, NSDictionary<NSString *,id> *))completionHandler {
    if (!completionHandler) { return -1; }
    if (![self isImage]) {
        completionHandler(nil, nil); return -1;
    }
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.progressHandler = progressHandler;
    return [[PHCachingImageManager defaultManager] requestImageForAsset:self targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        !completionHandler ?: completionHandler(result, info);
    }];
}

- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completionHandler:(void (^)(UIImage *, NSDictionary<NSString *,id> *))completionHandler {
    if (!completionHandler) { return -1; }
    if (![self isImage]) {
        completionHandler(nil, nil); return -1;
    }
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    CGFloat scale = [UIScreen mainScreen].scale;
    return [[PHCachingImageManager defaultManager] requestImageForAsset:self targetSize:CGSizeMake(size.width * scale, size.height * scale) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        !completionHandler ?: completionHandler(result, info);
    }];
}

- (void)requestImageInfo:(void (^)(NSDictionary *))completionHandler {
    if (!completionHandler) { return; }
    if (![self isImage]) {
        completionHandler(nil); return;
    }
    
    PHImageRequestOptions *imageRequestOptions = [PHImageRequestOptions new];
    imageRequestOptions.networkAccessAllowed = YES;
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:self options:imageRequestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [result setObject:@(orientation) forKey:kPHAssetImageOrientation];
        !info ?: [result setObject:info forKey:kPHAssetImageInfo];
        !dataUTI ?: [result setObject:dataUTI forKey:kPHAssetImageDataUTI];
        if (imageData) {
            
            [result setObject:imageData forKey:kPHAssetImageData];
            [result setObject:@(imageData.length) forKey:kPHAssetImageSize];
        }
        completionHandler(result);
    }];
}

#pragma mark - Utils

- (BOOL)isImage {
    
    if (@available(iOS 9.1, *)) {
        return self.mediaType == PHAssetMediaTypeImage && self.mediaSubtypes != PHAssetMediaSubtypePhotoLive;
    } else {
        return self.mediaType == PHAssetMediaTypeImage;
    }
}

@end
