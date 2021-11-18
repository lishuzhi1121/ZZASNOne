//
//  ZZASNSequence.h
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import <Foundation/Foundation.h>
#import <ZZASNOne/ZZASNNodeProtocol.h>

@class  ZZASNObjectIdentifier,
        ZZASNBitString,
        ZZASNOctetString,
        ZZASNInteger,
        ZZASNNull,
        ZZASNAxNode;

@interface ZZASNSequence : NSObject<ZZASNNodeProtocol>

/// 一个 SEQUENCE 中暂定只允许再包含一个 SEQUENCE
@property (nonatomic, strong) ZZASNSequence *sequence;
/// 一个 SEQUENCE 中最多只有一个 OBJECT IDENTIFIER
@property (nonatomic, strong) ZZASNObjectIdentifier *objectIdentifier;
/// 一个 SEQUENCE 中暂定最多只允许一个 NULL
@property (nonatomic, strong) ZZASNNull *asnNull;
/// 一个 SEQUENCE 中暂定最多只允许一个 BIT STRING
@property (nonatomic, strong) ZZASNBitString *bitString;
/// 一个 SEQUENCE 中暂定最多只允许一个 OCTET STRING
@property (nonatomic, strong) ZZASNOctetString *octetString;
/// 一个 SEQUENCE 中可能包含多个 INTEGER
@property (nonatomic, strong) NSMutableArray<ZZASNInteger *> *integers;
/// 一个 SEQUENCE 中可能包含多个 AxNode（这是一种特殊类型）
@property (nonatomic, strong) NSMutableArray<ZZASNAxNode *> *axNodes;

@end

