//
//  ZZASNOne.h
//  ZZASNOne
//
//  Created by SandsLee on 2021/11/17.
//

#import <Foundation/Foundation.h>

//! Project version number for ZZASNOne.
FOUNDATION_EXPORT double ZZASNOneVersionNumber;

//! Project version string for ZZASNOne.
FOUNDATION_EXPORT const unsigned char ZZASNOneVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ZZASNOne/PublicHeader.h>
#import <ZZASNOne/ZZASNNodeProtocol.h>
#import <ZZASNOne/ZZASNSequence.h>
#import <ZZASNOne/ZZASNObjectIdentifier.h>
#import <ZZASNOne/ZZASNBitString.h>
#import <ZZASNOne/ZZASNOctetString.h>
#import <ZZASNOne/ZZASNInteger.h>
#import <ZZASNOne/ZZASNNull.h>
#import <ZZASNOne/ZZASNAxNode.h>

/// ASN.1 语法文件对象
/// https://docs.microsoft.com/en-us/windows/win32/seccertenroll/about-asn-1-type-system
@interface ZZASNOne : NSObject

/// 一般ASN.1语法的内容以一个SEQUENCE开始, 类似于JSON的{}或者[]
@property (nonatomic, strong) ZZASNSequence *sequence;

/// 加载一个ASN.1语法格式的文件, 成功加载后内容将装载到 sequence 属性中
/// @param filePath 文件路径
+ (instancetype)loadWithContentsOfFile:(NSString *)filePath;

@end
