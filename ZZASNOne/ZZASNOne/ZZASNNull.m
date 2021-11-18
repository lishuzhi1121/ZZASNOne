//
//  ZZASNNull.m
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import "ZZASNNull.h"
#import "ZZASNUtils.h"

@implementation ZZASNNull

@synthesize length;
@synthesize contentLength;
@synthesize parsedLength;

+ (instancetype)instanceWithData:(NSData *)data {
    ZZASNNull *asnNull = [[ZZASNNull alloc] initWithData:data];
    return asnNull;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        [self _parseNullData:data];
    }
    return self;
}

- (void)_parseNullData:(NSData *)data {
    // 读取第二个字节表示长度
    int lenPos = [ZZASNUtils zzReadUInt8FromData:data offset:1];
    self.contentLength = lenPos;
    self.length = self.contentLength + 2; // NULL 节点是固定2个字节的头
    // NULL 节点一般没有内容
}

@end
