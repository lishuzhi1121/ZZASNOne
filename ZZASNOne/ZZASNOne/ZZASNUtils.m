//
//  ZZASNUtils.m
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import "ZZASNUtils.h"

@implementation ZZASNUtils

+ (uint8_t)zzReadUInt8FromData:(NSData *)data offset:(NSInteger)offset {
    if (data.length < offset + 1) {
        return 0;
    }
    
    uint8_t buff[1];
    [data getBytes:&buff range:NSMakeRange(offset, 1)];
    
    return (uint8_t)(buff[0] & 0xff);
}

+ (uint16_t)zzReadUInt16FromData:(NSData *)data offset:(NSInteger)offset {
    if (data.length < offset + 2) {
        return 0;
    }
    
    uint8_t buff[2];
    [data getBytes:&buff range:NSMakeRange(offset, 2)];
    
    return (uint16_t)(((buff[0] & 0xff) << 8) | ((buff[1] & 0xff)));
}

+ (uint32_t)zzReadUInt32FromData:(NSData *)data offset:(NSInteger)offset
{
    if (data.length < offset + 4) {
        return 0;
    }
    
    uint8_t buff[4];
    [data getBytes:&buff range:NSMakeRange(offset, 4)];
    
    return (uint32_t)(((buff[0] & 0xff) << 24) |
                      ((buff[1] & 0xff) << 16) |
                      ((buff[2] & 0xff) <<  8) |
                      ((buff[3] & 0xff)));
}

+ (NSData *)zzBase64DecodeString:(NSString *)str {
    if (![str isKindOfClass:[NSString class]] || str.length == 0) {
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

+ (NSString *)hexStringByData:(NSData *)data {
    if (![data isKindOfClass:[NSData class]] || data.length == 0) {
        return nil;
    }
    
    NSMutableString *hexStr = [NSMutableString string];
    const char *buf = data.bytes;
    for (int i = 0; i < data.length; i++)
    {
        [hexStr appendFormat:@"%02X", buf[i] & 0xff];
    }
    return hexStr;
}

@end
