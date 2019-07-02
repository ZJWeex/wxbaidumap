//
//  WXTextAreaComponent+Method.m
//  AFNetworking
//
//  Created by ZZJ on 2019/6/19.
//

#import "WXTextAreaComponent+Method.h"
#import <objc/runtime.h>

@implementation WXTextAreaComponent (Method)
+ (void)load{
    Class className = [self class];
    
    SEL originalSelector = @selector(setText:);
    SEL swizzledSelector = @selector(replace_setText:);
    
    Method originalMethod = class_getInstanceMethod(className, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(className, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(className, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(className, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    }else{
        //交换实现
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

-(void)replace_setText:(NSString *)text{
    [self replace_setText:text];
    if (text.length==0) {
        if ([self respondsToSelector:NSSelectorFromString(@"setPlaceholderAttributedString")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:NSSelectorFromString(@"setPlaceholderAttributedString")];
#pragma clang diagnostic pop
            
        }
        
    }
   
}

@end
