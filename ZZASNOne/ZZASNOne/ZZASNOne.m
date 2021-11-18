//
//  ZZASNOne.m
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/16.
//

#import "ZZASNOne.h"
#import "ZZASNUtils.h"
#import "ZZASNSequence.h"

@implementation ZZASNOne

+ (instancetype)loadWithContentsOfFile:(NSString *)filePath {
    ZZASNOne *asn = [[ZZASNOne alloc] initWithContentsOfFile:filePath];
    return asn;
}

- (instancetype)initWithContentsOfFile:(NSString *)filePath {
    if (self = [super init]) {
        [self _parseASNFile:filePath];
    }
    return self;
}

- (void)_parseASNFile:(NSString *)filePath {
    BOOL validFilePath = [self _filePathValidAndExists:filePath];
    if (!validFilePath) {
        return;
    }
    if ([filePath hasSuffix:@".pem"]) {
        // PEM 格式的文件
        NSData *data = [self _dataWithContentsOfPemFile:filePath];
        [self _parseASNContentData:data];
        
    } else if ([filePath hasSuffix:@".der"]) {
        // DER 格式的文件
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [self _parseASNContentData:data];
        
    } else {
        NSAssert(NO, @"不支持的文件格式! 仅支持 .pem 或 .der 格式的文件.");
    }
    
}

- (void)_parseASNContentData:(NSData *)contentData {
    // 读出第一个字节, 表示内容的类型, 详细定义请看 ZZASNSequence 类
    int contentType = [ZZASNUtils zzReadUInt8FromData:contentData offset:0];
    if (contentType == 0x30) { // SEQUENCE
        self.sequence = [ZZASNSequence instanceWithData:contentData];
    } else {
        // TODO: 其他类型的节点处理
        NSAssert(NO, @"ASN.1语法格式的文件内容非SEQUENCE开头!");
    }
}

- (BOOL)_filePathValidAndExists:(NSString *)filePath {
    BOOL validPath = [filePath isKindOfClass:[NSString class]] && (filePath.length > 0);
    NSAssert(validPath, @"文件路径类型不合法!");
    if (!validPath) {
        return NO;
    }
    BOOL isDir = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    NSAssert((isExists && !isDir), @"文件不存在或者路径是一个文件夹");
    if (!isExists || isDir) { // 文件不存在或者路径是一个文件夹
        return NO;
    }
    
    return YES;
}

- (NSData *)_dataWithContentsOfPemFile:(NSString *)filePath {
    NSError *error = nil;
    NSString *key = [NSString stringWithContentsOfFile:filePath
                                              encoding:NSUTF8StringEncoding
                                                 error:&error];
    BOOL success = ((error == nil) && (key.length > 0));
    NSAssert(success, @"PEM 格式的文件读取失败 error: %@", error.localizedDescription);
    if (!success) {
        return nil;
    }
    // PEM 公钥文件头
    NSString *pubHeader     = @"-----BEGIN PUBLIC KEY-----";
    // PEM 公钥文件尾
    NSString *pubFooter     = @"-----END PUBLIC KEY-----\n";
    // PEM RSA私钥文件头
    NSString *privHeader    = @"-----BEGIN RSA PRIVATE KEY-----";
    // PEM RSA私钥文件尾
    NSString *privFooter    = @"-----END RSA PRIVATE KEY-----\n";
    // PEM pkcs8私钥文件头
    NSString *pkcs8Header   = @"-----BEGIN PRIVATE KEY-----";
    // PEM pkcs8私钥文件尾
    NSString *pkcs8Footer   = @"-----END PRIVATE KEY-----\n";
    // PEM ECC椭圆曲线加密算法的私钥文件头
    NSString *ecPrivHeader = @"-----BEGIN EC PRIVATE KEY-----";
    // PEM ECC椭圆曲线加密算法的私钥文件尾
    NSString *ecPrivFooter = @"-----END EC PRIVATE KEY-----\n";
    
    if ([key hasPrefix:pubHeader] && [key hasSuffix:pubFooter]) {
        // PEM格式的公钥文件
        key = [key stringByReplacingOccurrencesOfString:pubHeader withString:@""];
        key = [key stringByReplacingOccurrencesOfString:pubFooter withString:@""];
    } else if ([key hasPrefix:privHeader] && [key hasSuffix:privFooter]) {
        // PEM格式的RSA私钥文件
        key = [key stringByReplacingOccurrencesOfString:privHeader  withString:@""];
        key = [key stringByReplacingOccurrencesOfString:privFooter  withString:@""];
    } else if ([key hasPrefix:pkcs8Header] && [key hasSuffix:pkcs8Footer]) {
        // PEM格式的pkcs8私钥文件
        key = [key stringByReplacingOccurrencesOfString:pkcs8Header withString:@""];
        key = [key stringByReplacingOccurrencesOfString:pkcs8Footer withString:@""];
    } else if ([key hasPrefix:ecPrivHeader] && [key hasSuffix:ecPrivFooter]) {
        // PEM ECC椭圆曲线加密算法的私钥文件
        key = [key stringByReplacingOccurrencesOfString:ecPrivHeader withString:@""];
        key = [key stringByReplacingOccurrencesOfString:ecPrivFooter withString:@""];
    } else {
        // TODO: 其他格式的PEM文件
        NSAssert(NO, @"请注意PEM的文件格式是否正常!");
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r"  withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n"  withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t"  withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "   withString:@""];
    
    // This key will be base64 encoded, so decode it!
    NSData *data = [ZZASNUtils zzBase64DecodeString:key];
    return data;
}

@end
