//
//  ZZASNBitString.m
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import "ZZASNBitString.h"
#import "ZZASNUtils.h"
#import "ZZASNSequence.h"

@implementation ZZASNBitString

@synthesize length;
@synthesize contentLength;
@synthesize parsedLength;

+ (instancetype)instanceWithData:(NSData *)data {
    ZZASNBitString *bitString = [[ZZASNBitString alloc] initWithData:data expand:YES];
    return bitString;
}

+ (instancetype)bitStringWithData:(NSData *)data {
    ZZASNBitString *bitString = [[ZZASNBitString alloc] initWithData:data expand:NO];
    return bitString;
}

- (instancetype)initWithData:(NSData *)data expand:(BOOL)expand {
    if (self = [super init]) {
        [self _parseBitStringData:data expand:expand];
    }
    return self;
}

- (void)_parseBitStringData:(NSData *)data expand:(BOOL)expand {
    /*
     0x03 0x81 0x81 0x00 ...
     ------------------------------------------------
     第一个字节 0x03 是 BIT STRING 的开头标识
     第二个字节 0x81 如果 BIT STRING 内容的长度<=127个字节，则该字节的最高位为0，
     其余位表示内容长度。否则最高位为1，其余位表示内容长度将用几个字节表示。
     例如：1. 0x81（1000 0001）最高位为1，说明内容长度超过了127个字节，其余位表示为1，
     说明该BIT STRING的内容长度要用接下来的1个字节表示，即0x81，表示长度为129个字节。
          2. 0x06（0000 0110）最高位为0，说明内容长度不超过127个字节，其余位表示为6，
     说明该BIT STRING的内容长度就是6个字节。
     第三个字节 0x81 表示 BIT STRING 的内容长度
     第四个字节 0x00 用于指定存在于内容中的最后一个字节中的未使用位数。
        如果传输的数据bit数恰好是8的倍数，则设置为0，表示所有bit位都要使用。
        如果想要舍弃传输的数据中最后一个字节的后5位，则应该设置为0x05 。
     */
    // 表示BIT STRING内容开始字节的偏移量,至少是2（0x03的头+0x06的长度）
    int contentOffset = 2;
    // 读取第二个字节表示长度
    int lenPos = [ZZASNUtils zzReadUInt8FromData:data offset:1];
    int lenHigh = (lenPos & 0x80) >> 7;
    int lenLow = lenPos & 0x7F;
    if (lenHigh == 1) { // 最高位为1
        if (lenLow == 1) {
            // BIT STRING的内容长度要用接下来的1个字节表示
            self.contentLength = [ZZASNUtils zzReadUInt8FromData:data offset:2];
            // 此时内容的偏移量加1
            contentOffset += 1;
            
        } else if (lenLow == 2) {
            //BIT STRING的内容长度要用接下来的2个字节表示
            self.contentLength = [ZZASNUtils zzReadUInt16FromData:data offset:2];
            // 此时内容的偏移量加2
            contentOffset += 2;
            
        } else {
            // 如果超过两个字节表示的长度,那也是够厉害的了,哈哈哈哈～
            NSAssert(NO, @"暂不支持的BIT STRING内容长度！");
        }
    } else { // 最高位为0
        // 其余位就表示内容长度, 此时内容的偏移量不用加
        self.contentLength = lenLow;
    }
    // BIT STRING 整体长度 = 内容长度 + 内容起始偏移量
    self.length = self.contentLength + contentOffset;
    
    // 处理第四个字节(也就是内容的第一个字节)
    int unusedBits = [ZZASNUtils zzReadUInt8FromData:data offset:contentOffset];
    // 开始解析内容部分
    self.parsedLength = 0;
    NSData *contentData = nil;
    if (unusedBits == 0x00) {
        contentData = [data subdataWithRange:NSMakeRange(contentOffset + 1, self.contentLength - 1)];
    } else {
        // TODO: 最后一个字节未使用位数非0的情况先忽略（ps:我也不知道怎么处理,哈哈哈哈～）
        contentData = [data subdataWithRange:NSMakeRange(contentOffset, self.contentLength)];
        NSAssert(NO, @"处理未使用位数非0的情况");
    }
    // 记录自身内容
    self.bitStringHexStr = [ZZASNUtils hexStringByData:contentData];
    // 仅当需要展开解析时才解析其内容
    if (expand) {
        [self _parseBitStringContentData:contentData];
    }
    
}

- (void)_parseBitStringContentData:(NSData *)contentData {
    // 读取内容的第一个字节, 表示内容的类型, 详细定义请看 ZZASNSequence 类
    int contentType = [ZZASNUtils zzReadUInt8FromData:contentData offset:0];
    switch (contentType) {
        case 0x30:
        {
            // SEQUENCE
            self.sequence = [ZZASNSequence instanceWithData:contentData];
            self.parsedLength = self.sequence.length;
            // self.contentLength - 1:因为要去掉内容的第一个用于表示未使用位数的字节
            if (self.parsedLength != (self.contentLength - 1)) {
                // 说明当前BIT STRING还有未解析的内容
                NSRange unparsedRange = NSMakeRange(self.sequence.length, contentData.length - self.sequence.length);
                NSData *subData = [contentData subdataWithRange:unparsedRange];
                [self _parseBitStringContentData:subData];
            }
            break;
        }
            
        default:
            break;
    }
}

@end
