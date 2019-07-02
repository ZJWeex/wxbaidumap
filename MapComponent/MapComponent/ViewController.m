//
//  ViewController.m
//  MapComponent
//
//  Created by ZZJ on 2019/6/28.
//  Copyright © 2019 Jion. All rights reserved.
//

#import "ViewController.h"
#import "WeexSDKManager.h"
#import "TCMLocationManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [WeexSDKManager setup];
    //weexSDK初始化后调用
    [[TCMLocationManager instance] registerWithKey:@"RO3cIwPrGHrM6c0ADZhFqTtj2bERcX8f" result:^(BMKLocationAuthErrorCode authCode) {
        if (authCode == BMKLocationAuthErrorSuccess) {
            
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
