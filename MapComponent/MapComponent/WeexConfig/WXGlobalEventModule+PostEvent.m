//
//  WXGlobalEventModule+PostEvent.m
//  WeexDemo
//
//  Created by ZZJ on 2018/11/30.
//  Copyright © 2018 taobao. All rights reserved.
//

#import "WXGlobalEventModule+PostEvent.h"

@implementation WXGlobalEventModule (PostEvent)
WX_EXPORT_METHOD(@selector(postEvent:params:))

-(void)postEvent:(NSString*)eventName params:(NSDictionary *)params{
    if (!params){
        params = [NSDictionary dictionary];
    }
    NSDictionary * userInfo = @{
                                @"param":params
                                };
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:self userInfo:userInfo];
}
@end
