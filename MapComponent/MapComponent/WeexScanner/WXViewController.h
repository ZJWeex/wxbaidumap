//
//  WXViewController.h
//  WeexDemo
//
//  Created by ZZJ on 2018/8/13.
//  Copyright © 2018年 taobao. All rights reserved.
//

#import "WXBaseViewController.h"
#import "SRWebSocket.h"
#import "WXModuleProtocol.h"

@interface WXViewController : WXBaseViewController<WXModuleProtocol>
@property(nonatomic,assign)BOOL  hideNavBar;
@property (nonatomic, strong) NSURL *sourceURL;
@end
