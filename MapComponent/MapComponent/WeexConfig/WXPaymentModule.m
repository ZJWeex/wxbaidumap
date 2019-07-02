//
//  WXPaymentModule.m
//  WeexDemo
//
//  Created by ZZJ on 2018/11/21.
//  Copyright © 2018 taobao. All rights reserved.
//

#import "WXPaymentModule.h"

@implementation WXPaymentModule
WX_EXPORT_METHOD(@selector(payment:callback:))

-(void)payment:(NSDictionary*)param callback:(WXModuleKeepAliveCallback)callback{
    
    callback(@"",NO);
}

@end
