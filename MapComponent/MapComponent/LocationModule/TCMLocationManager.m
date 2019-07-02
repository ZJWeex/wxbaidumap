//
//  TCMLocationManager.m
//  Superior
//
//  Created by ZZJ on 2019/5/12.
//  Copyright © 2019 淘菜猫. All rights reserved.
//

#import "TCMLocationManager.h"
#import <WeexSDK/WeexSDK.h>

#import "TCMLocationModule.h"
//百度申请的AK
static NSString *baiduAK = nil;

@interface TCMLocationManager ()<CLLocationManagerDelegate,BMKLocationAuthDelegate,BMKGeneralDelegate,BMKLocationManagerDelegate,BMKGeoCodeSearchDelegate,BMKPoiSearchDelegate>
{
        CLLocationManager *_locationManagerSystem;
        BOOL isRegister;
}

@property(nonatomic,strong)BMKLocationManager *locationManager;
@property(nonatomic,strong)BMKMapManager *mapManager;

//城市poi搜索
@property(nonatomic,strong)BMKPoiSearch *poiSearch;
//定位结果回调
@property(nonatomic,copy)LocationCallBack locationCallBack;
//鉴权结果回调
@property(nonatomic,copy)void(^authCode)(BMKLocationAuthErrorCode authCode);
//正地理编码结果回调
@property(nonatomic,copy)void(^geoCodeCompletion)(NSError * _Nullable err,BMKGeoCodeSearchResult *searchResult);
//反向地理编码结果回调
@property(nonatomic,copy)void(^reverseGeoCodeCompletion)(NSError * _Nullable err,BMKReverseGeoCodeSearchResult *searchResult);
//POI搜索结果回调
@property(nonatomic,copy)void(^poiSearchCompletion)(NSError * _Nullable err, NSArray<BMKPoiInfo *> * _Nullable searchResult);

@end
@implementation TCMLocationManager

#pragma mark -- CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSLog(@"定位权限发生改变");
    if (status == kCLAuthorizationStatusDenied) {
        
        NSString *bundleDisplayName = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleDisplayName"];
        NSString *prompt = [NSString stringWithFormat:@"请进入系统[设置]>[隐私]>[定位服务]开启定位，并允许\"%@\"使用定位服务",bundleDisplayName];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:prompt preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }]];
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        [root presentViewController:alert animated:YES completion:nil];
    }
}
//获取是否有定位权限
+ (BOOL)getUserLocationAuth {
    BOOL result = NO;
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            break;
        case kCLAuthorizationStatusRestricted:
            break;
        case kCLAuthorizationStatusDenied:
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            result = YES;
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            result = YES;
            break;
            
        default:
            break;
    }
    return result;
}

-(void)checkLocationAuthor{
    if (![TCMLocationManager getUserLocationAuth]) {
        NSLog(@"定位权限未开启");
        _locationManagerSystem = [[CLLocationManager alloc]init];
        _locationManagerSystem.delegate = self;
        [_locationManagerSystem requestWhenInUseAuthorization];
    }
}

+ (nonnull instancetype)instance {
    TCMLocationManager *instance = [TCMLocationManager new];
    return instance;
}

#pragma mark -- 注册
-(void)registerWithKey:(NSString*)AK {
    isRegister = YES;
    if ([BMKLocationAuth sharedInstance].permisionState != BMKLocationAuthErrorSuccess) {
        [[BMKLocationAuth sharedInstance] checkPermisionWithKey:AK authDelegate:self];
    }
    
    [self startMapManager];
    
}

-(void)registerWithKey:(NSString*)AK result:(void(^)(BMKLocationAuthErrorCode authCode))block{
    //检查定位是否可用
    [self checkLocationAuthor];
    
    [WXSDKEngine registerModule:@"location" withClass:NSClassFromString(@"TCMLocationModule")];
    [WXSDKEngine registerComponent:@"map" withClass:NSClassFromString(@"WXMapComponent")];
    baiduAK = AK;
    [self registerWithKey:AK];
    self.authCode = block;
    
}

+(NSString*)appKey{
    return baiduAK;
}

#pragma mark -- 启动地图引擎

-(BOOL)startMapManager{
    // 要使用百度地图，请先启动BaiduMapManager
    if (!_mapManager) {
        _mapManager = [[BMKMapManager alloc] init];
    }
    
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
    BOOL ret = [_mapManager start:baiduAK  generalDelegate:self];
    if (!ret) {
        NSLog(@"mapManager start failed!");
    }
    
    return ret;
}

//关闭地图引擎，释放定位信息数据
-(void)stopManager{
    [_mapManager stop];
    _poiSearch.delegate = nil;
    
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
    _locationManager.delegate = nil;
    _locationManager = nil;
    
}

//初始化定位数据
-(void)buildLocation{
    //初始化实例
    _locationManager = [[BMKLocationManager alloc] init];
    //设置delegate
    _locationManager.delegate = self;
    //设置返回位置的坐标系类型
    _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    //设置距离过滤参数
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    //设置预期精度参数
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //设置应用位置类型
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    //设置是否自动停止位置更新
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    //设置是否允许后台定位
    _locationManager.allowsBackgroundLocationUpdates = NO;
    //设置位置获取超时时间
    _locationManager.locationTimeout = 10;
    //设置获取地址信息超时时间
    _locationManager.reGeocodeTimeout = 10;
    
}

-(void)setAllwaysLocation:(BOOL)allwaysLocation{
    _allwaysLocation = allwaysLocation;
    if (!_locationManager) {
        return;
    }
    if (_allwaysLocation) {
        //开启持续定位(需联网)
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];
    }else{
        //停止持续定位
        [_locationManager stopUpdatingLocation];
        [_locationManager stopUpdatingHeading];
    }
}

#pragma mark -- Public

-(void)startWithLocation:(LocationCallBack)callBack{
    self.locationCallBack = callBack;
    if (!baiduAK) {
        NSError *error = [NSError errorWithDomain:@"还没有注册App Key" code:-1 userInfo:nil];
        self.locationCallBack(error, nil);
        return;
    }
    if (!isRegister) {
        [self registerWithKey:baiduAK];
    }
    
    if (!_locationManager) {
        [self buildLocation];
    }
    
    //开启持续定位(需联网)
    [self.locationManager startUpdatingLocation];
    if (_allwaysLocation) {
        [self.locationManager startUpdatingHeading];
    }
    
}

//正地理编码（即地址转坐标）
-(void)geoCodeWithCity:(NSString*)city ByAddress:(NSString*)address result:(void(^)(NSError * _Nullable err,BMKGeoCodeSearchResult *searchResult))block{
    
    self.geoCodeCompletion = block;
    
    BMKGeoCodeSearch *search = [[BMKGeoCodeSearch alloc] init];
    search.delegate = self;
    BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    if (address&&address.length>0) {
        geoCodeSearchOption.address = address;
        geoCodeSearchOption.city = city;
    }else{
        geoCodeSearchOption.address = city;
        geoCodeSearchOption.city = address;
    }
    
    BOOL flag = [search geoCode: geoCodeSearchOption];
    if (flag) {
        NSLog(@"geo检索发送成功");
    }  else  {
        NSLog(@"geo检索发送失败");
    }
}

//逆地理编码（即坐标转地址）
-(void)reverseGeoCode:(CLLocationCoordinate2D)coordinate result:(void(^)(NSError * _Nullable err,BMKReverseGeoCodeSearchResult *searchResult))block{
    self.reverseGeoCodeCompletion = block;
    
    BMKGeoCodeSearch *search = [[BMKGeoCodeSearch alloc] init];
    search.delegate = self;
    
    BMKReverseGeoCodeSearchOption *reverseGeoCodeOption = [[BMKReverseGeoCodeSearchOption alloc] init];
    
//    coordinate = CLLocationCoordinate2DMake(39.915, 116.404);
    // 是否访问最新版行政区划数据（仅对中国数据生效）
    reverseGeoCodeOption.isLatestAdmin = YES;
    reverseGeoCodeOption.location = coordinate;
    BOOL flag = [search reverseGeoCode: reverseGeoCodeOption];
    if (flag) {
        NSLog(@"逆geo检索发送成功");
    }  else  {
        NSLog(@"逆geo检索发送失败");
    }
    
}

//POI城市内检索
-(void)poiSearchWithCity:(NSString*)city keyword:(NSString*)keyword result:(void(^)(NSError * _Nullable err,NSArray<BMKPoiInfo *> * _Nullable searchResult))block{
    
    self.poiSearchCompletion = block;
    
    if(!_poiSearch){
        BMKPoiSearch *poiSearch = [[BMKPoiSearch alloc] init];
        //此处需要先遵循协议<BMKPoiSearchDelegate>
        poiSearch.delegate = self;
        _poiSearch = poiSearch;
    }
    
    //初始化请求参数类BMKCitySearchOption的实例
    BMKPOICitySearchOption *cityOption = [[BMKPOICitySearchOption alloc] init];
    //检索关键字，必选。举例：小吃
    cityOption.keyword = keyword;
    //区域名称(市或区的名字，如上海市，普陀区)，最长不超过25个字符，必选
    cityOption.city = city;
    //检索分类，可选，与keyword字段组合进行检索，多个分类以","分隔。举例：美食,烧烤,酒店
//    cityOption.tags = @[@"美食",@"烧烤"];
    //区域数据返回限制，可选，为YES时，仅返回city对应区域内数据
    cityOption.isCityLimit = YES;
    //POI检索结果详细程度
    //cityOption.scope = BMK_POI_SCOPE_BASIC_INFORMATION;
    //检索过滤条件，scope字段为BMK_POI_SCOPE_DETAIL_INFORMATION时，filter字段才有效
    //cityOption.filter = filter;
    //分页页码，默认为0，0代表第一页，1代表第二页，以此类推
    cityOption.pageIndex = 0;
    //单次召回POI数量，默认为10条记录，最大返回20条
    cityOption.pageSize = 15;
    
    BOOL flag = [_poiSearch poiSearchInCity:cityOption];
    if(flag) {
        NSLog(@"POI城市内检索成功");
    } else {
        NSLog(@"POI城市内检索失败");
        if (self.poiSearchCompletion) {
            self.poiSearchCompletion(nil, @[]);
        }
    }
    

}


#pragma mark -- BMKLocationAuthDelegate
/**
 *@brief 返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKLocationAuthErrorCode
 */
- (void)onCheckPermissionState:(BMKLocationAuthErrorCode)iError{
    switch (iError) {
        case BMKLocationAuthErrorSuccess:
        {
            NSLog(@"鉴权成功");
        }
            break;
        case BMKLocationAuthErrorNetworkFailed:
            NSLog(@"因网络鉴权失败");
            break;
        case BMKLocationAuthErrorFailed:
            NSLog(@"KEY非法鉴权失败");
            break;
            
        default:
            NSLog(@"未知错误");
            break;
    }
    if (self.authCode) {
        self.authCode(iError);
    }
    
}

#pragma mark -- BMKGeneralDelegate
/**
 联网结果回调
 
 @param iError 联网结果错误码信息，0代表联网成功
 */
- (void)onGetNetworkState:(int)iError {
    if (0 == iError) {
        NSLog(@"BMKMap联网成功");
    } else {
        NSLog(@"联网失败：%d", iError);
    }
}
/**
 *返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKPermissionCheckResultCode
 */
- (void)onGetPermissionState:(int)iError{
    BMKPermissionCheckResultCode errCode = iError;
    if (errCode == 0) {
        NSLog(@"地图授权验证通过");
    }else{
        NSLog(@"地图授权错误码:%d",errCode);
    }
    
}

#pragma mark -- BMKLocationManagerDelegate
//定位发生错误
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error{
    NSLog(@"定位发生错误:{%ld - %@}",(long)error.code,error.localizedDescription);
    if (self.locationCallBack) {
        self.locationCallBack(error, nil);
    }
    
}
//连续定位回调函数
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didUpdateLocation:(BMKLocation * _Nullable)location orError:(NSError * _Nullable)error

{
    if (error){
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
        error = [NSError errorWithDomain:error.localizedDescription code:error.code userInfo:nil];
    }
    if (location) {//得到定位信息，添加annotation
        if (location.location) {
            NSLog(@"LOC = %@",location.location);
        }
        if (location.rgcData) {
            NSLog(@"rgc = %@",[location.rgcData description]);
        }
    }
    if (self.locationCallBack) {
        self.locationCallBack(error, location);
    }
    if (!_allwaysLocation) {
        //停止持续定位
        [self.locationManager stopUpdatingLocation];

    }
    
}
//提供设备朝向的回调方法
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager
          didUpdateHeading:(CLHeading * _Nullable)heading{
    if (!_allwaysLocation) {
        //停止持续定位
        [self.locationManager stopUpdatingHeading];
    }
}
#pragma mark -- BMKGeoCodeSearchDelegate
/**
 正向地理编码检索结果回调
 
 @param searcher 检索对象
 @param result 正向地理编码检索结果
 @param error 错误码，@see BMKCloudErrorCode
 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        NSLog(@"正向地理编码检索结果：%@",result.description);
        //在此处理正常结果
        if (self.geoCodeCompletion) {
            self.geoCodeCompletion(nil, result);
        }
        
    }else {
        NSLog(@"检索失败");
        if (self.geoCodeCompletion) {
            NSError *err = [NSError errorWithDomain:@"检索失败" code:error userInfo:nil];
            self.geoCodeCompletion(err, nil);
        }
        
    }
    
}

/**
 反向地理编码检索结果回调
 
 @param searcher 检索对象
 @param result 反向地理编码检索结果
 @param error 错误码，@see BMKCloudErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSLog(@"反向地理编码检索结果：%@",result.description);
        if (self.reverseGeoCodeCompletion) {
            self.reverseGeoCodeCompletion(nil, result);
        }
        
    }else {
        NSLog(@"检索失败");
        if (self.reverseGeoCodeCompletion) {
            NSError *err = [NSError errorWithDomain:@"检索失败" code:error userInfo:nil];
            self.reverseGeoCodeCompletion(err, nil);
        }
        
    }
}

#pragma mark - BMKPoiSearchDelegate
/**
 *返回POI搜索结果
 *@param searcher 搜索对象
 *@param poiResult 搜索结果列表
 *@param errorCode 错误码，@see BMKSearchErrorCode
 */
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPOISearchResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode {
    //BMKSearchErrorCode错误码，BMK_SEARCH_NO_ERROR：检索结果正常返回
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSLog(@"检索结果返回成功：%@",poiResult.poiInfoList);
        if (self.poiSearchCompletion) {
            self.poiSearchCompletion(nil, poiResult.poiInfoList);
        }
        
        
    }else if (errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD) {
        NSLog(@"检索词有歧义");
        if (self.poiSearchCompletion) {
            NSError *err = [NSError errorWithDomain:@"检索失败" code:errorCode userInfo:nil];
            self.poiSearchCompletion(err, nil);
        }
        
    } else {
        NSLog(@"其他检索结果错误码相关处理");
        if (self.poiSearchCompletion) {
            NSError *err = [NSError errorWithDomain:@"检索失败" code:errorCode userInfo:nil];
            self.poiSearchCompletion(err, nil);
        }
    }
    
}

-(void)dealloc{
    NSLog(@"TCMLocationManager被释放");
}


@end
