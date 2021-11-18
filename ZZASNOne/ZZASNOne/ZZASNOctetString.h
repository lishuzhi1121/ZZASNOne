//
//  ZZASNOctetString.h
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import <Foundation/Foundation.h>
#import <ZZASNOne/ZZASNNodeProtocol.h>

@class ZZASNSequence;

@interface ZZASNOctetString : NSObject<ZZASNNodeProtocol>

/// 一个 OCTET STRING 中暂定只允许包含一个 SEQUENCE
@property (nonatomic, strong) ZZASNSequence *sequence;

/// OCTET STRING 自身内容的16进制字符串
@property (nonatomic, copy) NSString *octetStringHexStr;

@end

