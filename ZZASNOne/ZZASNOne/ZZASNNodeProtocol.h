//
//  ZZASNNodeProtocol.h
//  ZZRSADemo
//
//  Created by SandsLee on 2021/11/17.
//

#ifndef ZZASNNodeProtocol_h
#define ZZASNNodeProtocol_h

@protocol ZZASNNodeProtocol <NSObject>

/// Node 整体结构长度
@property (nonatomic, assign) int length;
/// Node 中的内容部分长度
@property (nonatomic, assign) int contentLength;
/// Node 中已经解析了的长度
@property (nonatomic, assign) int parsedLength;

/// 对象构造方法
/// @param data 对象数据
+ (instancetype)instanceWithData:(NSData *)data;

@end

#endif /* ZZASNNodeProtocol_h */
