//
//  HHUploadFile.m
//  HeiHuaBaiHua
//
//  Created by HeiHuaBaiHua on 16/6/6.
//  Copyright © 2016年 HeiHuaBaiHua. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "HHUploadFile.h"

@interface HHUploadFile()

@property (copy, nonatomic) NSString *uploadKey;
@property (copy, nonatomic) NSString *fileName;
@property (copy, nonatomic) NSString *fileType;
@property (copy, nonatomic) NSString *md5String;
@property (strong, nonatomic) NSData *fileData;

@end

@implementation HHUploadFile

- (instancetype)initWithFileData:(NSData *)data fileName:(NSString *)name fileType:(HHUploadFileType)type uploadKey:(NSString *)key {
    if (self = [super init]) {
        
        self.fileData = data;
        self.uploadKey = key;
        
        switch (type) {
            case HHUploadFileTypePng: {
                
                self.fileType = @"image/png";
                self.fileName = [name stringByAppendingString:@".png"];
            }   break;
                
            case HHUploadFileTypeJpg: {
                
                self.fileType = @"image/jpeg";
                self.fileName = [name stringByAppendingString:@".jpeg"];
            }   break;
                
            case HHUploadFileTypeMp3: {
                
                self.fileType = @"audio/mp3";
                self.fileName = [name stringByAppendingString:@".mp3"];
            }   break;
        }
        
    }
    return self;
}

+ (instancetype)pngImageWithFileData:(NSData *)data imageName:(NSString *)name {
    return [[HHUploadFile alloc] initWithFileData:data fileName:name fileType:HHUploadFileTypePng uploadKey:nil];
}

+ (instancetype)jpgImageWithFileData:(NSData *)data imageName:(NSString *)name {
    return [[HHUploadFile alloc] initWithFileData:data fileName:name fileType:HHUploadFileTypeJpg uploadKey:nil];
}

+ (instancetype)mp3AudioWithFileData:(NSData *)data audioName:(NSString *)name {
    return [[HHUploadFile alloc] initWithFileData:data fileName:name fileType:HHUploadFileTypeMp3 uploadKey:nil];
}

+ (instancetype)pngImageWithFileData:(NSData *)data imageName:(NSString *)name uploadKey:(NSString *)key {
    return [[HHUploadFile alloc] initWithFileData:data fileName:name fileType:HHUploadFileTypePng uploadKey:key];
}

+ (instancetype)jpgImageWithFileData:(NSData *)data imageName:(NSString *)name uploadKey:(NSString *)key {
    return [[HHUploadFile alloc] initWithFileData:data fileName:name fileType:HHUploadFileTypeJpg uploadKey:key];
}

+ (instancetype)mp3AudioWithFileData:(NSData *)data audioName:(NSString *)name uploadKey:(NSString *)key {
    return [[HHUploadFile alloc] initWithFileData:data fileName:name fileType:HHUploadFileTypeMp3 uploadKey:key];
}

#pragma mark - Utils

+ (NSString *)md5WithData:(NSData *)data {
    unsigned char result[16];
    CC_MD5(data.bytes, data.length, result); 
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

#pragma mark - Getter

- (NSString *)uploadKey {
    if (!_uploadKey) {
        _uploadKey = self.md5String;
    }
    return _uploadKey;
}

- (NSString *)md5String {
    if (!_md5String) {
        _md5String = self.fileData.length > 0 ? [HHUploadFile md5WithData:self.fileData] : @"";
    }
    return _md5String;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nfileName: %@\nfileType: %@\nuploadKey: %@\nfileLength: %ld",self.fileName,self.fileType,self.uploadKey,self.fileData.length];
}

@end
