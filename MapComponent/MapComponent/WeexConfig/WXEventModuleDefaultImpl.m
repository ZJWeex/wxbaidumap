//
//  WXEventModuleDefaultImpl.m
//  WeexDemo
//
//  Created by ZZJ on 2018/8/9.
//  Copyright © 2018年 taobao. All rights reserved.
//

#import "WXEventModuleDefaultImpl.h"
@interface WXEventModuleDefaultImpl ()

@end

@implementation WXEventModuleDefaultImpl

#pragma mark WXEventModuleProtocol
- (void)openURL:(NSString *)url {
    NSLog(@"WXEventModuleProtocol :%@",url);
}

@end
