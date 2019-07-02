//
//  WXPaopaoComponent.h
//  Superior
//
//  Created by ZZJ on 2019/5/29.
//  Copyright © 2019 淘菜猫. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXPaopaoView : UIView
@property (nonatomic, strong) UIImage *image; //商户图
@property (nonatomic, copy) NSString *title; //商户名
@property (nonatomic, copy) NSString *subtitle; //地址

-(CGFloat)getPaopaoWidth;

@end

NS_ASSUME_NONNULL_END
