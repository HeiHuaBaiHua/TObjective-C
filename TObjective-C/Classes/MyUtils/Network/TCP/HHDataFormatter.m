//
//  HHDataFormatter.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#define BASE 65521UL
/* use NO_DIVIDE if your processor does not do division in hardware */
#ifdef NO_DIVIDE
/* use NO_SHIFT if your processor does shift > 1 by loop */
#  ifdef NO_SHIFT
#    define reduce_full(a) \
do { \
if (a >= (BASE << 16)) a -= (BASE << 16); \
if (a >= (BASE << 15)) a -= (BASE << 15); \
if (a >= (BASE << 14)) a -= (BASE << 14); \
if (a >= (BASE << 13)) a -= (BASE << 13); \
if (a >= (BASE << 12)) a -= (BASE << 12); \
if (a >= (BASE << 11)) a -= (BASE << 11); \
if (a >= (BASE << 10)) a -= (BASE << 10); \
if (a >= (BASE << 9)) a -= (BASE << 9); \
if (a >= (BASE << 8)) a -= (BASE << 8); \
if (a >= (BASE << 7)) a -= (BASE << 7); \
if (a >= (BASE << 6)) a -= (BASE << 6); \
if (a >= (BASE << 5)) a -= (BASE << 5); \
if (a >= (BASE << 4)) a -= (BASE << 4); \
if (a >= (BASE << 3)) a -= (BASE << 3); \
if (a >= (BASE << 2)) a -= (BASE << 2); \
if (a >= (BASE << 1)) a -= (BASE << 1); \
if (a >= BASE) a -= BASE; \
} while (0)
#    define reduce_x(a) \
do { \
if (MIN_WORK > (1 << 5) && a >= (BASE << 6)) a -= (BASE << 6); \
if (MIN_WORK > (1 << 4) && a >= (BASE << 5)) a -= (BASE << 5); \
if (a >= (BASE << 4)) a -= (BASE << 4); \
if (a >= (BASE << 3)) a -= (BASE << 3); \
if (a >= (BASE << 2)) a -= (BASE << 2); \
if (a >= (BASE << 1)) a -= (BASE << 1); \
if (a >= BASE) a -= BASE; \
} while (0)
#    define reduce(a) reduce_full(a)
#  else
#    define reduce_full(a) \
do { \
unsigned long b = a & 0x0000ffff; \
a >>= 16; \
b -= a; \
a <<= 4; \
a += b; \
a = a >= BASE ? a - BASE : a; \
} while(a >= BASE)
#    define reduce_x(a) \
do { \
unsigned long b = a & 0x0000ffff; \
a >>= 16; \
b -= a; \
a <<= 4; \
a += b; \
a = a >= BASE ? a - BASE : a; \
} while(0)
#    define reduce(a) \
do { \
unsigned long b = a & 0x0000ffff; \
a >>= 16; \
b -= a; \
a <<= 4; \
a += b; \
} while(0)
#  endif
#else
#  define reduce_full(a) a %= BASE
#  define reduce_x(a) a %= BASE
#  define reduce(a) a %= BASE
#endif

#import <CommonCrypto/CommonDigest.h>

#import "HHDataFormatter.h"

#define SessionIdLength (0)/** SessionId的长度 */
#define MsgTypeLength (4)/** 消息类型的长度 */
#define MsgVersionLength (4)/** 协议版本号的长度 */
#define MsgSerialNumberLength (4)/** 消息序号的长度 */
#define MsgResponseCodeLength (4)/** 消息响应状态码的长度 */
#define MsgContentLength (4)/** 消息有效载荷的长度 */
#define Adler32Length (32)/** Adler32的长度 */
#define MsgResponseHeaderLength (MsgTypeLength + MsgSerialNumberLength + MsgResponseCodeLength + MsgContentLength)/** 消息响应的头部长度 */

@implementation HHDataFormatter

+ (NSData *)dataFromInteger4:(uint32_t)integer {
    
    uint32_t time = integer;
    char *p_time = (char *)&time;
    static char str_time[4] = {0};
    for(int i = 4 - 1; i >= 0; i--) {
        str_time[i] = *p_time;
        p_time ++;
    }
    return [NSData dataWithBytes:&str_time length:4];
}

+ (int)integer4FromData:(NSData *)data {
    char *dataChar = (char *)data.bytes;
    char *index = (char *)&dataChar;
    char typeChar[4] = {0};
    for (int i = 0 ; i < data.length; i++) {
        typeChar[4 - 1 - i] = dataChar[i];
        index ++;
    }
    
    int integer;
    NSData *typeData = [NSData dataWithBytes:typeChar length:4];
    [typeData getBytes:&integer length:4];
    return integer;
}

+ (NSData *)msgTypeDataFromInteger:(uint32_t)integer {
    return [self dataFromInteger4:integer];
}

+ (uint32_t)msgTypeFromData:(NSData *)data {
    return [self integer4FromData:data];
}

+ (uint32_t)msgVersionFromData:(NSData *)data {
    return [self integer4FromData:data];
}

+ (NSData *)msgVersionDataFromInteger:(uint32_t)integer {
    return [self dataFromInteger4:integer];
}

+ (NSData *)msgContentLengthDataFromInteger:(uint32_t)integer {
    return [self dataFromInteger4:integer];
}

+ (uint32_t)msgContentLengthFromData:(NSData *)data {
    return [self integer4FromData:data];
}

+ (uint32_t)msgSerialNumberFromData:(NSData *)data {
    return [self integer4FromData:data];
}

+ (NSData *)msgSerialNumberDataFromInteger:(uint32_t)integer {
    return [self dataFromInteger4:integer];
}

+ (uint32_t)msgResponseCodeFromData:(NSData *)data {
    return [self integer4FromData:data];
}

+ (NSData *)msgResponseCodeDataFromInteger:(uint32_t)integer {
    return [self dataFromInteger4:integer];
}

+ (NSData *)adler32ToDataWithProtoBuffByte:(Byte *)buffByte length:(uint32_t)length {

    //Adler32编码，需要低位移位运算
    uint64_t checkValue = av_adler32_update(1, buffByte, length);
    uint64_t time = checkValue;
    char *p_time = (char *)&time;
    static char checkValueChar[Adler32Length] = {0};
    for(int i = Adler32Length - 1; i >= 0; i--) {
        checkValueChar[i] = *p_time;
        p_time ++;
    }
    NSData *AdlerData = [NSData dataWithBytes:&checkValueChar length:Adler32Length];
    return AdlerData;
}

/** adler32的验证转换方法 */
#define DO1(buf)  { s1 += *buf++; s2 += s1; }
#define DO4(buf)  DO1(buf); DO1(buf); DO1(buf); DO1(buf);
#define DO16(buf) DO4(buf); DO4(buf); DO4(buf); DO4(buf);
unsigned long av_adler32_update (unsigned long adler, const uint8_t * buf, unsigned int len) {
    unsigned long s1 = adler & 0xffff;
    unsigned long s2 = adler >> 16;
    while (len > 0) {
#if HAVE_FAST_64BIT && HAVE_FAST_UNALIGNED && !CONFIG_SMALL
        unsigned len2 = FFMIN((len-1) & ~7, 23*8);
        if (len2) {
            uint64_t a1= 0;
            uint64_t a2= 0;
            uint64_t b1= 0;
            uint64_t b2= 0;
            len -= len2;
            s2 += s1*len2;
            while (len2 >= 8) {
                uint64_t v = AV_RN64(buf);
                a2 += a1;
                b2 += b1;
                a1 +=  v    &0x00FF00FF00FF00FF;
                b1 += (v>>8)&0x00FF00FF00FF00FF;
                len2 -= 8;
                buf+=8;
            }
            
            //We combine the 8 interleaved adler32 checksums without overflows
            //Decreasing the number of iterations would allow below code to be
            //simplified but would likely be slower due to the fewer iterations
            //of the inner loop
            s1 += ((a1+b1)*0x1000100010001)>>48;
            s2 += ((((a2&0xFFFF0000FFFF)+(b2&0xFFFF0000FFFF)+((a2>>16)&0xFFFF0000FFFF)+((b2>>16)&0xFFFF0000FFFF))*0x800000008)>>32)
#if HAVE_BIGENDIAN
            + 2*((b1*0x1000200030004)>>48)
            +   ((a1*0x1000100010001)>>48)
            + 2*((a1*0x0000100020003)>>48);
#else
            + 2*((a1*0x4000300020001)>>48)
            +   ((b1*0x1000100010001)>>48)
            + 2*((b1*0x3000200010000)>>48);
#endif
        }
#else
        while (len > 4  && s2 < (1U << 31)) {
            DO4(buf);
            len -= 4;
        }
#endif
        DO1(buf); len--;
        s1 %= BASE;
        s2 %= BASE;
    }
    return (s2 << 16) | s1;
}

@end

@interface HHTCPSocketResponseParser ()

@property (nonatomic, strong) NSData *responseData;

@end


@implementation HHTCPSocketResponseParser

+ (uint32_t)responseHeaderLength {
    return MsgResponseHeaderLength;
}

+ (uint32_t)responseURLFromData:(NSData *)data {
    return [HHDataFormatter msgTypeFromData:[data subdataWithRange:NSMakeRange(0, MsgTypeLength)]];
}

+ (uint32_t)responseCodeFromData:(NSData *)data {
    return [HHDataFormatter msgResponseCodeFromData:[data subdataWithRange:NSMakeRange(MsgTypeLength + MsgSerialNumberLength, MsgResponseCodeLength)]];
}

+ (uint32_t)responseTypeTailFromData:(NSData *)data {
    
    int msgResponseLength = [self responseContentLengthFromData:data] + MsgResponseHeaderLength;
    return [HHDataFormatter msgTypeFromData:[data subdataWithRange:NSMakeRange(msgResponseLength - MsgTypeLength, MsgTypeLength)]];
}

+ (uint32_t)responseSerialNumberFromData:(NSData *)data {
    return [HHDataFormatter msgSerialNumberFromData:[data subdataWithRange:NSMakeRange(MsgTypeLength, MsgSerialNumberLength)]];
}

+ (uint32_t)responseContentLengthFromData:(NSData *)data {
    return [HHDataFormatter msgContentLengthFromData:[data subdataWithRange:NSMakeRange(MsgResponseHeaderLength - MsgContentLength, MsgContentLength)]];
}

+ (NSData *)responseAdlerFromData:(NSData *)data {
    return [data subdataWithRange:NSMakeRange(MsgResponseHeaderLength + [self responseContentLengthFromData:data], Adler32Length)];
}

+ (NSData *)responseContentFromData:(NSData *)data {
    return [data subdataWithRange:NSMakeRange(MsgResponseHeaderLength, [self responseContentLengthFromData:data])];
}

@end
