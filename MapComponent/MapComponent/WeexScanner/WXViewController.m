//
//  WXViewController.m
//  WeexDemo
//
//  Created by ZZJ on 2018/8/13.
//  Copyright © 2018年 taobao. All rights reserved.
//

#import "WXViewController.h"
#import "DemoDefine.h"
#import "WXSDKInstance.h"
#import <objc/runtime.h>
#import "WXPrerenderManager.h"
#import "WXMonitor.h"
#import "WXResultBackgroundView.h"

//#import "WXRootViewController.h"
//#import "WXSDKEngine.h"
//#import "WXSDKManager.h"
//#import "WXUtility.h"

@interface WXViewController (Private)
@property (nonatomic, strong) WXSDKInstance *instance;
@property (nonatomic, strong) UIView *weexView;

- (void)_updateInstanceState:(WXState)state;

@end
@interface WXViewController ()<SRWebSocketDelegate>
@property (nonatomic, strong) SRWebSocket *hotReloadSocket;
@property (nonatomic, strong) WXResultBackgroundView *privateContentView;
@end

@implementation WXViewController

- (void)dealloc {
#if DEBUG
    [self.hotReloadSocket close];
#endif
}
- (void)viewDidLoad {
    //屏蔽父类的viewDidLoad
    void (*viewDidLoad)(id, SEL) = (void (*)(id, SEL))class_getMethodImplementation([UIViewController class], @selector(viewDidLoad));
    viewDidLoad(self, @selector(viewDidLoad));
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self _renderWithURL:self.sourceURL];
    
#if DEBUG
    NSString * hotReloadURL =  WXSocketConnectionURL;
    if (hotReloadURL){
        _hotReloadSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:hotReloadURL]];
        _hotReloadSocket.delegate = self;
        [_hotReloadSocket open];
    }
#endif
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = _hideNavBar;
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
}

- (void)_renderWithURL:(NSURL *)sourceURL
{
    if (!sourceURL) {
        return;
    }
    
    [self.instance destroyInstance];
    if([WXPrerenderManager isTaskReady:[self.sourceURL absoluteString]]){
        self.instance = [WXPrerenderManager instanceFromUrl:self.sourceURL.absoluteString];
    }
    
    self.instance = [[WXSDKInstance alloc] init];
    self.instance.pageObject = self;
    self.instance.pageName = sourceURL.absoluteString;
    self.instance.viewController = self;
    CGFloat navBarH = _hideNavBar? 0.0f:44+statusBarH;
    self.instance.frame = CGRectMake(0.0f, navBarH, self.view.bounds.size.width, self.view.bounds.size.height-navBarH);
    
    NSString *newURL = nil;
    
    if ([sourceURL.absoluteString rangeOfString:@"?"].location != NSNotFound) {
        newURL = [NSString stringWithFormat:@"%@&random=%d", sourceURL.absoluteString, arc4random()];
    } else {
        newURL = [NSString stringWithFormat:@"%@?random=%d", sourceURL.absoluteString, arc4random()];
    }
    [self.instance renderWithURL:[NSURL URLWithString:newURL] options:@{@"bundleUrl":sourceURL.absoluteString} data:nil];
    
    self.privateContentView.loadingStatus = RESULT_LOADING_STATUS_LOADING;
    
    __weak typeof(self) weakSelf = self;
    self.instance.onCreate = ^(UIView *view) {
        [weakSelf.weexView removeFromSuperview];
        weakSelf.weexView = view;
        [weakSelf onCreate:view];
    };
    
    self.instance.onFailed = ^(NSError *error) {
        [weakSelf performSelectorOnMainThread:@selector(onFailed:) withObject:error waitUntilDone:NO];
    };
    
    self.instance.renderFinish = ^(UIView *view) {
        [weakSelf _updateInstanceState:WeexInstanceAppear];
         [weakSelf performSelectorOnMainThread:@selector(renderFinish:) withObject:view waitUntilDone:NO];
    };
    self.instance.onRenderProgress = ^ (CGRect renderRect) {
    };
    self.instance.onJSDownloadedFinish = ^(WXResourceResponse *response, WXResourceRequest *request, NSData *data, NSError *error) {
    };
    self.instance.onJSRuntimeException = ^(WXJSExceptionInfo *jsException) {
        
        [weakSelf performSelectorOnMainThread:@selector(onJSRuntimeException:) withObject:jsException waitUntilDone:NO];
    };
    if([WXPrerenderManager isTaskReady:[self.sourceURL absoluteString]]){
        WX_MONITOR_INSTANCE_PERF_START(WXPTJSDownload, self.instance);
        WX_MONITOR_INSTANCE_PERF_END(WXPTJSDownload, self.instance);
        WX_MONITOR_INSTANCE_PERF_START(WXPTFirstScreenRender, self.instance);
        WX_MONITOR_INSTANCE_PERF_START(WXPTAllRender, self.instance);
        [WXPrerenderManager renderFromCache:[self.sourceURL absoluteString]];
        return;
    }
}

#pragma mark -- SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"webSocket Open");
}
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([@"refresh" isEqualToString:message]) {
        [self refreshWeex];
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"webSocket err : %@",error);
}

#pragma mark -- PP
- (void)renderFinish:(UIView *)view{
    //加载完成
    self.privateContentView.loadingStatus = RESULT_LOADING_STATUS_RENDER_FINISH;
}
- (void)onJSRuntimeException:(WXJSExceptionInfo *)jsException{
    if (jsException.errorCode.integerValue == -2013) {
        self.privateContentView.loadingStatus = RESULT_LOADING_STATUS_FILE_EXECUTION_FAILED;
        [self.weexView removeFromSuperview];
    }
}
- (void)onFailed:(NSError *)error{
    if (error.code == -2205) {
        self.privateContentView.loadingStatus = RESULT_LOADING_STATUS_NETWORK_ERROR;
    } else if(error.code == -2202){
        self.privateContentView.loadingStatus = RESULT_LOADING_STATUS_LOAD_FAILED;
    } else if (error.code == 404) {
        self.privateContentView.loadingStatus = RESULT_LOADING_STATUS_NO_FILE;
    }
}

- (void)onCreate:(UIView *)view{
    [self.view addSubview:self.weexView];
    self.privateContentView.loadingStatus = RESULT_LOADING_STATUS_LOAD_FINISH;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (WXResultBackgroundView *)privateContentView{
    if (!_privateContentView) {
        __weak typeof(self) weakSelf = self;
        WXResultBackgroundView *backgroundView = [WXResultBackgroundView objectWithHandler:^{
            [weakSelf _renderWithURL:weakSelf.sourceURL];
        }];
        backgroundView.tag = RESULT_BACKGROUND_VIEW_TAG;
        backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:backgroundView];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[backgroundView]-0-|" options:0 metrics:@{} views:@{@"backgroundView":backgroundView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[backgroundView]-0-|" options:0 metrics:@{} views:@{@"backgroundView":backgroundView}]];
        
        UITabBarController<UIGestureRecognizerDelegate> *tabBarController = (id)self.tabBarController;
        if (!tabBarController || (![tabBarController.viewControllers indexOfObject:self] && [tabBarController respondsToSelector:@selector(gestureRecognizerShouldBegin:)] && [tabBarController gestureRecognizerShouldBegin:tabBarController.navigationController.interactivePopGestureRecognizer])) {
            
            UIImage *image = nil;
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSURL *url = [bundle URLForResource:@"tHybridKit" withExtension:@"bundle"];
            if (url) {
                NSBundle *targetBundle = [NSBundle bundleWithURL:url];
                image = [UIImage imageNamed:@"navigation_goback.png" inBundle:targetBundle compatibleWithTraitCollection:nil];
                image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            }
            
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:(UIBarButtonItemStylePlain) target:self action:@selector(leftBarButtonAction)];
            backgroundView.navigationItem.leftBarButtonItem = item;
        }
        
        _privateContentView = backgroundView;
    }
    [self.view addSubview:_privateContentView];
    
    return _privateContentView;
}
- (void)leftBarButtonAction{
    //返回上一页
    [self.navigationController popViewControllerAnimated:YES];
}

@end
