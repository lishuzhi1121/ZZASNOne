//
//  ZZASNSequence.m
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import "ZZASNSequence.h"
#import "ZZASNUtils.h"
#import "ZZASNObjectIdentifier.h"
#import "ZZASNNull.h"
#import "ZZASNBitString.h"
#import "ZZASNInteger.h"
#import "ZZASNOctetString.h"
#import "ZZASNAxNode.h"

@implementation ZZASNSequence

@synthesize length;
@synthesize contentLength;
@synthesize parsedLength;

+ (instancetype)instanceWithData:(NSData *)data {
    ZZASNSequence *sequence = [[ZZASNSequence alloc] initWithData:data];
    return sequence;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        [self _parseSequenceData:data];
    }
    return self;
}

- (void)_parseSequenceData:(NSData *)data {
    /*
     0x30 0x82 0x01 0x01 ...
     ------------------------------------------------
     第一个字节 0x30 是SEQUENCE的开头标识
     第二个字节 0x82 如果SEQUENCE内容的长度<=127个字节，则该字节的最高位为0，
     其余位表示内容长度。否则最高位为1，其余位表示内容长度将用几个字节表示。
     例如：1. 0x82（1000 0010）最高位为1，说明内容长度超过了127个字节，其余位表示为2，
     说明该SEQUENCE的内容长度要用接下来的2个字节表示，即0x01 0x01，表示长度为257个字节。
          2. 0x03（0000 0011）最高位为0，说明内容长度不超过127个字节，其余位表示为3，
     说明该SEQUENCE的内容长度就是3个字节。
     */
    // 表示SEQUENCE内容开始字节的偏移量,至少是2（0x30的头+0x03的长度）
    int contentOffset = 2;
    // 读取第二个字节表示长度
    int lenPos = [ZZASNUtils zzReadUInt8FromData:data offset:1];
    int lenHigh = (lenPos & 0x80) >> 7;
    int lenLow = lenPos & 0x7F;
    if (lenHigh == 1) { // 最高位为1
        if (lenLow == 1) {
            // SEQUENCE的内容长度要用接下来的1个字节表示
            self.contentLength = [ZZASNUtils zzReadUInt8FromData:data offset:2];
            // 此时内容的偏移量加1
            contentOffset += 1;
        } else if (lenLow == 2) {
            //SEQUENCE的内容长度要用接下来的2个字节表示
            self.contentLength = [ZZASNUtils zzReadUInt16FromData:data offset:2];
            // 此时内容的偏移量加2
            contentOffset += 2;
        } else {
            NSAssert(NO, @"暂不支持的SEQUENCE内容长度！");
        }
    } else { // 最高位为0
        // 其余位就表示内容长度, 此时内容的偏移量不用加
        self.contentLength = lenLow;
    }
    // SEQUENCE 整体长度 = 内容长度 + 内容起始偏移量
    self.length = self.contentLength + contentOffset;
    
    // 开始解析内容部分
    self.parsedLength = 0;
    NSData *contentData = [data subdataWithRange:NSMakeRange(contentOffset, self.contentLength)];
    [self _parseSequenceContentData:contentData];
}

- (void)_parseSequenceContentData:(NSData *)contentData {
    /*
     读取内容的第一个字节,表示内容的类型:
     https://docs.microsoft.com/en-us/windows/win32/seccertenroll/about-der-encoding-of-asn-1-types
     0x01: BOOLEAN
     0x02: INTEGER
     0x03: BIT STRING
     0x04: OCTET STRING
     0x05: NULL
     0x06: OBJECT IDENTIFIER
     0x0C: UTF8String
     0x13: PrintableString
     0x16: IA5tring
     0x1E: BMPString
     0x30: SEQUENCE
     0x31: SET
     */
    id<ZZASNNodeProtocol> currentNode = nil;
    int contentType = [ZZASNUtils zzReadUInt8FromData:contentData offset:0];
    switch (contentType) {
        case 0x02:
        {
            // INTEGER
            ZZASNInteger * integer = [ZZASNInteger instanceWithData:contentData];
            [self.integers addObject:integer];
            currentNode = integer;
            break;
        }
        case 0x03:
        {
            // BIT STRING
            self.bitString = [ZZASNBitString instanceWithData:contentData];
            currentNode = self.bitString;
            break;
        }
        case 0x04:
        {
            // OCTET STRING
            self.octetString = [ZZASNOctetString instanceWithData:contentData];
            currentNode = self.octetString;
            break;
        }
        case 0x05:
        {
            // NULL
            self.asnNull = [ZZASNNull instanceWithData:contentData];
            currentNode = self.asnNull;
            break;
        }
        case 0x06:
        {
            // OBJECT IDENTIFIER
            self.objectIdentifier = [ZZASNObjectIdentifier instanceWithData:contentData];
            currentNode = self.objectIdentifier;
            break;
        }
        case 0x30:
        {
            // SEQUENCE
            self.sequence = [ZZASNSequence instanceWithData:contentData];
            currentNode = self.sequence;
            break;
        }
        case 0xA0:
        case 0xA1:
        {
            // AxNode
            ZZASNAxNode * ax = [ZZASNAxNode instanceWithData:contentData];
            [self.axNodes addObject:ax];
            currentNode = ax;
            break;
        }
            
        default:
            break;
    }
    
    // 判断当前节点内容是否解析完成
    self.parsedLength += currentNode.length;
    if (self.parsedLength != self.contentLength) {
        // 说明当前SEQUENCE还有未解析的内容
        NSRange unparsedRange = NSMakeRange(currentNode.length, contentData.length - currentNode.length);
        NSData *subData = [contentData subdataWithRange: unparsedRange];
        // 递归解析余下内容
        [self _parseSequenceContentData:subData];
    }
    
}

#pragma mark - getter

- (NSMutableArray<ZZASNInteger *> *)integers {
    if (!_integers) {
        _integers = [NSMutableArray array];
    }
    return _integers;
}

- (NSMutableArray<ZZASNAxNode *> *)axNodes {
    if (!_axNodes) {
        _axNodes = [NSMutableArray array];
    }
    return _axNodes;
}

@end
