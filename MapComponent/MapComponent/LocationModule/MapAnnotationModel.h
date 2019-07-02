//
//  MapAnnotationModel.h
//  Superior
//
//  Created by ZZJ on 2019/5/30.
//  Copyright © 2019 淘菜猫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <MJExtension/MJExtension.h>
#import "TCMLocationManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface MapAnnotationModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)modelWithDictionary:(NSDictionary*)dict;

//保存原始数据，可能为nil
@property(nonatomic,readonly)NSDictionary *rawData;
//0:默认标注 1:自定义标注图标
@property(nonatomic,copy)NSString *pointType;
//pointType为0，1时有效 pinColor：red,green,purple
@property(nonatomic,assign)BMKPinAnnotationColor pinColorType;
@property(nonatomic,copy)NSString *pinColor;
//设置标注图片,在pointType为1时有效
@property(nonatomic,copy)NSString *image;

//设置气泡是否可以弹出
@property(nonatomic,copy)NSString *canShowCallout;
//选中标注true或false
@property(nonatomic,copy)NSString *select;

//0:默认泡泡 1:自定义气泡
@property(nonatomic,copy)NSString *paopaoType;
//pointType1时有效,若title为nil，则无法弹出泡泡
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *subtitle;

//图片合并
+(UIImage*)mergeFromImage:(UIImage*)fromImg toImage:(UIImage*)toImg;
//保存截屏
+(int)saveImage:(BMKMapView*)mapView;
//获取全景图
+(void)requsetStreetImgWithCoordinate:(CLLocationCoordinate2D)coordinate callBlock:(void(^)(UIImage *image))block;

@end

NS_ASSUME_NONNULL_END
