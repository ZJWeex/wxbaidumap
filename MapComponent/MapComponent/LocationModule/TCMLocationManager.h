//
//  TCMLocationManager.h
//  Superior
//
//  Created by ZZJ on 2019/5/12.
//  Copyright © 2019 淘菜猫. All rights reserved.
// [Client] Failure to deallocate CLLocationManager on the same runloop as its creation may result in a crash

#import <Foundation/Foundation.h>
//定位相关
#import <BMKLocationkit/BMKLocationComponent.h>
//地理编码
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

NS_ASSUME_NONNULL_BEGIN
//定位回调
typedef void(^LocationCallBack)(NSError * _Nullable err,BMKLocation * _Nullable location);
//BMKLocatingCompletionBlock单次定位回调

@interface TCMLocationManager : NSObject

+ (nonnull instancetype)instance;

+(NSString*)appKey;

//是否持续定位，默认NO
@property(nonatomic,assign)BOOL allwaysLocation;

/**
 注册

 @param AK appKey
 */
-(void)registerWithKey:(NSString*)AK;
-(void)registerWithKey:(NSString*)AK result:(void(^)(BMKLocationAuthErrorCode authCode))block;
/**
 开启定位

 @param callBack 定位结果回调
 */
-(void)startWithLocation:(LocationCallBack)callBack;

//正地理编码（即地址转坐标）
-(void)geoCodeWithCity:(NSString*)city ByAddress:(NSString*)address result:(void(^)(NSError * _Nullable err,BMKGeoCodeSearchResult * _Nullable searchResult))block;

//逆地理编码（即坐标转地址）
-(void)reverseGeoCode:(CLLocationCoordinate2D)coordinate result:(void(^)(NSError * _Nullable err, BMKReverseGeoCodeSearchResult * _Nullable searchResult))block;

//POI城市内检索
-(void)poiSearchWithCity:(NSString*)city keyword:(NSString*)keyword result:(void(^)(NSError * _Nullable err, NSArray<BMKPoiInfo *> * _Nullable searchResult))block;

//停止地图定位引擎
-(void)stopManager;

@end

NS_ASSUME_NONNULL_END
