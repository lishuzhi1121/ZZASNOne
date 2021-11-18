//
//  ZZASNAxNode.m
//  ZZASNOne
//
//  Created by SandsLee on 2021/11/18.
//

#import "ZZASNAxNode.h"
#import "ZZASNUtils.h"
#import "ZZASNObjectIdentifier.h"
#import "ZZASNBitString.h"

@implementation ZZASNAxNode

@synthesize length;
@synthesize contentLength;
@synthesize parsedLength;

+ (instancetype)instanceWithData:(NSData *)data {
    ZZASNAxNode *ax = [[ZZASNAxNode alloc] initWithData:data];
    return ax;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        [self _parseAxData:data];
    }
    return self;
}

- (void)_parseAxData:(NSData *)data {
    /*
     0xA0 0x0A ...
     0xA1 0x44 ...
     ------------------------------------------------
     第一个字节 0xA0/0xA1 是 Ax 类型节点的开头标识
     第二个字节 0x0A/0x44 表示 Ax 类型节点的内容长度
     */
    // 表示Ax内容开始字节的偏移量,至少是2（0xA0的头+0x0A的长度）
    int contentOffset = 2;
    // 读取第二个字节表示长度
    int lenPos = [ZZASNUtils zzReadUInt8FromData:data offset:1];
    self.contentLength = lenPos;
    // Ax 整体长度 = 内容长度 + 内容起始偏移量
    self.length = self.contentLength + contentOffset;
    
    // 开始解析内容部分
    self.parsedLength = 0;
    NSData *contentData = [data subdataWithRange:NSMakeRange(contentOffset, self.contentLength)];
    [self _parseAxContentData:contentData];
    
}

- (void)_parseAxContentData:(NSData *)contentData {
    // 读取内容的第一个字节, 表示内容的类型, 详细定义请看 ZZASNSequence 类
    id<ZZASNNodeProtocol> currentNode = nil;
    int contentType = [ZZASNUtils zzReadUInt8FromData:contentData offset:0];
    switch (contentType) {
        case 0x03:
        {
            // BIT STRING
            self.bitString = [ZZASNBitString bitStringWithData:contentData];
            currentNode = self.bitString;
            break;
        }
        case 0x06:
        {
            // OBJECT IDENTIFIER
            self.objectIdentifier = [ZZASNObjectIdentifier instanceWithData:contentData];
            currentNode = self.objectIdentifier;
            break;
        }
            
        default:
            break;
    }
    
    // 判断当前节点内容是否解析完成
    self.parsedLength += currentNode.length;
    if (self.parsedLength != self.contentLength) {
        // 说明当前Ax还有未解析的内容
        NSRange unparsedRange = NSMakeRange(currentNode.length, contentData.length - currentNode.length);
        NSData *subData = [contentData subdataWithRange: unparsedRange];
        // 递归解析余下内容
        [self _parseAxContentData:subData];
    }
    
}

@end
