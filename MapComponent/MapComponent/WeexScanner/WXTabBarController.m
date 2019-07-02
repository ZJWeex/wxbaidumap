//
//  WXTabBarController.m
//  MapComponent
//
//  Created by ZZJ on 2019/6/28.
//  Copyright © 2019 Jion. All rights reserved.
//

#import "WXTabBarController.h"
#import "WXViewController.h"
#import "NSURL+XZOL.h"
#import "WXRootViewController.h"
//状态栏高
#define statusBarH    CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)
#define safeAreaBottomH (statusBarH > 20 ? 34 : 0)

@interface WXTabBarController ()<UIGestureRecognizerDelegate, UITabBarControllerDelegate>
@property (nonatomic, copy) NSArray *urlList;
@end

@implementation WXTabBarController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    [self setTabBarChildController];
}
- (void)setTabBarChildController{
    NSArray *titleArray = @[@"首页",@"兴趣",@"社区",@"我的"];
    NSArray *imageArray = @[@"tab_button_message",@"tab_button_settings",@"tab_button_message",@"tab_button_friends"];
    NSArray *classNames = @[@"WXViewController",@"WXViewController", @"MessageController",@"WXViewController"];
    _urlList = @[
                 @"index.js",
                 @"http://192.168.15.220:8081/dist/base-superior/homepage_index.js",
                 @"",
                 @"http://192.168.15.220:8081/dist/base-superior/personal_index.js",
                 ];
    [self.tabBar setTranslucent:NO];
    [self.tabBar setTintColor:[UIColor lightTextColor]];
    
    UIImage *indicatorImage = [UIImage imageNamed:@"tab_button_select_back"];
    if (safeAreaBottomH>0) {
        indicatorImage = [indicatorImage resizableImageWithCapInsets:UIEdgeInsetsMake(safeAreaBottomH, -10, 0, 0) resizingMode:UIImageResizingModeTile];
    }
    
//    [self.tabBar setSelectionIndicatorImage:indicatorImage];
    
    for (int j=0;j<classNames.count;j++) {
        NSString *className = classNames[j];
        NSString *url = _urlList[j];
        UIViewController *vc;
        if (url&&url.length>0) {
            vc = [(WXViewController*)[NSClassFromString(className) alloc] initWithSourceURL:[NSURL weexUrlWithFilePath:url]];
            vc.hidesBottomBarWhenPushed = NO;
            ((WXViewController*)vc).hideNavBar = YES;
        }else{
            vc = [[NSClassFromString(className) alloc] init];
        }
        
        vc.tabBarItem.image = [[UIImage imageNamed:imageArray[j]]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:imageArray[j]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        vc.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        vc.tabBarItem.title = titleArray[j];
        
        //设置tabbar的title的颜色，字体大小，阴影
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:10],NSFontAttributeName, nil];
        [vc.tabBarItem setTitleTextAttributes:dic forState:UIControlStateNormal];
        
        NSShadow *shad = [[NSShadow alloc] init];
        shad.shadowColor = [UIColor whiteColor];
        
        NSDictionary *selectDic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:16/255.0 green:212/255.0 blue:201/255.0 alpha:1.0],NSForegroundColorAttributeName,shad,NSShadowAttributeName,[UIFont boldSystemFontOfSize:10],NSFontAttributeName, nil];
        [vc.tabBarItem setTitleTextAttributes:selectDic forState:UIControlStateSelected];
        WXRootViewController *navi = [[WXRootViewController alloc] initWithRootViewController:vc];
        [navi.navigationBar setTintColor:[UIColor colorWithRed:16/255.0 green:212/255.0 blue:201/255.0 alpha:1.0]];
        [navi.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:16/255.0 green:212/255.0 blue:201/255.0 alpha:1.0]}];
        [self addChildViewController:navi];
    }
    
}
#pragma mark -- UITabBarControllerDelegate
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
   
    return YES;
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{

}

#pragma mark -- UIGestureRecognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
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
