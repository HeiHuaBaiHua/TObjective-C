//
//  HHDataFormatter.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHDataFormatter : NSObject

+ (int)msgTypeFromData:(NSData *)data;/**< msgType的NSData转换成int */
+ (NSData *)msgTypeDataFromInteger:(int)integer;/**< msgType的int转换成NSData */

+ (int)msgContentLengthFromData:(NSData *)data;/**< msgLength的NSData转换成int */
+ (NSData *)msgContentLengthDataFromInteger:(int)integer;/**< msgLength的int转换成NSData */

+ (int)msgSerialNumberFromData:(NSData *)data;/**< msgSerialNumber的NSData转换成int */
+ (NSData *)msgSerialNumberDataFromInteger:(int)integer;/**< msgSerialNumber的int转换成NSData */

+ (int)msgResponseCodeFromData:(NSData *)data;/**< msgResponseCode的NSData转换成int */
+ (NSData *)msgResponseCodeDataFromInteger:(int)integer;/**< msgResponseCode的int转换成NSData */

+ (NSData *)adler32ToDataWithProtoBuffByte:(Byte *)buffByte length:(int)length;/**< adler32验证值转换成NSData */

@end

@interface HHTCPSocketResponseFormatter : NSObject

+ (instancetype)formatterWithResponseData:(NSData *)data;

+ (int)responseTypeFromData:(NSData *)data;
+ (int)responseCodeFromData:(NSData *)data;
+ (int)responseTypeTailFromData:(NSData *)data;
+ (int)responseSerialNumberFromData:(NSData *)data;
+ (int)responseContentLengthFromData:(NSData *)data;
+ (NSData *)responseAdlerFromData:(NSData *)data;
+ (NSData *)responseContentFromData:(NSData *)data;

- (int)responseType;
- (int)responseCode;
- (int)responseTypeTail;
- (int)responseSerialNumber;
- (int)responseContentLength;
- (NSData *)responseAdler;
- (NSData *)responseContent;

@end
