//
//  HHDataFormatter.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHDataFormatter : NSObject

+ (uint32_t)msgTypeFromData:(NSData *)data;/**< msgType的NSData转换成uint32_t */
+ (NSData *)msgTypeDataFromInteger:(uint32_t)integer;/**< msgType的uint32_t转换成NSData */

+ (uint32_t)msgVersionFromData:(NSData *)data;/**< msgVersion的NSData转换成uint32_t */
+ (NSData *)msgVersionDataFromInteger:(uint32_t)integer;/**< msgVersion的uint32_t转换成NSData */

+ (uint32_t)msgContentLengthFromData:(NSData *)data;/**< msgLength的NSData转换成uint32_t */
+ (NSData *)msgContentLengthDataFromInteger:(uint32_t)integer;/**< msgLength的uint32_t转换成NSData */

+ (uint32_t)msgSerialNumberFromData:(NSData *)data;/**< msgSerialNumber的NSData转换成uint32_t */
+ (NSData *)msgSerialNumberDataFromInteger:(uint32_t)integer;/**< msgSerialNumber的uint32_t转换成NSData */

+ (uint32_t)msgResponseCodeFromData:(NSData *)data;/**< msgResponseCode的NSData转换成int */
+ (NSData *)msgResponseCodeDataFromInteger:(uint32_t)integer;/**< msgResponseCode的int转换成NSData */

+ (NSData *)adler32ToDataWithProtoBuffByte:(Byte *)buffByte length:(uint32_t)length;/**< adler32验证值转换成NSData */

@end

@interface HHTCPSocketResponseParser : NSObject

+ (uint32_t)responseHeaderLength;
+ (uint32_t)responseURLFromData:(NSData *)data;
+ (uint32_t)responseCodeFromData:(NSData *)data;
+ (uint32_t)responseTypeTailFromData:(NSData *)data;
+ (uint32_t)responseSerialNumberFromData:(NSData *)data;
+ (uint32_t)responseContentLengthFromData:(NSData *)data;
+ (NSData *)responseAdlerFromData:(NSData *)data;
+ (NSData *)responseContentFromData:(NSData *)data;

@end
