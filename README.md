# ZZASNOne
ASN.1 语法格式的文件内容解析，目前已实现对openssl生成的RSA公钥算法密钥文件以及ECC椭圆曲线算法（国密SM2）密钥文件的解析。

## 一、ASN.1 编码

关于ASN.1的编码格式，[微软官方文档](https://docs.microsoft.com/en-us/windows/win32/seccertenroll/about-der-encoding-of-asn-1-types) 有非常详细的描述，也推荐参考喵神的 [与 JOSE 战斗的日子 - 写给 iOS 开发者的密码学入门手册 (理论)](https://onevcat.com/2018/12/jose-2/) 。为了更加方便学习ASN.1语法格式，下面对ASN.1做个基本介绍。

### 1. 类型定义

ASN.1 编码的类型包括：基本类型、字符串类型以及构造类型，详见：[ASN.1 类型系统](https://docs.microsoft.com/en-us/windows/win32/seccertenroll/about-asn-1-type-system) 。

#### 1.1 基本类型

ASN.1 的基本类型主要包括以下几种：

* BIT STRING

    > 0x03 0x81 0x81 0x00 ...
    > 第一个字节 0x03 是 BIT STRING 的开头标识。
    > 第二个字节 0x81 如果 BIT STRING 内容的长度<=127个字节，则该字节的最高位为0，其余位表示内容长度。否则最高位为1，其余位表示内容长度将用几个字节表示。
    > 例如：1. 0x81（1000 0001）最高位为1，说明内容长度超过了127个字节，其余位表示为1，说明该BIT STRING的内容长度要用接下来的1个字节表示，即0x81，表示长度为129个字节。2. 0x06（0000 0110）最高位为0，说明内容长度不超过127个字节，其余位表示为6，说明该BIT STRING的内容长度就是6个字节。
    > 第三个字节 0x81 表示 BIT STRING 的内容长度。
    > 第四个字节 0x00 用于指定存在于内容中的最后一个字节中的未使用位数。如果传输的数据bit数恰好是8的倍数，则设置为0，表示所有bit位都要使用。如果想要舍弃传输的数据中最后一个字节的后5位，则应该设置为0x05 。

* BOOLEAN

    > 0x01 0x01 0x00 ...
    > 第一个字节 0x01 是 BOOLEAN 的开头标识。
    > 第二个字节 0x01 表示 BOOLEAN 的内容长度，一个布尔值，自然就只是一个字节。
    > 第三个字节 0x00 表示 BOOLEAN 的内容，0x00表示FALSE，非0都表示TRUE。

* INTEGER

    > 0x02 0x81 0x81 0x00 ...
    > 第一个字节 0x02 是 INTEGER 的开头标识。
    > 第二个字节 0x81 如果 INTEGER 内容的长度<=127个字节，则该字节的最高位为0，其余位表示内容长度。否则最高位为1，其余位表示内容长度将用几个字节表示。
    > 例如：1. 0x81（1000 0001）最高位为1，说明内容长度超过了127个字节，其余位表示为1，说明该INTEGER的内容长度要用接下来的1个字节表示，即0x81，表示长度为129个字节。2. 0x06（0000 0110）最高位为0，说明内容长度不超过127个字节，其余位表示为6，说明该INTEGER的内容长度就是6个字节。
    > 第三个字节 0x81 表示 INTEGER 的内容长度。
    > 第四个字节 0x00 用于指定当该节点内容的数字不是负数，但是最高位为1时仍表示正数。
     
* NULL

    > 0x05 0x00 ...
    > 第一个字节 0x05 是 NULL 的开头标识。
    > 第二个字节 0x00 表示 NULL 的内容长度，NULL一般没有内容，所以长度是0个字节。

* OBJECT IDENTIFIER

    > 0x06 0x09 ...
    > 第一个字节 0x06 是 OBJECT IDENTIFIER 的开头标识。
    > 第二个字节 0x09 表示 OBJECT IDENTIFIER 的内容长度。
    > 根据内容长度读取出内容的16进制字符串再转为点分十进制字符串，该库暂未进行转换，具体转换方式参考：[OBJECT IDENTIFIER 编码规范](https://docs.microsoft.com/en-us/windows/win32/seccertenroll/about-object-identifier)

* OCTET STRING

    > 0x04 0x82 0x02 0x5F ...
    > 第一个字节 0x04 是 OCTET STRING 的开头标识。（OCTET STRING和BIT STRING数据类型非常相似。不同之处在于，因为OCTET STRING的尾随字节不能有未使用的位，所以不必将前导字节0x00添加到内容中。）
    > 第二个字节 0x82 如果 OCTET STRING 内容的长度<=127个字节，则该字节的最高位为0，其余位表示内容长度。否则最高位为1，其余位表示内容长度将用几个字节表示。
    > 例如：1. 0x82（1000 0010）最高位为1，说明内容长度超过了127个字节，其余位表示为2，说明该OCTET STRING的内容长度要用接下来的2个字节表示，即0x02 0x5F，表示长度为607个字节。2. 0x06（0000 0110）最高位为0，说明内容长度不超过127个字节，其余位表示为6，说明该OCTET STRING的内容长度就是6个字节。
    > 第三、四个字节 0x81 表示 OCTET STRING 的内容长度。


#### 1.2 字符串类型

ASN.1 的字符串类型主要包括以下几种：

* BMPString
* IA5String
* PrintableString
* TeletexString
* UTF8String

> 由于该库暂时没有支持到解析这些类型，所以暂时不做说明～😂😂😂


#### 1.3 构造类型

ASN.1 的构造类型主要包括以下几种：

* SEQUENCE

    > 0x30 0x82 0x01 0x01 ...
    > 第一个字节 0x30 是SEQUENCE的开头标识。
    > 第二个字节 0x82 如果SEQUENCE内容的长度<=127个字节，则该字节的最高位为0，其余位表示内容长度。否则最高位为1，其余位表示内容长度将用几个字节表示。
    > 例如：1. 0x82（1000 0010）最高位为1，说明内容长度超过了127个字节，其余位表示为2，说明该SEQUENCE的内容长度要用接下来的2个字节表示，即0x01 0x01，表示长度为257个字节。2. 0x03（0000 0011）最高位为0，说明内容长度不超过127个字节，其余位表示为3，说明该SEQUENCE的内容长度就是3个字节。

* SET/SET OF

    > 由于该库暂时没有支持到解析这个类型，所以暂时不做说明～😂😂😂
    

## 二、使用方式

### 1. 接入

将 `ZZASNOne/Package` 目录下的 `ZZASNOne.framework` 拖到你的项目中并选择Copy即可。

### 2. 使用

接口比较简单，调用示例代码如下：

```objc
#import "AppDelegate.h"
#import <ZZASNOne/ZZASNOne.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // MARK: - ASN.1 parse test
    // ECC 公钥文件
    NSString *pubFilePath = [[NSBundle mainBundle] pathForResource:@"public_key_prime256v1" ofType:@"pem"];
    ZZASNOne *asn1 = [ZZASNOne loadWithContentsOfFile:pubFilePath];
    // 公钥字符串：asn1->_sequence->_bitString->_bitStringHexStr
    NSLog(@"asn1: %@", asn1);
    
    // ECC 私钥文件
    NSString *privFilePath = [[NSBundle mainBundle] pathForResource:@"private_key_prime256v1" ofType:@"pem"];
    ZZASNOne *asn2 = [ZZASNOne loadWithContentsOfFile:privFilePath];
    // 私钥字符串：asn2->_sequence->_octetString->_octetStringHexStr
    // 公钥字符串：asn2->_sequence->_axNodes->[1]->_bitString->_bitStringHexStr
    NSLog(@"asn1: %@", asn2);
    
    return YES;
}

```

