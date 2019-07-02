//
//  WXPickerModule+Evnet.m
//  Superior
//
//  Created by ZZJ on 2018/12/3.
//  Copyright © 2018 taobao. All rights reserved.
//

#import <objc/runtime.h>
#import "WXPickerModule+Evnet.h"
@interface WXPickerModule (Private)
@property (nonatomic, strong)NSString * pickerType;
//picker
@property(nonatomic,strong)UIPickerView *picker;
@property(nonatomic,strong)UIView *backgroundView;
@property(nonatomic,strong)UIView *pickerView;
//date picker
@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic)BOOL isAnimating;

@end
@implementation WXPickerModule (Evnet)
#define WXPickerHeight 266

-(void)show {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];  //hide keyboard
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.backgroundView];
    if (@available(iOS 11.0, *)){
        //iOS11以上系统
    }
    NSString *version = [UIDevice currentDevice].systemVersion;
    if ([version containsString:@"."]) {
        NSArray *versions = [version componentsSeparatedByString:@"."];
        if ([versions.firstObject integerValue] == 11) {
            NSArray *gestureRecognizers = self.backgroundView.gestureRecognizers;
            if (gestureRecognizers.count > 0) {
                [self.backgroundView removeGestureRecognizer:gestureRecognizers.lastObject];
                UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:NSSelectorFromString(@"hide")];
                tapGesture.delegate = self;
                [self.backgroundView addGestureRecognizer:tapGesture];
            }
        }
    }
    
    if (self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    self.backgroundView.hidden = NO;
    UIView * focusView = self.picker;
    if([self.pickerType isEqualToString:@"picker"]) {
        focusView = self.picker;
    } else {
        focusView = self.datePicker;
    }
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, focusView);
    [UIView animateWithDuration:0.35f animations:^{
        self.pickerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - WXPickerHeight, [UIScreen mainScreen].bounds.size.width, WXPickerHeight);
        self.backgroundView.alpha = 1;
        
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
        
    }];
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    Ivar backgroundViewivar = class_getInstanceVariable([self class], "_backgroundView");
    UIView *backgroundView=object_getIvar(self, backgroundViewivar);
    if (touch.view==backgroundView) {
        
        return YES;
        
    }
    return NO;
}
@end
