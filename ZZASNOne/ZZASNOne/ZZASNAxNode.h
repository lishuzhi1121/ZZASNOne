//
//  ZZASNAxNode.h
//  ZZASNOne
//
//  Created by SandsLee on 2021/11/18.
//

#import <Foundation/Foundation.h>
#import <ZZASNOne/ZZASNNodeProtocol.h>

@class ZZASNObjectIdentifier, ZZASNBitString;

@interface ZZASNAxNode : NSObject<ZZASNNodeProtocol>

/// 一个 Ax 中最多只有一个 OBJECT IDENTIFIER
@property (nonatomic, strong) ZZASNObjectIdentifier *objectIdentifier;

/// 一个 Ax 中暂定最多只允许一个 BIT STRING
@property (nonatomic, strong) ZZASNBitString *bitString;

@end

