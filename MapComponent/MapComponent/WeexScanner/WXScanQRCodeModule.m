//
//  WXScanQRCodeModule.m
//  TCMBuyer
//
//  Created by ZZJ on 2019/7/18.
//  Copyright © 2019 Taocaimall. All rights reserved.
//

#import "WXScanQRCodeModule.h"
#import <AVFoundation/AVFoundation.h>
//#import <YYKit.h>

@interface WXScanQRCodeModule ()<TCMScanQRCodeControllerDelegate>
@property (nonatomic,copy)WXModuleCallback callback;
@property (nonatomic,copy)void(^backAnimated)(BOOL animated);
@end
@implementation WXScanQRCodeModule
@synthesize weexInstance;

//android使用fireGlobalEventCallback通知发送，名字scanQrCallback
WX_EXPORT_METHOD(@selector(scanQRCode:));
WX_EXPORT_METHOD(@selector(backAnimated:));

- (void)scanQRCode:(WXModuleCallback)callback {
    TCMScanQRCodeController *qrVc = [[TCMScanQRCodeController alloc] init];
    qrVc.delegate = self;
    self.callback = callback;
    
    if (self.weexInstance.viewController.navigationController) {
        [self.weexInstance.viewController.navigationController pushViewController:qrVc animated:YES];
    }else{
        [self.weexInstance.viewController presentViewController:qrVc animated:YES completion:^{
            
        }];
    }
    
}

- (void)backAnimated:(BOOL)animated {
    
     if (self.weexInstance.viewController.navigationController) {
         if (animated) {
             [self.weexInstance.viewController.navigationController popViewControllerAnimated:animated];
         }else {
             NSArray *vcs = self.weexInstance.viewController.navigationController.viewControllers;
             NSMutableArray *vcArray = [NSMutableArray arrayWithArray:vcs];
             [vcArray enumerateObjectsUsingBlock:^(UIViewController  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 if ([obj isKindOfClass:[TCMScanQRCodeController class]]) {
                     [vcArray removeObject:obj];
                     *stop = YES;
                     return ;
                 }
             }];
             
             self.weexInstance.viewController.navigationController.viewControllers = vcArray;
         }
         
     }else{
         [self.weexInstance.viewController dismissViewControllerAnimated:animated completion:^{
         }];
     }
}

#pragma mark -- TCMScanQRCodeControllerDelegate
-(void)scanQRCodeController:(UIViewController*)vc byMessage:(NSString*)message {
    if (self.callback) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:message forKey:@"result"];
        self.callback(dic);
    }
    
}

@end

#define IPHONE_SIZE     [[UIScreen mainScreen] bounds].size

@interface TCMScanQRCodeController ()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,CAAnimationDelegate>
@property (nonatomic,strong)AVCaptureSession * session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (strong, nonatomic)UIButton *torchBtn;//灯泡开关

@property (nonatomic,strong)UINavigationBar *navigationBar;
@property (nonatomic,strong)UINavigationItem *navItem;

@end

#define iS_Iphone_X (([UIScreen mainScreen].bounds.size.width == 375 && [UIScreen mainScreen].bounds.size.height != 667) || ([UIScreen mainScreen].bounds.size.width == 414 && [UIScreen mainScreen].bounds.size.height != 736))

@implementation TCMScanQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    [self instanceDevice];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.navigationController&&!self.navigationController.navigationBarHidden) {
        NSLog(@"vv");
    }else{
        
        self.navItem.title = self.title;
        [self.view addSubview:self.navigationBar];
        
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self getAuthorization] && ![self.view.layer.sublayers.firstObject isKindOfClass:[AVCaptureVideoPreviewLayer class]]) {
        //从设置返回调用
        [self instanceDevice];
    }
    
    [self.session startRunning];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.session.isRunning) {
        [self.session stopRunning];
    }

    if (!self.torchBtn.hidden&&self.torchBtn.selected) {
        [self turnTorchAction:self.torchBtn];
    }
}

//配置相机属性
- (void)instanceDevice{
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=CGRectMake(0, 64, self.view.layer.bounds.size.width, self.view.layer.bounds.size.height-64);
    [self.view.layer insertSublayer:layer atIndex:0];
    
    [self overlayPickerView];
    
    [_session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
    
}

//创建扫码页面
- (void)overlayPickerView {
    
    //左侧的view
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (IPHONE_SIZE.width*0.25)*0.5, self.view.frame.size.height)];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    //右侧的view
    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(IPHONE_SIZE.width-(IPHONE_SIZE.width*0.25)*0.5, 0, (IPHONE_SIZE.width*0.25)*0.5, self.view.frame.size.height)];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    //最上部view
    UIImageView* upView = [[UIImageView alloc] initWithFrame:CGRectMake((IPHONE_SIZE.width*0.25)*0.5, 0, IPHONE_SIZE.width*0.75, (self.view.frame.size.height-IPHONE_SIZE.width*0.75)*0.5-64)];
    upView.alpha = 0.5;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //底部view
    UIImageView * downView = [[UIImageView alloc] initWithFrame:CGRectMake((IPHONE_SIZE.width*0.25)*0.5, CGRectGetMaxY(upView.frame)+IPHONE_SIZE.width*0.75, IPHONE_SIZE.width*0.75, ((self.view.frame.size.height-IPHONE_SIZE.width*0.75)*.5 + 44+ 40))];
    downView.alpha = 0.5;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    UIImageView *centerView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame), CGRectGetMaxY(upView.frame), IPHONE_SIZE.width*0.75, IPHONE_SIZE.width*0.75)];
    centerView.image = [UIImage imageNamed:@"扫描框.png"];
    centerView.contentMode = UIViewContentModeScaleAspectFit;
    centerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:centerView];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake((IPHONE_SIZE.width*0.25)*0.5, CGRectGetMaxY(upView.frame), IPHONE_SIZE.width*0.75, 2)];
    line.tag = 1800;
    line.image = [UIImage imageNamed:@"扫描线.png"];
    line.contentMode = UIViewContentModeScaleAspectFill;
    line.backgroundColor = [UIColor clearColor];
    [self.view addSubview:line];
    
    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, IPHONE_SIZE.width, 60)];
    msg.backgroundColor = [UIColor clearColor];
    msg.textColor = [UIColor whiteColor];
    msg.textAlignment = NSTextAlignmentCenter;
    msg.font = [UIFont systemFontOfSize:16.0];
    msg.text = @"扫一扫";
//    [self.view addSubview:msg];
    
    
    UILabel *label  = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMinY(downView.frame)+30, IPHONE_SIZE.width-20, 30)];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15.0];
    //将二维码放入框中即可自动扫描
    label.text = @"将取景框对准二维码，即可自动扫描完成";
    [self.view addSubview:label];
    
    [self.view addSubview:self.torchBtn];
    self.torchBtn.center = self.view.center;
}

//监听扫码状态-修改扫描动画
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context{
    if ([object isKindOfClass:[AVCaptureSession class]]) {
        BOOL isRunning = ((AVCaptureSession *)object).isRunning;
        if (isRunning) {
            [self addAnimation];
        }else{
            [self removeAnimation];
        }
    }
}

//添加扫码动画
- (void)addAnimation{
    UIView *line = [self.view viewWithTag:1800];
    
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:[NSNumber numberWithFloat:0]];
    [animationMove setToValue:[NSNumber numberWithFloat:IPHONE_SIZE.width*.75-2]];
    animationMove.duration = 2;
    //设置动画代理需放置循环引用
//    animationMove.delegate = self;
    animationMove.repeatCount  = OPEN_MAX;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    if ([self getAuthorization]) {
        [line.layer addAnimation:animationMove forKey:@"LineAnimation"];
    }
    
}
//去除扫码动画
- (void)removeAnimation{
    UIView *line = [self.view viewWithTag:1800];
    [line.layer removeAnimationForKey:@"LineAnimation"];
}

#pragma mark --AVCaptureMetadataOutputObjectsDelegate
// 获取扫码结果
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count == 0) {
        return;
    }
    AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];
    NSString *QRMsg = metadataObject.stringValue;
    NSLog(@"二维码:%@\n",QRMsg);
    [self.session stopRunning];
    
    //    [self playSoundEffect:@"QRcodeSuccess" ofType:@"wav" andAlert:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(scanQRCodeController:byMessage:)]) {
            [self.delegate scanQRCodeController:self byMessage:QRMsg];
        }
    });
    
}

#pragma mark -- AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    // brightnessValue 值代表光线强度，值越小代表光线越暗
    NSLog(@"光线%f", brightnessValue);
    if (brightnessValue <= -2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.torchBtn.hidden = NO;
        });
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.device.torchMode == AVCaptureTorchModeOff) {
                self.torchBtn.hidden = YES;
            }
        });
    }
}


-(void)playSoundEffect:(NSString *)name ofType:(NSString*)type andAlert:(BOOL)useAlert{
    NSString *audioFile=[[NSBundle mainBundle] pathForResource:name ofType:type];
    NSURL *fileUrl=[NSURL fileURLWithPath:audioFile];
    //1.获得系统声音ID
    SystemSoundID mySoundID = 0;
    /**
     * inFileUrl:音频文件url
     * outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
     */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &mySoundID);
    //如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    //    AudioServicesAddSystemSoundCompletion(mySoundID, NULL, NULL, soundCompleteCallback, NULL);
    //2.播放音频
    if (useAlert) {
        AudioServicesPlayAlertSound(mySoundID);//播放音效并震动
    }else{
        AudioServicesPlaySystemSound(mySoundID);//播放音效
    }
}


#pragma mark -  打开/关闭手电筒
- (void)turnTorchAction:(UIButton*)sender {
    sender.selected = !sender.selected;
    if ([self.device hasTorch] && [self.device hasFlash]){
        [self.device lockForConfiguration:nil];
        if (sender.selected) {
            [self.device setTorchMode:AVCaptureTorchModeOn];
            [self.device setFlashMode:AVCaptureFlashModeOn];
        } else {
            [self.device setTorchMode:AVCaptureTorchModeOff];
            [self.device setFlashMode:AVCaptureFlashModeOff];
        }
        [self.device unlockForConfiguration];
    } else {
        NSLog(@"当前设备没有闪光灯");
    }
}

#pragma mark - 获取权限
- (BOOL)getAuthorization {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized){
        return YES;
    }else if (authStatus == AVAuthorizationStatusNotDetermined){
        return NO;
    }else {
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"相机权限受限" message:@"请在iPhone的\"设置->隐私->相机\"选项中,允许\"淘菜猫-商户版\"访问您的相机." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]){
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                    } else {
                        // Fallback on earlier versions
                        [[UIApplication sharedApplication] openURL:url];
                    }
                    
                }
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        return NO;
    }
    
}

#pragma mark --getter
-(AVCaptureSession*)session {
    if (!_session) {
        //获取摄像设备
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _device = device;
        //创建输入流
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        //创建输出流
        AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
        //设置代理 在主线程里刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //闪光灯
        AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        //初始化链接对象
        _session = [[AVCaptureSession alloc]init];
        //高质量采集率
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if (input) {
            [_session addInput:input];
        }
        if (output) {
            [_session addOutput:output];
            //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
            NSMutableArray *a = [[NSMutableArray alloc] init];
            if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
                [a addObject:AVMetadataObjectTypeQRCode];
            }
            if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
                [a addObject:AVMetadataObjectTypeEAN13Code];
            }
            if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
                [a addObject:AVMetadataObjectTypeEAN8Code];
            }
            if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
                [a addObject:AVMetadataObjectTypeCode128Code];
            }
            output.metadataObjectTypes=a;
        }
        
        if ([_session canAddOutput:dataOutput]) {
            [_session addOutput:dataOutput];
        }
    }
    return _session;
}

- (UINavigationBar *)navigationBar{
    if (!_navigationBar) {
        _navigationBar = [[UINavigationBar alloc] init];
        
        CGFloat statusH = iS_Iphone_X ? 44 : 20;
        _navigationBar.frame = CGRectMake(0, statusH, IPHONE_SIZE.width, 44);
        
        UIColor *barColor = [UINavigationBar appearance].barTintColor;
        if (!barColor){
            barColor = UIColor.whiteColor;
        }
        _navigationBar.tintColor = barColor;
        _navigationBar.translucent = NO;
        
        UIColor *titleColor = [UIColor colorWithRed:95.0/255 green:95.0/255 blue:95.0/255 alpha:1];;
        
        [_navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: titleColor,NSFontAttributeName: [UIFont boldSystemFontOfSize:22]}];
        UIColor *shadowColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
//        [_navigationBar setShadowImage:[UIImage imageWithColor:shadowColor]];
        
        UIView *statusView = [UIView new];
        statusView.frame = CGRectMake(0, -statusH, IPHONE_SIZE.width, statusH);
        statusView.backgroundColor = _navigationBar.tintColor;
        [_navigationBar addSubview:statusView];
        
        _navigationBar.items = @[self.navItem];
    }
    
    return _navigationBar;
}

- (UINavigationItem *)navItem{
    if (!_navItem) {
        UINavigationItem *item = [[UINavigationItem alloc] init];
        _navItem = item;
        [self addBackBarButtonItem];
    }
    
    return _navItem;
}

-(void)addBackBarButtonItem {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tHybridKit" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
   UIImage *image = [UIImage imageNamed:@"navigation_goback" inBundle:bundle compatibleWithTraitCollection:nil];
    
    button.frame = CGRectMake(0, 0, image.size.width > 36 ? image.size.width:36, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -26, 0, 0);
    [button addTarget:self action:@selector(leftBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *itemback = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:(UIBarButtonItemStylePlain) target:self action:@selector(leftBarButtonAction)];
    
    _navItem.leftBarButtonItem = itemback;
    
}

-(UIButton*)torchBtn {
    if (!_torchBtn) {
        _torchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_torchBtn setTitle:@"打开" forState:UIControlStateNormal];
        [_torchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_torchBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        _torchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_torchBtn addTarget:self action:@selector(turnTorchAction:) forControlEvents:UIControlEventTouchUpInside];
        _torchBtn.bounds = CGRectMake(0, 0, 45, 45);
        _torchBtn.hidden = YES;
        
    }
    return _torchBtn;
}

-(void)leftBarButtonAction {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
}


-(void)dealloc{
    [_session removeObserver:self forKeyPath:@"running" context:nil];
    NSLog(@"xx dealloc");
}

@end
