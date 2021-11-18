//
//  ZZASNUtils.h
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import <Foundation/Foundation.h>

@interface ZZASNUtils : NSObject

/// 从NSData中读取一个8位无符号整数
/// @param data data
/// @param offset 偏移量
+ (uint8_t)zzReadUInt8FromData:(NSData *)data offset:(NSInteger)offset;

/// 从NSData中读取一个16位无符号整数
/// @param data data
/// @param offset 偏移量
+ (uint16_t)zzReadUInt16FromData:(NSData *)data offset:(NSInteger)offset;

/// 从NSData中读取一个32位无符号整数
/// @param data data
/// @param offset 偏移量
+ (uint32_t)zzReadUInt32FromData:(NSData *)data offset:(NSInteger)offset;

/// Base64解码
/// @param str base64字符串
+ (NSData *)zzBase64DecodeString:(NSString *)str;

/// NSData 转16进制字符串
/// @param data data
+ (NSString *)hexStringByData:(NSData *)data;


@end
