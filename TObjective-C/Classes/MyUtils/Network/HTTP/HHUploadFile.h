//
//  HHUploadFile.h
//  HeiHuaBaiHua
//
//  Created by HeiHuaBaiHua on 16/6/6.
//  Copyright © 2016年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    HHUploadFileTypePng,
    HHUploadFileTypeJpg,
    HHUploadFileTypeMp3
} HHUploadFileType;

@interface HHUploadFile : NSObject

+ (instancetype)pngImageWithFileData:(NSData *)data imageName:(NSString *)name;/**< 默认以data的md5值做uploadKey */
+ (instancetype)jpgImageWithFileData:(NSData *)data imageName:(NSString *)name;/**< 默认以data的md5值做uploadKey */
+ (instancetype)mp3AudioWithFileData:(NSData *)data audioName:(NSString *)name;/**< 默认以data的md5值做uploadKey */
+ (instancetype)pngImageWithFileData:(NSData *)data imageName:(NSString *)name uploadKey:(NSString *)key;
+ (instancetype)jpgImageWithFileData:(NSData *)data imageName:(NSString *)name uploadKey:(NSString *)key;
+ (instancetype)mp3AudioWithFileData:(NSData *)data audioName:(NSString *)name uploadKey:(NSString *)key;

- (instancetype)initWithFileData:(NSData *)data fileName:(NSString *)name fileType:(HHUploadFileType)type uploadKey:(NSString *)key;

- (NSData *)fileData;
- (NSString *)fileName;
- (NSString *)fileType;
- (NSString *)uploadKey;
- (NSString *)md5String;
@end
