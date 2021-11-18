//
//  ZZASNBitString.h
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import <Foundation/Foundation.h>
#import <ZZASNOne/ZZASNNodeProtocol.h>

@class ZZASNSequence;

@interface ZZASNBitString : NSObject<ZZASNNodeProtocol>

/// 一个 BIT STRING 中暂定只允许包含一个 SEQUENCE
@property (nonatomic, strong) ZZASNSequence *sequence;

/// BIT STRING 自身内容的16进制字符串
@property (nonatomic, copy) NSString *bitStringHexStr;

/// 构造方法，当且仅当只需要使用BIT STRING自身内容的16进制字符串时
/// 使用该构造方法表示不需要解析BIT STRING节点的内容部分
/// @param data 数据
+ (instancetype)bitStringWithData:(NSData *)data;

@end

