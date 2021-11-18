//
//  ZZASNOctetString.m
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import "ZZASNOctetString.h"
#import "ZZASNUtils.h"
#import "ZZASNSequence.h"

@implementation ZZASNOctetString

@synthesize length;
@synthesize contentLength;
@synthesize parsedLength;

+ (instancetype)instanceWithData:(NSData *)data {
    ZZASNOctetString *octetString = [[ZZASNOctetString alloc] initWithData:data];
    return octetString;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        [self _parseOctetStringData:data];
    }
    return self;
}

- (void)_parseOctetStringData:(NSData *)data {
    /*
     0x04 0x82 0x02 0x5F ...
     ------------------------------------------------
     第一个字节 0x04 是 OCTET STRING 的开头标识，（OCTET STRING和BIT STRING
     数据类型非常相似。不同之处在于，因为OCTET STRING的尾随字节不能有未使用的位，
     所以不必将前导字节0x00添加到内容中。）
     第二个字节 0x82 如果 OCTET STRING 内容的长度<=127个字节，则该字节的最高位为0，
     其余位表示内容长度。否则最高位为1，其余位表示内容长度将用几个字节表示。
     例如：1. 0x82（1000 0010）最高位为1，说明内容长度超过了127个字节，其余位表示为2，
     说明该OCTET STRING的内容长度要用接下来的2个字节表示，即0x02 0x5F，表示长度为607个字节。
          2. 0x06（0000 0110）最高位为0，说明内容长度不超过127个字节，其余位表示为6，
     说明该OCTET STRING的内容长度就是6个字节。
     第三、四个字节 0x81 表示 OCTET STRING 的内容长度
     */
    // 表示OCTET STRING内容开始字节的偏移量,至少是2（0x03的头+0x06的长度）
    int contentOffset = 2;
    // 读取第二个字节表示长度
    int lenPos = [ZZASNUtils zzReadUInt8FromData:data offset:1];
    int lenHigh = (lenPos & 0x80) >> 7;
    int lenLow = lenPos & 0x7F;
    if (lenHigh == 1) { // 最高位为1
        if (lenLow == 1) {
            // OCTET STRING的内容长度要用接下来的1个字节表示
            self.contentLength = [ZZASNUtils zzReadUInt8FromData:data offset:2];
            // 此时内容的偏移量加1
            contentOffset += 1;
        } else if (lenLow == 2) {
            //OCTET STRING的内容长度要用接下来的2个字节表示
            self.contentLength = [ZZASNUtils zzReadUInt16FromData:data offset:2];
            // 此时内容的偏移量加2
            contentOffset += 2;
        } else {
            // 如果超过两个字节表示的长度,那也是够厉害的了,哈哈哈哈～
            NSAssert(NO, @"暂不支持的OCTET STRING内容长度！");
        }
    } else { // 最高位为0
        // 其余位就表示内容长度, 此时内容的偏移量不用加
        self.contentLength = lenLow;
    }
    // OCTET STRING 整体长度 = 内容长度 + 内容起始偏移量
    self.length = self.contentLength + contentOffset;
    
    // 开始解析内容部分
    self.parsedLength = 0;
    NSData *contentData = [data subdataWithRange:NSMakeRange(contentOffset, self.contentLength)];
    // 记录自身内容
    self.octetStringHexStr = [ZZASNUtils hexStringByData:contentData];
    [self _parseOctetStringContentData:contentData];
    
}

- (void)_parseOctetStringContentData:(NSData *)contentData {
    // 读取内容的第一个字节, 表示内容的类型, 详细定义请看 ZZASNSequence 类
    int contentType = [ZZASNUtils zzReadUInt8FromData:contentData offset:0];
    switch (contentType) {
        case 0x30:
        {
            // SEQUENCE
            self.sequence = [ZZASNSequence instanceWithData:contentData];
            self.parsedLength = self.sequence.length;
            if (self.parsedLength != (self.contentLength)) {
                // 说明当前OCTET STRING还有未解析的内容
                NSRange unparsedRange = NSMakeRange(self.sequence.length, contentData.length - self.sequence.length);
                NSData *subData = [contentData subdataWithRange:unparsedRange];
                [self _parseOctetStringContentData:subData];
            }
            break;
        }
            
        default:
            break;
    }
}

@end
