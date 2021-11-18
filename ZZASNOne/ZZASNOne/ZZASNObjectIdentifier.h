//
//  ZZASNObjectIdentifier.h
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import <Foundation/Foundation.h>
#import <ZZASNOne/ZZASNNodeProtocol.h>

@interface ZZASNObjectIdentifier : NSObject<ZZASNNodeProtocol>

/// 用于表示OBJECT IDENTIFIER的16进制字符串（后续可将其转为点分十进制字符串）
@property (nonatomic, copy) NSString *objectIdentiferHexStr;

@end

