//
//  AppDelegate.m
//  ZZASNOneDemo
//
//  Created by SandsLee on 2021/11/18.
//

#import "AppDelegate.h"
#import <ZZASNOne/ZZASNOne.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


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


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
