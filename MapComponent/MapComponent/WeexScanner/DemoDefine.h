/**
 * Created by Weex.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the Apache Licence 2.0.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
//状态栏高
#define statusBarH    CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)
#define safeAreaBottomH (statusBarH > 20 ? 34 : 0)


#define CURRENT_IP @"192.168.15.235"

#if TARGET_IPHONE_SIMULATOR
    #define DEMO_HOST @"127.0.0.1"//@"192.168.15.220"//
#else
    #define DEMO_HOST CURRENT_IP
#endif

#define DEMO_URL(path) [NSString stringWithFormat:@"http://%@:8081/dist/%@", DEMO_HOST, path]

#define BUNDLE_URL [NSString stringWithFormat:@"file://%@/bundlejs/index.js",[NSBundle mainBundle].bundlePath]


#define WXSocketConnectionURL [NSString stringWithFormat:@"ws://%@:8080/websocket", DEMO_HOST]
