//
//  WXNavigatorModule+Extension.m
//  Superior
//
//  Created by ZZJ on 2018/12/1.
//  Copyright © 2018 taobao. All rights reserved.
//

#import "WXNavigatorModule+Extension.h"

@implementation WXNavigatorModule (Extension)
WX_EXPORT_METHOD(@selector(go:callback:))

-(void)go:(NSInteger)index callback:(WXModuleKeepAliveCallback)callback{
    if (index>0) {
        callback(@"fail",NO);
        return;
    }
    UIViewController *controller = self.weexInstance.viewController;
    if (controller.navigationController) {
        NSArray *controllers = controller.navigationController.viewControllers;
        NSUInteger page = abs((int)index);
        if (controllers.count > page) {
            UIViewController *targetVC = controllers[controllers.count - 1 -page];
            [controller.navigationController popToViewController:targetVC animated:YES];
            callback(@"success",NO);
        }else if (controllers.count>1 && page>=controllers.count){
            [controller.navigationController popToRootViewControllerAnimated:YES];
            callback(@"success",NO);
        }else{
            callback(@"fail",NO);
        }
        
    }else{
        callback(@"fail",NO);
    }
}

@end
