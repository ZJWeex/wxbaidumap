//
//  WeexSDKManager.m
//  WeexDemo
//
//  Created by yangshengtao on 16/11/14.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import "WeexSDKManager.h"
#import "DemoDefine.h"
#import <WeexSDK/WeexSDK.h>
#import "WXTabBarController.h"
#import "WXImgLoaderDefaultImpl.h"
#import "WXNavigationImpl.h"

@implementation WeexSDKManager

+ (void)setup;
{
    [self initWeexSDK];
    [self loadCustomTabbar];
    
}

+ (void)initWeexSDK
{
    NSString *bundleName = [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleNameKey];
    NSLog(@"bundleName:%@",bundleName);
    [WXAppConfiguration setAppGroup:@"AliApp"];
    [WXAppConfiguration setAppName:[[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]];
    [WXAppConfiguration setAppVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [WXAppConfiguration setExternalUserAgent:@"ExternalUA"];
    
    [WXSDKEngine initSDKEnvironment];
    
    [WXSDKEngine registerHandler:[WXImgLoaderDefaultImpl new] withProtocol:@protocol(WXImgLoaderProtocol)];
    //替换默认的导航handler
    [WXSDKEngine registerHandler:[WXNavigationImpl new] withProtocol:@protocol(WXNavigationProtocol)];
    
#ifdef DEBUG
    [WXLog setLogLevel:WXLogLevelLog];
#endif
}

+ (void)loadCustomTabbar
{
    WXTabBarController *demo = [[WXTabBarController alloc] init];
    [[UIApplication sharedApplication] delegate].window.rootViewController = demo;
}

@end
