//
//  WXResultBackgroundView.m
//  MapComponent
//
//  Created by ZZJ on 2019/7/1.
//  Copyright © 2019 Jion. All rights reserved.
//

#import "WXResultBackgroundView.h"
#import "DemoDefine.h"

const NSInteger RESULT_BACKGROUND_VIEW_TAG = 1024;
const NSInteger RESULT_CREATE_VIEW_TAG = 2048;
@interface WXResultBackgroundView()
@property (nonatomic, strong) UIView *navigationView;
@property (nonatomic, strong) UIView *optionView;
@property (nonatomic, copy) void(^handler)(void);

@end

@implementation WXResultBackgroundView
+ (instancetype)objectWithHandler:(void(^)(void))handler{
    WXResultBackgroundView *obj = [[self alloc] init];
    UIView *containView = [[UIView alloc] init];
    containView.translatesAutoresizingMaskIntoConstraints = NO;
    [obj addSubview:containView];
    
    [obj addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containView]-0-|" options:0 metrics:@{} views:@{@"containView":containView}]];
    [obj addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[containView]-0-|" options:0 metrics:@{} views:@{@"containView":containView}]];

    obj.handler = handler;
    
    return obj;
}
- (void)setLoadingStatus:(RESULT_LOADING_STATUS)loadingStatus{
    
    switch (loadingStatus) {
        case RESULT_LOADING_STATUS_LOADING:
            [self resetOptionView:nil];
            break;
        case RESULT_LOADING_STATUS_NETWORK_ERROR:
            [self networkError];
            break;
        case RESULT_LOADING_STATUS_LOAD_FAILED:
            [self loadFail];
            break;
        case RESULT_LOADING_STATUS_NO_FILE:
            [self noFile];
            break;
        case RESULT_LOADING_STATUS_LOAD_FINISH:
            self.exclusiveTouch = NO;
            break;
        case RESULT_LOADING_STATUS_FILE_EXECUTION_FAILED:
            [self executionFail];
            break;
        case RESULT_LOADING_STATUS_RENDER_FINISH:
            if (_loadingStatus == RESULT_LOADING_STATUS_FILE_EXECUTION_FAILED) {
                return;
            }
            [self finish];
            break;
    }
    _loadingStatus = loadingStatus;
}
- (void)networkError{
    UILabel *label = [[UILabel alloc] init];
    [self resetOptionView:label];
    label.text = @"网络不可用,请检查网络后重试！";
    label.textAlignment = NSTextAlignmentCenter;
}

- (void)loadFail{
    [self failView];
}

- (void)noFile{
    UILabel *label = [[UILabel alloc] init];
    [self resetOptionView:label];
    label.text = @"文件不存在,请稍后重试！";
    label.textAlignment = NSTextAlignmentCenter;
}

- (void)executionFail{
    UILabel *label = [[UILabel alloc] init];
    [self resetOptionView:label];
    NSLog(@"%@", label);
    label.text = @"程序异常,请稍后重试！";
    label.textAlignment = NSTextAlignmentCenter;
    self.hidden = NO;
    
}

-(void)failView {
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"tHybridKit" withExtension:@"bundle"];
    if (url) {
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeCenter;
        NSBundle *targetBundle = [NSBundle bundleWithURL:url];
        UIImage *image = [UIImage imageNamed:@"404.png"
                                    inBundle:targetBundle
               compatibleWithTraitCollection:nil];
        imageView.image = image;
        [self resetOptionView:imageView];
    }else{
        UILabel *label = [[UILabel alloc] init];
        [self resetOptionView:label];
        label.text = @"加载失败或无法连接到服务器";
        label.textAlignment = NSTextAlignmentCenter;
    }
    
}

- (void)finish{
    [self resetOptionView:nil];
    self.hidden = YES;
}


- (void)action{
    [self resetOptionView:nil];
    if (self.handler) {
        self.handler();
    }
}

- (UINavigationBar *)navigationBar{
    if (!_navigationBar) {
        UIView *navigationView = [[UIView alloc] init];
        navigationView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:navigationView];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navigationView]|" options:0 metrics:@{} views:@{@"navigationView":navigationView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[navigationView(height)]" options:0 metrics:@{@"height":@(44+statusBarH)} views:@{@"navigationView":navigationView}]];

        _navigationView = navigationView;
        
        UINavigationBar *bar = [[UINavigationBar alloc] init];
        
        UIColor *barColor = [UINavigationBar appearance].barTintColor;
//        if (self.handler.noption.titleColor) {
//            barColor = self.handler.noption.barColor;
//        }
//
        bar.barTintColor = barColor;
        navigationView.backgroundColor = barColor;
        bar.translucent = NO;
        bar.translatesAutoresizingMaskIntoConstraints = NO;
        [navigationView addSubview:bar];
        [navigationView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bar]|" options:0 metrics:@{} views:@{@"bar":bar}]];
        [navigationView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bar]|" options:0 metrics:@{} views:@{@"bar":bar}]];

        _navigationBar = bar;
    }
    
    return _navigationBar;
}

- (UINavigationItem *)navigationItem{
    if (!_navigationItem) {
        UINavigationItem *item = [[UINavigationItem alloc] init];
        self.navigationBar.items = @[item];
        item.title = @"淘菜猫";
        UIColor *titleColor = UIColor.whiteColor;
//        if (self.handler.noption.titleColor) {
//            titleColor = self.handler.noption.titleColor;
//        }
        [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: titleColor,
                                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                                                     }];
        
        _navigationItem = item;
    }
    
    return _navigationItem;
}


- (NSString *)title{
    return self.navigationItem.title;
}
- (void)setTitle:(NSString *)title{
    if (!title.length) {
        self.navigationView.backgroundColor = [UIColor whiteColor];
        self.navigationBar.hidden = YES;
        
//        [self.navigationView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(0);
//        }];
        
        return;
    }
    self.navigationItem.title = title;
}
- (UIBarButtonItem *)leftBarButtonItem{
    return self.navigationItem.leftBarButtonItem;
}
- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem{
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (UIBarButtonItem *)rightBarButtonItem{
    return self.navigationItem.rightBarButtonItem;
}
- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem{
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}
- (void)resetOptionView:(UIView *)childView{
    [self.optionView removeFromSuperview];
    
    if (!childView) {
        return;
    }
    UIView *view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:view];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:@{} views:@{@"view":view}]];
    if (self.navigationView) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[navigationView][view]|" options:0 metrics:@{} views:@{@"view":view,@"navigationView":self.navigationView}]];
    }else{
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:@{} views:@{@"view":view}]];
    }
    
    
    childView.backgroundColor = UIColor.whiteColor;
    childView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:childView];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[childView]|" options:0 metrics:@{} views:@{@"childView":childView}]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[childView(height)]" options:0 metrics:@{@"height":@(250)} views:@{@"childView":childView}]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-100]];

    self.optionView = view;
    if (childView) {
        UIButton *button = [[UIButton alloc] init];
        [button setBackgroundColor:[UIColor colorWithRed:195/255.0 green:45/255.0 blue:74/255.0 alpha:1.0]];
        [button setTitle:@"重新加载" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.layer.cornerRadius = 5.0;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [view addSubview:button];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(width)]" options:0 metrics:@{@"width":@(100)} views:@{@"button":button}]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[childView]-30-[button(height)]" options:0 metrics:@{@"height":@(40)} views:@{@"button":button,@"childView":childView}]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];

        [button addTarget:self action:@selector(action) forControlEvents:(UIControlEventTouchUpInside)];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
