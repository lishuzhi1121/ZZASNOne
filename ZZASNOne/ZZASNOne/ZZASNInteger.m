//
//  ZZASNInteger.m
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import "ZZASNInteger.h"
#import "ZZASNUtils.h"

@implementation ZZASNInteger

@synthesize length;
@synthesize contentLength;
@synthesize parsedLength;

+ (instancetype)instanceWithData:(NSData *)data {
    ZZASNInteger *integer = [[ZZASNInteger alloc] initWithData:data];
    return integer;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        [self _parseIntegerData:data];
    }
    return self;
}

- (void)_parseIntegerData:(NSData *)data {
    /*
     0x02 0x81 0x81 0x00 ...
     ------------------------------------------------
     第一个字节 0x02 是 INTEGER 的开头标识
     第二个字节 0x81 如果 INTEGER 内容的长度<=127个字节，则该字节的最高位为0，
     其余位表示内容长度。否则最高位为1，其余位表示内容长度将用几个字节表示。
     例如：1. 0x81（1000 0001）最高位为1，说明内容长度超过了127个字节，其余位表示为1，
     说明该INTEGER的内容长度要用接下来的1个字节表示，即0x81，表示长度为129个字节。
          2. 0x06（0000 0110）最高位为0，说明内容长度不超过127个字节，其余位表示为6，
     说明该INTEGER的内容长度就是6个字节。
     第三个字节 0x81 表示 INTEGER 的内容长度
     第四个字节 0x00 用于指定当该节点内容的数字不是负数，但是最高位为1时仍表示正数。
     */
    // 表示INTEGER内容开始字节的偏移量,至少是2（0x03的头+0x06的长度）
    int contentOffset = 2;
    // 读取第二个字节表示长度
    int lenPos = [ZZASNUtils zzReadUInt8FromData:data offset:1];
    int lenHigh = (lenPos & 0x80) >> 7;
    int lenLow = lenPos & 0x7F;
    if (lenHigh == 1) { // 最高位为1
        if (lenLow == 1) {
            // INTEGER的内容长度要用接下来的1个字节表示
            self.contentLength = [ZZASNUtils zzReadUInt8FromData:data offset:2];
            // 此时内容的偏移量加1
            contentOffset += 1;
            
        } else if (lenLow == 2) {
            // INTEGER的内容长度要用接下来的2个字节表示
            self.contentLength = [ZZASNUtils zzReadUInt16FromData:data offset:2];
            // 此时内容的偏移量加2
            contentOffset += 2;
            
        } else {
            // 如果超过两个字节表示的长度,那也是够厉害的了,哈哈哈哈～
            NSAssert(NO, @"暂不支持的INTEGER内容长度！");
        }
    } else { // 最高位为0
        // 其余位就表示内容长度, 此时内容的偏移量不用加
        self.contentLength = lenLow;
    }
    // INTEGER 整体长度 = 内容长度 + 内容起始偏移量
    self.length = self.contentLength + contentOffset;
    
    // 开始解析内容部分
    self.parsedLength = 0;
    NSData *contentData = nil;
    if (self.contentLength > 1) {
        // 处理第四个字节(也就是内容的第一个字节，正数标识，仅当INTEGER内容长度大于1个字节时处理)
        int posFlag = [ZZASNUtils zzReadUInt8FromData:data offset:contentOffset];
        if (posFlag == 0x00) {
            contentData = [data subdataWithRange:NSMakeRange(contentOffset + 1, self.contentLength - 1)];
        } else {
            contentData = [data subdataWithRange:NSMakeRange(contentOffset, self.contentLength)];
        }
    } else {
        contentData = [data subdataWithRange:NSMakeRange(contentOffset, self.contentLength)];
    }
    
    [self _parseIntegerContentData:contentData];
    
}

- (void)_parseIntegerContentData:(NSData *)contentData {
    NSMutableString *hexStr = [NSMutableString string];
    const char *buf = [contentData bytes];
    for (int i = 0; i < [contentData length]; i++)
    {
        [hexStr appendFormat:@"%02X", buf[i] & 0xff];
    }
    self.integerHexStr = [hexStr copy];
}

@end
