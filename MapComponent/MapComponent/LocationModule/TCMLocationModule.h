//
//  TCMLocationModule.h
//  Superior
//
//  Created by ZZJ on 2019/5/10.
//  Copyright © 2019 淘菜猫. All rights reserved.
//

//注册weex相关组件
/*
 [WXSDKEngine registerModule:@"location" withClass:NSClassFromString(@"TCMLocationModule")];
 [WXSDKEngine registerComponent:@"map" withClass:NSClassFromString(@"WXMapComponent")];
 */

#import <Foundation/Foundation.h>
#import <WeexSDK/WeexSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCMLocationModule : NSObject <WXModuleProtocol>

//用于返回经纬度及位置信息
-(void)location:(WXModuleKeepAliveCallback)block;
//根据地理编码返回结果,参数：@{@"latitude":@(纬度),@"longitude":@(经度)}
-(void)reverseGeoCode:(NSDictionary*)geoCode result:(WXModuleKeepAliveCallback)callback;

//城市POI搜索服务
-(void)POISearch:(NSDictionary*)searchOption result:(WXModuleKeepAliveCallback)callback;

@end

NS_ASSUME_NONNULL_END
/*
 
 WX_EXPORT_METHOD(@selector(location:));
 说明：返回经纬度及位置信息
 返回结果：
 {
    result:failed,
    data:'错误信息说明'
 }
 {
     result:success,
     data:{
         latitude:'纬度',
         longitude:'经度',
         province:'省',
         city:'市',
         district:'区名字',
         street:'街道名字',
         streetNumber:'街道号码属性',
         cityCode:'城市编码',
         adCode:'行政区划编码属性',
         locationDescribe:'位置语义化结果的定位点在什么地方周围的描述信息，例如：天地软件园'
     }
 }
 WX_EXPORT_METHOD(@selector(geoCode: result:));
 说明：根据位置信息返回经纬度；⚠️：city可选，当address为空时，将city值给address
 参数：{"city":"城市名称","address":"街道地址"}
 返回结果：
 {
 result:failed,
 data:'错误信息说明'
 }
 {
 result:success,
 data:{
     latitude:'纬度',
     longitude:'经度',
     level:'地理类型包含：UNKNOWN、国家、省、商圈、生活服务等等',
     precise:'是否是精准查找',//true:准确查找，false:不精确
     }
 }
 
 WX_EXPORT_METHOD(@selector(reverseGeoCode: result:));
 说明：根据地理编码返回结果
 参数：{"latitude":"纬度","longitude":"经度"}
 返回结果：
 {
     result:failed,
     data:'错误信息说明'
 }
 {
     result:success,
     data:{
         province:'省',
         city:'市',
         district:'区名字',
         address:"地址名",
         businessCircle:"商圈名",
         latitude:'纬度',
         longitude:'经度',
         poiList:[{
             name:"poi名称",
             address:"poi地址信息",
             province:'POI所在省份',
             city:'POI所在城市',
             area:"POI所在行政区域",
             distance:"距离坐标点距离",
             latitude:'纬度',
             longitude:'经度'
         }]
     }
 }
 
 WX_EXPORT_METHOD(@selector(POISearch: result:));
 说明：城市POI搜索服务
 参数：{"city":"城市名称","keyword":"关键字"}
 返回结果：
 {
     result:failed,
     data:'错误信息说明'
 }
 {
 result:success,
     data:[{
         name:"poi名称",
         address:"poi地址信息",
         province:'POI所在省份',
         city:'POI所在城市',
         area:"POI所在行政区域",
         distance:"距离坐标点距离",
         latitude:'纬度',
         longitude:'经度'
     }]
 }
 
 */
