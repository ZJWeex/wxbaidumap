//
//  NSURL+XZOL.m
//  MapComponent
//
//  Created by ZZJ on 2019/7/1.
//  Copyright © 2019 Jion. All rights reserved.
//

#import "NSURL+XZOL.h"
#import "DemoDefine.h"
@implementation NSURL (XZOL)
+ (NSURL *)weexUrlWithFilePath:(NSString *)filePath{
    
    NSString *fullpath = nil;
#if DEBUG
    if ([filePath containsString:@"http"]) {
        fullpath = filePath;
    }else{
        fullpath = DEMO_URL(filePath);
    }
    
#else
    fullpath = [NSString stringWithFormat:@"%@%@", self.HTTP_RemoteResourceReplace, filePath];
#endif
    NSLog(@"weex resouces file:%@", fullpath);
    return [NSURL URLWithString:fullpath];
    
}

+ (NSString *)HTTP_RemoteResourceReplace{
    return @"http://h5.taocai.mobi/down/thybrid/";
}

@end
