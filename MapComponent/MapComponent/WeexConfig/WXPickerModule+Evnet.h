//
//  WXPickerModule+Evnet.h
//  Superior
//
//  Created by ZZJ on 2018/12/3.
//  Copyright © 2018 taobao. All rights reserved.
// 解决picker在iOS11上不回调问题
/*
 两种方法：
 1.重写的方式
 2.使用方法交换的方式
 */
#import "WXPickerModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXPickerModule (Evnet)<UIGestureRecognizerDelegate>

@end

NS_ASSUME_NONNULL_END
