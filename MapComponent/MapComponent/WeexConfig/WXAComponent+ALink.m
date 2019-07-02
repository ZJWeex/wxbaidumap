//
//  WXAComponent+ALink.m
//  WeexDemo
//
//  Created by ZZJ on 2018/10/24.
//  Copyright © 2018 taobao. All rights reserved.
//

#import "WXAComponent+ALink.h"
#import <objc/runtime.h>
@interface WXAComponent (Private)
@property (nonatomic, strong) NSString *href;
@end

@implementation WXAComponent (ALink)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
       
        SEL originalSelector = NSSelectorFromString(@"openURL");
        SEL swizzledSelector = @selector(replace_openURL);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        //交换实现
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}
- (void)replace_openURL {
    if ([self.href hasPrefix:@"tel:"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.href] options:@{} completionHandler:nil];
        return;
    }
    [self replace_openURL];
}

@end
