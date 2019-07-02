//
//  WXGlobalEventModule.h
//  WeexDemo
//
//  Created by ZZJ on 2018/11/21.
//  Copyright © 2018 taobao. All rights reserved.
//  若pods引入第三方库，但并没有导出这个库中的某个文件的.h文件，则可采用这个方法做继承或扩展
#import <Foundation/Foundation.h>
#import "WXModuleProtocol.h"

@interface WXGlobalEventModule : NSObject <WXModuleProtocol>

@end
/*
#ifndef WXGlobalEventModule_h
#define WXGlobalEventModule_h


#endif*/
/* WXGlobalEventModule_h */
