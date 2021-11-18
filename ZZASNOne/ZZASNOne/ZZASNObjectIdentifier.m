//
//  ZZASNObjectIdentifier.m
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import "ZZASNObjectIdentifier.h"
#import "ZZASNUtils.h"

@implementation ZZASNObjectIdentifier

@synthesize length;
@synthesize contentLength;
@synthesize parsedLength;

+ (instancetype)instanceWithData:(NSData *)data {
    ZZASNObjectIdentifier *oid = [[ZZASNObjectIdentifier alloc] initWithData:data];
    return oid;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        [self _parseObjectIdentifierData:data];
    }
    return self;
}

- (void)_parseObjectIdentifierData:(NSData *)data {
    // 读取第二个字节表示内容长度
    int lenPos = [ZZASNUtils zzReadUInt8FromData:data offset:1];
    self.contentLength = lenPos;
    self.length = self.contentLength + 2; // OBJECT IDENTIFIER 的头一般是2个字节
    // 读取内容
    uint8_t buff[lenPos];
    [data getBytes:&buff range:NSMakeRange(2, lenPos)];
    NSMutableString *oid = [NSMutableString string];
    for (int i = 0; i < lenPos; i++)
    {
        [oid appendFormat:@"%02X", buff[i] & 0xff];
    }
    self.objectIdentiferHexStr = [oid copy];
}

@end
