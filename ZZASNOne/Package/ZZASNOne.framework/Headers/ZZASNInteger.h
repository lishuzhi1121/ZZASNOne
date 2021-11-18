//
//  ZZASNInteger.h
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import <Foundation/Foundation.h>
#import <ZZASNOne/ZZASNNodeProtocol.h>


@interface ZZASNInteger : NSObject<ZZASNNodeProtocol>

/// 表示 INTEGER 数字内容的16进制字符串
@property (nonatomic, copy) NSString *integerHexStr;

@end

