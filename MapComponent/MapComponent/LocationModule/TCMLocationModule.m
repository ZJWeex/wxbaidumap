//
//  TCMLocationModule.m
//  Superior
//
//  Created by ZZJ on 2019/5/10.
//  Copyright © 2019 淘菜猫. All rights reserved.
//

#import "TCMLocationModule.h"
#import "TCMLocationManager.h"
#import <MJExtension/MJExtension.h>

@interface TCMLocationModule ()
@property(nonatomic,strong)TCMLocationManager *locationManager;
@end
@implementation TCMLocationModule
WX_EXPORT_METHOD(@selector(location:));
WX_EXPORT_METHOD(@selector(geoCode: result:));
WX_EXPORT_METHOD(@selector(reverseGeoCode: result:));
WX_EXPORT_METHOD(@selector(POISearch: result:));

- (instancetype)init {
    if (self = [super init]) {
        _locationManager = [TCMLocationManager instance];
    }
    return self;
}

//用于返回经纬度及位置信息
-(void)location:(WXModuleKeepAliveCallback)block{
    
    [_locationManager startWithLocation:^(NSError * _Nullable err, BMKLocation * _Nullable location) {
        //获取到定位信息
        NSMutableDictionary * callbackRsp =[[NSMutableDictionary alloc] init];
        if (err) {
            [callbackRsp setValue:@"failed" forKey:@"result"];
            [callbackRsp setValue:err.domain forKey:@"data"];
        }else{
            [callbackRsp setValue:@"success" forKey:@"result"];
            
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            [data setValue:@(location.location.coordinate.latitude) forKey:@"latitude"];
            [data setValue:@(location.location.coordinate.longitude) forKey:@"longitude"];
            [data setValue:location.rgcData.province forKey:@"province"];
            [data setValue:location.rgcData.city forKey:@"city"];
            //区名字属性
            [data setValue:location.rgcData.district forKey:@"district"];
            //街道名字属性
            [data setValue:location.rgcData.street forKey:@"street"];
            //街道号码属性
            [data setValue:location.rgcData.streetNumber forKey:@"streetNumber"];
            //城市编码属性
            [data setValue:location.rgcData.cityCode forKey:@"cityCode"];
            //行政区划编码属性
            [data setValue:location.rgcData.adCode forKey:@"adCode"];
            
            NSString *locationDescribe = location.rgcData.locationDescribe;
            if ([locationDescribe hasPrefix:@"在"]&&[locationDescribe hasSuffix:@"附近"]) {
                locationDescribe = [locationDescribe substringWithRange:NSMakeRange(1, locationDescribe.length-3)];
            }
            [data setValue:locationDescribe forKey:@"locationDescribe"];
            //poiList
            NSArray *poiList = [BMKLocationPoi mj_keyValuesArrayWithObjectArray:location.rgcData.poiList];
            [data setValue:poiList forKey:@"poiList"];
            
            [callbackRsp setValue:data forKey:@"data"];
        }
        if (block) {
            block(callbackRsp,TRUE);
        }
    }];
    
}
//根据城市、街道返回结果
-(void)geoCode:(NSDictionary*)geoCode result:(WXModuleKeepAliveCallback)callback{
    NSString *city = geoCode[@"city"];
    NSString *address = geoCode[@"address"];
    __weak typeof(self) weakSelf = self;
    [weakSelf.locationManager geoCodeWithCity:city ByAddress:address result:^(NSError * _Nullable err, BMKGeoCodeSearchResult * _Nullable searchResult) {
        NSMutableDictionary * resultGeo =[[NSMutableDictionary alloc] init];
        if (err) {
            [resultGeo setValue:@"failed" forKey:@"result"];
            [resultGeo setValue:err.domain forKey:@"data"];
        }else{
            [resultGeo setValue:@"success" forKey:@"result"];
            
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            //地址类型
            [data setValue:searchResult.level forKey:@"level"];
            //是否是精准查找，1为精确查找，即准确打点，0为不精确，即模糊打点
            if (searchResult.precise==1) {
                [data setValue:@"true" forKey:@"precise"];
            }else{
                [data setValue:@"false" forKey:@"precise"];
            }
            
            //经纬度
            [data setValue:@(searchResult.location.latitude) forKey:@"latitude"];
            [data setValue:@(searchResult.location.longitude) forKey:@"longitude"];
            
            [resultGeo setValue:data forKey:@"data"];
        }
        if (callback) {
            callback(resultGeo,NO);
        }
        
    }];
}

//根据地理编码返回结果
-(void)reverseGeoCode:(NSDictionary*)geoCode result:(WXModuleKeepAliveCallback)callback{
    CLLocationDegrees latitude = [geoCode[@"latitude"] doubleValue];
    CLLocationDegrees longitude = [geoCode[@"longitude"] doubleValue];
    
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(latitude, longitude);
    __weak typeof(self) weakSelf = self;
    [weakSelf.locationManager reverseGeoCode:coordinate2D result:^(NSError * _Nullable err, BMKReverseGeoCodeSearchResult * _Nullable searchResult) {
        NSMutableDictionary * resultGeo =[[NSMutableDictionary alloc] init];
        if (err) {
            [resultGeo setValue:@"failed" forKey:@"result"];
            [resultGeo setValue:err.domain forKey:@"data"];
        }else{
            [resultGeo setValue:@"success" forKey:@"result"];
            
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            //省名称
            [data setValue:searchResult.addressDetail.province forKey:@"province"];
            //城市名
            [data setValue:searchResult.addressDetail.city forKey:@"city"];
            //区县名称
            [data setValue:searchResult.addressDetail.district forKey:@"district"];
            //地址名
            [data setValue:searchResult.address forKey:@"address"];
            //商圈名
            [data setValue:searchResult.businessCircle forKey:@"businessCircle"];
            //经纬度
            [data setValue:@(searchResult.location.latitude) forKey:@"latitude"];
            [data setValue:@(searchResult.location.longitude) forKey:@"longitude"];
            
            NSMutableArray *poiList = [NSMutableArray array];
            for (BMKPoiInfo *poi in searchResult.poiList) {
                NSMutableDictionary *poiDic = [NSMutableDictionary dictionary];
                //poi名称
                [poiDic setValue:poi.name forKey:@"name"];
                //poi地址信息
                [poiDic setValue:poi.address forKey:@"address"];
                //POI所在省份
                if (poi.province) {
                    [poiDic setValue:poi.province forKey:@"province"];
                }else{
                    [poiDic setValue:searchResult.addressDetail.province forKey:@"province"];
                }
                
                //POI所在城市
                if (poi.city) {
                    [poiDic setValue:poi.city forKey:@"city"];
                }else{
                    [poiDic setValue:searchResult.addressDetail.city forKey:@"city"];
                }
                
                //POI所在行政区域
                if (poi.area) {
                    [poiDic setValue:poi.area forKey:@"area"];
                }else{
                    [poiDic setValue:searchResult.addressDetail.district forKey:@"area"];
                }
                
                //距离坐标点距离，注：此字段只对逆地理检索有效
                [poiDic setValue:@(poi.distance) forKey:@"distance"];
                //经纬度
                [poiDic setValue:@(poi.pt.latitude) forKey:@"latitude"];
                [poiDic setValue:@(poi.pt.longitude) forKey:@"longitude"];
                
                
                [poiList addObject:poiDic];
            }
            //地址周边POI信息
            [data setValue:poiList forKey:@"poiList"];
            
            [resultGeo setValue:data forKey:@"data"];
        }
        if (callback) {
            callback(resultGeo,NO);
        }
    }];
    
    
}

//城市POI搜索服务
-(void)POISearch:(NSDictionary*)searchOption result:(WXModuleKeepAliveCallback)callback{
    NSString *city = searchOption[@"city"];
    NSString *keyword = searchOption[@"keyword"];
    
    if (!city || city.length==0) {
        NSError *err = [NSError errorWithDomain:@"缺少城市区域名称" code:-1 userInfo:nil];
        NSMutableDictionary * resultSet =[[NSMutableDictionary alloc] init];
        [resultSet setValue:@"failed" forKey:@"result"];
        [resultSet setValue:err.domain forKey:@"data"];
        if (callback) {
            callback(resultSet,NO);
        }
        
        return;
    }
    __weak typeof(self) weakSelf = self;
    [weakSelf.locationManager poiSearchWithCity:city keyword:keyword result:^(NSError * _Nullable err, NSArray<BMKPoiInfo *> * _Nullable searchResult) {
        NSMutableDictionary * resultSet =[[NSMutableDictionary alloc] init];
        if (err) {
            [resultSet setValue:@"failed" forKey:@"result"];
            [resultSet setValue:err.domain forKey:@"data"];
        }else{
            [resultSet setValue:@"success" forKey:@"result"];
            
            NSMutableArray *poiArray = [NSMutableArray array];
            for (BMKPoiInfo *poi in searchResult) {
                NSMutableDictionary *poiDic = [NSMutableDictionary dictionary];
                //poi名称
                [poiDic setValue:poi.name forKey:@"name"];
                //poi地址信息
                [poiDic setValue:poi.address forKey:@"address"];
                //POI所在省份
                [poiDic setValue:poi.province forKey:@"province"];
                //POI所在城市
                [poiDic setValue:poi.city forKey:@"city"];
                //POI所在行政区域
                [poiDic setValue:poi.area forKey:@"area"];
                //距离坐标点距离，注：此字段只对逆地理检索有效
                [poiDic setValue:@(poi.distance) forKey:@"distance"];
                //经纬度
                [poiDic setValue:@(poi.pt.latitude) forKey:@"latitude"];
                [poiDic setValue:@(poi.pt.longitude) forKey:@"longitude"];
                
                
                [poiArray addObject:poiDic];
            }
            
            [resultSet setValue:poiArray forKey:@"data"];
        }
        if (callback) {
            callback(resultSet,NO);
        }
    }];
    
}

-(void)dealloc{
    [_locationManager stopManager];
    NSLog(@"释放:%s",__FILE__);
}

@end
