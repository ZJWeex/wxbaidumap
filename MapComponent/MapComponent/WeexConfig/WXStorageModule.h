//
//  WXStorageModule.h
//  Superior
//
//  Created by ZZJ on 2018/11/23.
//  Copyright © 2018 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WeexSDK/WeexSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface WXStorageModule : NSObject<WXModuleProtocol>
- (void)length:(WXModuleCallback)callback;

- (void)getAllKeys:(WXModuleCallback)callback;

- (void)setItem:(NSString *)key value:(NSString *)value callback:(WXModuleCallback)callback;

- (void)setItemPersistent:(NSString *)key value:(NSString *)value callback:(WXModuleCallback)callback;

- (void)getItem:(NSString *)key callback:(WXModuleCallback)callback;

- (void)removeItem:(NSString *)key callback:(WXModuleCallback)callback;

@end

NS_ASSUME_NONNULL_END
/*
self.storage = [WXStorageModule new];
-(void)changeBange {
    __weak typeof(self) weakSelf = self;
    [self.storage getItem:@"LocalStorage_CartData" callback:^(NSDictionary *result) {
        NSLog(@"get:%@",result);
        int count = 0;
        NSData *jsonData = [result[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"json=%@",json);
        if ([json isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray*)json;
            for (NSDictionary *group in array) {
                id supGoodsList = group[@"supGoodsList"];
                if ([supGoodsList isKindOfClass:[NSArray class]]) {
                    NSArray *supGoodsArray = (NSArray*)supGoodsList;
                    for (NSDictionary *item in supGoodsArray) {
                        count += [item[@"count"] intValue];
                    }
                }
            }
        }
        if (count >0) {
            UIViewController *vc = weakSelf.viewControllers[2];
            vc.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",count];
        }else{
            UIViewController *vc = weakSelf.viewControllers[2];
            vc.tabBarItem.badgeValue = nil;
        }
        
    }];
}
*/
