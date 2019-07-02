//
//  WXMapComponent.m
//  Superior
//
//  Created by ZZJ on 2019/5/13.
//  Copyright © 2019 淘菜猫. All rights reserved.
//

#import "WXMapComponent.h"
#import "WXPaopaoView.h"
#import "TCMLocationManager.h"
#import "WXPointAnnotation.h"
#import "SDWebImageManager.h"

#define kStreetImg @"StreetImgKey"
//#define kAnnotationImg [UIImage imageNamed:@"location_marker"]
#define kAnnotationImg \
[UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:@"location_marker" ofType:@"png"]]

@interface WXMapComponent ()<BMKMapViewDelegate>
//用来记录该事件是否生效
@property (nonatomic,assign)BOOL mapLoaded;
//点击标注上泡泡事件
@property (nonatomic,assign)BOOL selectBubble;
//是否显示用户位置
@property (nonatomic,assign)BOOL showsUserLocation;
//用户位置
@property(nonatomic,strong)NSDictionary *userLocation;
//是否实时显示路况信息
@property(nonatomic,assign)BOOL showTraffic;
//是否展示地图缩放按钮
@property (nonatomic,assign)BOOL zoomControlsEnabled;
//缩放等级:4-21
@property(nonatomic,assign)CGFloat zoomLevel;
//是否显式比例尺
@property(nonatomic,assign)BOOL showScaleBar;
/// 比例尺的位置，设定坐标以BMKMapView左上角为原点，向右向下增长
@property (nonatomic) CGPoint scaleBarPosition;
//是否可自动添加标注
@property(nonatomic,assign)BOOL autoAddAnnotation;
@property (nonatomic,strong)id <BMKAnnotation> autoAnnotation;

@property (nonatomic,strong)BMKMapView *mapView;
@property (nonatomic,strong)TCMLocationManager *locationManager;
//用于临时存储选中的标注
@property (nonatomic,strong)id<BMKAnnotation> selectAnnotation;

@end
@implementation WXMapComponent

WX_EXPORT_METHOD(@selector(addAnnotation:));
WX_EXPORT_METHOD(@selector(addAnnotations:));
WX_EXPORT_METHOD(@selector(removeAnnotation:));
WX_EXPORT_METHOD(@selector(removeAnnotations));
//地图截屏，返回bool值
WX_EXPORT_METHOD(@selector(saveImage));

//自定义属性
- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance {
    if(self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        
        if (attributes[@"userLocation"]) {
            _userLocation = attributes[@"userLocation"];
            if (_userLocation[@"latitude"]&&_userLocation[@"longitude"]) {
                _showsUserLocation = YES;
            }
        }
        
        if (attributes[@"showTraffic"]) {
            _showTraffic = [WXConvert BOOL: attributes[@"showTraffic"]];
        }else{
            _showTraffic = NO;
        }
        if (attributes[@"zoomLevel"]) {
            _zoomLevel = [WXConvert CGFloat: attributes[@"zoomLevel"]];
        }else{
            _zoomLevel = 14;
        }
        
        if (attributes[@"zoomControlsEnabled"]) {
            _zoomControlsEnabled = [WXConvert BOOL: attributes[@"zoomControlsEnabled"]];
        }else{
            _zoomControlsEnabled = NO;
        }
        if (attributes[@"showScaleBar"]) {
            _showScaleBar = [WXConvert BOOL: attributes[@"showScaleBar"]];
        }else{
            _showScaleBar = YES;
        }
        
        if (attributes[@"scaleBarPosition"]) {
            NSDictionary *barPoint = attributes[@"scaleBarPosition"];
            CGFloat x = barPoint[@"x"]?[WXConvert WXPixelType: barPoint[@"x"] scaleFactor:self.weexInstance.pixelScaleFactor]:1;
            CGFloat y =  barPoint[@"y"]?[WXConvert WXPixelType: barPoint[@"y"] scaleFactor:self.weexInstance.pixelScaleFactor]-20:1;
            CGPoint position = CGPointMake(x,y);
            _scaleBarPosition = position;
        }
        
    }
    return self;
}

- (UIView *)loadView {
    _mapView = [BMKMapView new];
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(31.242727, 121.513295) animated:NO];
    return _mapView;
}

- (void)viewDidLoad {
    ((BMKMapView*)self.view).delegate = self;
    //设置定位的状态
    ((BMKMapView*)self.view).userTrackingMode = BMKUserTrackingModeNone;
    [((BMKMapView*)self.view) setZoomLevel:_zoomLevel];
    [((BMKMapView*)self.view) setTrafficEnabled:_showTraffic];
    ((BMKMapView*)self.view).showsUserLocation = _showsUserLocation;
    ((BMKMapView*)self.view).showMapScaleBar = _showScaleBar;
    if (!CGPointEqualToPoint(_scaleBarPosition,CGPointZero)) {
        ((BMKMapView*)self.view).mapScaleBarPosition = _scaleBarPosition;
    }
    
    //设置是否显示缩放按钮，百度地图没有提供
//    _mapView.showsZoomControls = _zoomControlsEnabled;
    BMKLocationViewDisplayParam *param = [BMKLocationViewDisplayParam new];
    param.accuracyCircleFillColor = [UIColor colorWithRed:255/255.0 green:0 blue:51/255.0 alpha:0.5];
    param.accuracyCircleStrokeColor = [UIColor colorWithRed:255/255.0 green:0 blue:51/255.0 alpha:0.2];
    param.locationViewImage = kAnnotationImg;
    param.isRotateAngleValid = NO;
    param.isAccuracyCircleShow =YES;
    param.locationViewOffsetY = 0;
    param.locationViewOffsetX = 0;
    //                [weakSelf.mapView updateLocationViewWithParam:param];
    
    //当mapview即将被显式的时候调用，不调用该方法指南针不显示
    [_mapView viewWillAppear];
}

-(void)viewWillUnload{
    //当mapView即将被隐藏的时候调用，存储当前mapView的状态
    [_mapView viewWillDisappear];
    if (_mapView.delegate) {
        ((BMKMapView*)self.view).delegate = nil;
    }
}

-(void)viewDidUnload{
    NSLog(@"当前view组件map被释放");
}

//当属性更新时，同步给地图控件
- (void)updateAttributes:(NSDictionary *)attributes {
    
    if (attributes[@"userLocation"]) {
        _userLocation = attributes[@"userLocation"];
        BOOL showUserLoc = _userLocation.allKeys>0&&_userLocation[@"latitude"]&&_userLocation[@"longitude"];
        _showsUserLocation = showUserLoc;
        ((BMKMapView*)self.view).showsUserLocation = _showsUserLocation;
        if (showUserLoc) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[_userLocation[@"latitude"] doubleValue] longitude:[_userLocation[@"longitude"] doubleValue]];
            
            BMKUserLocation * userLoc = [[BMKUserLocation alloc] init];
            userLoc.location = location;
            [((BMKMapView*)self.view) updateLocationData:userLoc];
            [((BMKMapView*)self.view) setCenterCoordinate:userLoc.location.coordinate animated:YES];
        }
        
    }
    
    if (attributes[@"showTraffic"]) {
        _showTraffic = [WXConvert BOOL: attributes[@"showTraffic"]];
        [((BMKMapView*)self.view) setTrafficEnabled:_showTraffic];
    }
    
    if (attributes[@"zoomLevel"]) {
        _zoomLevel = [WXConvert CGFloat: attributes[@"zoomLevel"]];
        [((BMKMapView*)self.view) setZoomLevel:_zoomLevel];
    }
    if (attributes[@"zoomControlsEnabled"]) {
        _zoomControlsEnabled = [WXConvert BOOL: attributes[@"zoomControlsEnabled"]];
//        ((BMKMapView*)self.view).showsZoomControls = _zoomControlsEnabled;
    }
    if (attributes[@"showScaleBar"]) {
        _showScaleBar = [WXConvert BOOL: attributes[@"showScaleBar"]];
        ((BMKMapView*)self.view).showMapScaleBar = _showScaleBar;
    }
    
    if (attributes[@"scaleBarPosition"]) {
        NSDictionary *barPoint = attributes[@"scaleBarPosition"];
        CGFloat x = barPoint[@"x"]?[WXConvert WXPixelType: barPoint[@"x"] scaleFactor:self.weexInstance.pixelScaleFactor]:1;
        CGFloat y =  barPoint[@"y"]?[WXConvert WXPixelType: barPoint[@"y"] scaleFactor:self.weexInstance.pixelScaleFactor]-20:1;
        CGPoint position = CGPointMake(x,y);
        _scaleBarPosition = position;
        if (CGPointEqualToPoint(_scaleBarPosition,CGPointZero)) {
            ((BMKMapView*)self.view).mapScaleBarPosition = _scaleBarPosition;
        }
    }
    
}


#pragma mark -- 事件
- (void)addEvent:(NSString *)eventName {
    if ([eventName isEqualToString:@"mapLoaded"]) {
        _mapLoaded = YES;
    }
    if ([eventName isEqualToString:@"selectBubble"]) {
        _selectBubble = YES;
    }
    if ([eventName isEqualToString:@"autoAddAnnotation"]) {
        _autoAddAnnotation = YES;
    }
    
}

- (void)removeEvent:(NSString *)eventName {
    if ([eventName isEqualToString:@"mapLoaded"]) {
        _mapLoaded = NO;
    }
    if ([eventName isEqualToString:@"selectBubble"]) {
        _selectBubble = NO;
    }
    if ([eventName isEqualToString:@"autoAddAnnotation"]) {
        _autoAddAnnotation = NO;
    }
}

#pragma mark -- 点标记
-(void)addAnnotation:(NSDictionary*)dicAnnotation{
    WXPointAnnotation *pointAnnotation = [self objectWithDictionary:dicAnnotation];
    [(BMKMapView*)self.view addAnnotation:pointAnnotation];
    
}

- (void)addAnnotations:(NSArray*)annotations {
    NSMutableArray *annotationsArray = [NSMutableArray array];
    for (NSDictionary *dicAnnotation in annotations) {
        WXPointAnnotation *pointAnnotation = [self objectWithDictionary:dicAnnotation];
        [annotationsArray addObject:pointAnnotation];
    }
    if (annotationsArray.count) {
       [(BMKMapView*)self.view addAnnotations:annotationsArray];
    }
    
}

-(WXPointAnnotation*)objectWithDictionary:(NSDictionary*)dicAnnotation{
    MapAnnotationModel *model = [MapAnnotationModel modelWithDictionary:dicAnnotation];
    //添加标注数据对象。
    WXPointAnnotation *pointAnnotation = [[WXPointAnnotation alloc] init];
    pointAnnotation.annotationConfig = model;
    //经纬度
    NSNumber *latitude = [NSNumber numberWithDouble:[WXConvert CGFloat: dicAnnotation[@"latitude"]]];
    NSNumber *longitude = [NSNumber numberWithDouble:[WXConvert CGFloat: dicAnnotation[@"longitude"]]];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
    //标题
    pointAnnotation.title = dicAnnotation[@"title"];
    //副标题
    pointAnnotation.subtitle = dicAnnotation[@"subtitle"];
    
    return pointAnnotation;
}

- (void)removeAnnotation:(NSDictionary*)dicAnnotation{
    WXPointAnnotation *targetAnnotation = [self objectWithDictionary:dicAnnotation];
    id <BMKAnnotation> annotation = nil;
    for (WXPointAnnotation *pointAnnotation in _mapView.annotations) {
        if (targetAnnotation.coordinate.latitude == pointAnnotation.coordinate.latitude&&targetAnnotation.coordinate.longitude == pointAnnotation.coordinate.longitude) {
            annotation = pointAnnotation;
            break;
        }
    }
    if (annotation != nil) {
        //删除指定的单个点标记
        [_mapView removeAnnotation:annotation];
    }
}
- (void)removeAnnotations {
    [_mapView removeAnnotations:_mapView.annotations];
}

//地图截屏,地图必须加载完成
-(int)saveImage{
    if (!_mapLoaded) {
        return !_mapLoaded;
    }
    BOOL result = [MapAnnotationModel saveImage:_mapView];
    return result;
}

#pragma mark -- 点聚合
//需要下载官方demo添加相关类

#pragma mark -- BMKMapViewDelegate
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    if (_mapLoaded) {
        //给前端发送事件地图加载完成
        [self fireEvent:@"mapLoaded" params:@{@"result":@"success"} domChanges:nil];
    }
    //设置用户位置
    if(_userLocation&&_userLocation.allKeys>0){
        if (_userLocation[@"latitude"]&&_userLocation[@"longitude"]) {
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[_userLocation[@"latitude"] doubleValue] longitude:[_userLocation[@"longitude"] doubleValue]];
            BMKUserLocation * userLoc = [[BMKUserLocation alloc] init];
            userLoc.location = location;
            [mapView updateLocationData:userLoc];
            [mapView setCenterCoordinate:userLoc.location.coordinate animated:YES];
        }
    }
    //设置指南针
    [mapView setCompassPosition:CGPointMake(10, 30)];
    //设置指南针图片
    [mapView setCompassImage:[UIImage imageNamed:@"icon_compass"]];
    
}
//地图渲染完毕后会调用
- (void)mapViewDidFinishRendering:(BMKMapView *)mapView{
    
}

//添加annotation点标记
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        BMKPinAnnotationView*annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        WXPointAnnotation *pointAnnotation = (WXPointAnnotation*)annotation;
        MapAnnotationModel *annotationModel = pointAnnotation.annotationConfig;
        //标注样式公共参数：
        //设置气泡可以弹出，默认为NO
        annotationView.canShowCallout= [WXConvert BOOL:annotationModel.canShowCallout];
        //设置标注动画显示，默认为NO
        annotationView.animatesDrop = YES;
        //设置标注可以拖动，默认为NO
        annotationView.draggable = YES;
        
        if ([annotationModel.pointType integerValue]==0) {
            //1.设置标注样式
            annotationView.pinColor = annotationModel.pinColorType;
            
        }else if ([annotationModel.pointType integerValue]==1){
            //2.自定义标注图标
            if ([annotationModel.image hasPrefix:@"http"]) {
                annotationView.image = kAnnotationImg;
                __block BMKPinAnnotationView *annotationViewB = annotationView;
                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:annotationModel.image] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    annotationViewB.image = [MapAnnotationModel mergeFromImage:image toImage:kAnnotationImg];
                }];
                
            }else if([annotationModel.image componentsSeparatedByString:@"/"].count>1){
                NSString *imageSrc = annotationModel.image;
                NSString * newURL = [imageSrc copy];
                WX_REWRITE_URL(imageSrc, WXResourceTypeImage, self.weexInstance);
                annotationView.image = kAnnotationImg;
                __block BMKPinAnnotationView *annotationViewB = annotationView;
                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:newURL] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (image) {
                        annotationViewB.image = image;
                    }
                }];
            }else{
                if ([annotationModel.image isEqualToString:kStreetImg]) {
                    //在设置气泡时重制标注
                    annotationView.image = kAnnotationImg;
                }else{
                    UIImage *mImage = [UIImage imageNamed:annotationModel.image];
                    if (mImage) {
                        annotationView.image = mImage;
                    }else{
                        annotationView.image = kAnnotationImg;
                    }
                    
                }
                
            }
            
        }
        if ([annotationModel.paopaoType integerValue] == 1) {
            //3.添加自定义气泡
            WXPaopaoView *customPopView = [[WXPaopaoView alloc] init];
            customPopView.image = [UIImage imageNamed:@"defaultImage"];
            if ([annotationModel.image hasPrefix:@"http"]) {
                __block WXPaopaoView *popView = customPopView;
                [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:annotationModel.image] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    popView.image = image;
                }];
                
            }else{
                if ([annotationModel.image isEqualToString:kStreetImg]) {
                    
                    __block BMKPinAnnotationView *annotationViewB = annotationView;
                    [MapAnnotationModel requsetStreetImgWithCoordinate:pointAnnotation.coordinate callBlock:^(UIImage *image) {
                        if (image) {
                            annotationViewB.image = [MapAnnotationModel mergeFromImage:image toImage:kAnnotationImg];
                            customPopView.image = image;
                        }
                    }];
                }else{
                    customPopView.image = [UIImage imageNamed:annotationModel.image];
                }
                
            }
            
            customPopView.title = annotationModel.title;
            customPopView.subtitle = annotationModel.subtitle;
            customPopView.frame = CGRectMake(0, 0, customPopView.getPaopaoWidth, 70);
            
            BMKActionPaopaoView *pView = [[BMKActionPaopaoView alloc] initWithCustomView:customPopView];
            pView.backgroundColor = [UIColor clearColor];
            pView.frame = customPopView.frame;
            annotationView.paopaoView = pView;
        }
        
        if ([WXConvert BOOL:annotationModel.select]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //选中标注，弹出泡泡
                [mapView selectAnnotation:pointAnnotation animated:YES];
            });
            
        }
        
        return annotationView;
    }
    return nil;
}
//当mapView新添加annotation views时，调用
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    
    //设置最后添加的标注为中心
    id <BMKAnnotation> pointAnnotation =((BMKAnnotationView*)views.lastObject).annotation;
    [mapView setCenterCoordinate:pointAnnotation.coordinate animated:NO];
    
//    NSArray *annotations = [views valueForKey:@"annotation"];
//    [mapView showAnnotations:annotations animated:YES];
    
}
//当选中一个annotation views时，调用
//当BMKAnnotation的title为nil，BMKAnnotationView的canShowCallout为NO时，不显示气泡，点击BMKAnnotationView会回调此接口。当气泡已经弹出，点击BMKAnnotationView不会继续回调此接口
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    if (_selectAnnotation != view.annotation) {
        [mapView deselectAnnotation:_selectAnnotation animated:NO];
    }
    _selectAnnotation = view.annotation;
    if (_selectBubble) {
        if ([view.annotation isKindOfClass:[WXPointAnnotation class]]) {
            WXPointAnnotation *pointAnnotation = (WXPointAnnotation*)view.annotation;
            MapAnnotationModel *annotationModel = pointAnnotation.annotationConfig;
            if (![WXConvert BOOL:annotationModel.canShowCallout]) {
                NSMutableDictionary *bubbleDic = [NSMutableDictionary dictionary];
                [bubbleDic setValue:@"annotation" forKey:@"selectType"];
                [bubbleDic setValue:annotationModel.rawData forKey:@"rawData"];
                //给前端发送点击标注事件
                [self fireEvent:@"selectBubble" params:bubbleDic domChanges:nil];
            }
        }else {
            view.canShowCallout = NO;
            NSLog(@"点击了BMKUserLocationPointAnnotation");
            NSMutableDictionary *bubbleDic = [NSMutableDictionary dictionary];
            [bubbleDic setValue:@"annotation" forKey:@"selectType"];
            [bubbleDic setValue:@{@"title":@"UserLocation"} forKey:@"rawData"];
            //给前端发送点击标注事件
            [self fireEvent:@"selectBubble" params:bubbleDic domChanges:nil];
        }
    }else{
        
        view.canShowCallout = NO;
        
    }
    
}
//当取消选中一个annotation views时，调用
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view{
    
}

//当点击annotation view弹出的泡泡时，调用
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view{
    if (_selectBubble) {
        if ([view.annotation isKindOfClass:[WXPointAnnotation class]]) {
            WXPointAnnotation *pointAnnotation = (WXPointAnnotation*)view.annotation;
            MapAnnotationModel *annotationModel = pointAnnotation.annotationConfig;
            NSMutableDictionary *bubbleDic = [NSMutableDictionary dictionary];
            [bubbleDic setValue:@"bubble" forKey:@"selectType"];
            [bubbleDic setValue:annotationModel.rawData forKey:@"rawData"];
            //给前端发送点击泡泡事件
            [self fireEvent:@"selectBubble" params:bubbleDic domChanges:nil];
        }
        
    }
}

- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi{
    
}
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    if (_selectAnnotation&&_selectAnnotation != _autoAnnotation) {
        [mapView deselectAnnotation:_selectAnnotation animated:YES];
    }
    NSLog(@"点击了地图空白处");
    
    if (_autoAddAnnotation) {
        if (!_locationManager) {
            _locationManager = [TCMLocationManager instance];
        }
        
        if (_autoAnnotation ) {
            BMKAnnotationView *annotView = [mapView viewForAnnotation:_autoAnnotation];
            if (annotView.isSelected) {
                [mapView deselectAnnotation:_selectAnnotation animated:YES];
                return;
            }else{
                [mapView removeAnnotation:_autoAnnotation];
            }
        }
        
    }else{
        _locationManager = nil;
    }
    __weak typeof(self) weakSelf = self;
    [_locationManager reverseGeoCode:coordinate result:^(NSError * _Nullable err, BMKReverseGeoCodeSearchResult * _Nullable searchResult) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        //纬度
        [dic setValue:[NSNumber numberWithDouble:coordinate.latitude] forKey: @"latitude"];
        //经度
        [dic setValue:[NSNumber numberWithDouble:coordinate.longitude] forKey: @"longitude"];
        if (!err) {
            NSString *title = searchResult.sematicDescription;
            if ([title containsString:@","]) {
                NSArray *titles = [title componentsSeparatedByString:@","];
                title = titles.firstObject;
                if ([title hasSuffix:@"内"]) {
                    title = [title stringByReplacingOccurrencesOfString:@"内" withString:@""];
                }
            }
            NSString *subtitle = searchResult.address;
            
            [dic setValue:title forKey: @"title"];
            [dic setValue:subtitle forKey: @"subtitle"];
            
            [dic setValue:kStreetImg forKey: @"image"];
            [dic setValue:@"1" forKey: @"paopaoType"];
            [dic setValue:@"1" forKey: @"pointType"];
            [dic setValue:@"true" forKey: @"canShowCallout"];
        }
        if (weakSelf.autoAddAnnotation) {
            //给前端发送事件点击地图添加了一个标注
            [weakSelf fireEvent:@"autoAddAnnotation" params:@{@"result":@"success",@"data":dic} domChanges:nil];
        }
        [weakSelf addAnnotation:dic];
        
        weakSelf.autoAnnotation = weakSelf.mapView.annotations.lastObject;
    }];
    
}

- (void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate{
    NSLog(@"长安地图");
}

-(void)dealloc{
    if(_locationManager){
        [_locationManager stopManager];
    }
    NSLog(@"快来啊，地图被释放了");
}

@end
