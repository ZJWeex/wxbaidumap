//
//  WXMapComponent.h
//  Superior
//
//  Created by ZZJ on 2019/5/13.
//  Copyright © 2019 淘菜猫. All rights reserved.
//

#import <WeexSDK/WeexSDK.h>
#import "WXComponent.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXMapComponent : WXComponent
/*
 添加点标记
 参数：
 @{
     @"latitude":@"31.242727",//纬度
     @"longitude":@"121.513295",//经度
     @"title":@"上海",
     @"subtitle":@"陆家嘴金融中心"
 };
 */
-(void)addAnnotation:(NSDictionary*)dicAnnotation;

@end

NS_ASSUME_NONNULL_END
/*
 weex调用：
 <map style="width:750px;height:500px"
     ref='map'
     @mapLoaded="mapLoaded"  //地图加载完成事件
     @selectBubble="selectBubble" //选中标注事件
     @autoAddAnnotation='autoAddAnnotation', //点击地图空白处添加标注事件,不实现该方法，无法添加。而且这种添加标注的方式不灵敏！
     zoomLevel='14' //比例尺等级，默认14。取值范围：4-21
     zoomControlsEnabled='fasle' //是否展示地图缩放按钮，默认false。ios不支持
     showTraffic='false' //是否实时显示路况信息,默认false
     userLocation="{latitude:'31.242727',longitude:'121.513295'}" //用户位置
     showScaleBar="true"  //是否显式比例尺，默认true
     :scaleBarPosition="{x:10,y:10}"> //比例尺的位置
 </map>
 
 weex事件：
 //地图加载完成事件
 mapLoaded(){
 
    //地图加载完成后，添加一个标注
     let annotationConfig={
         latitude:"31.242727",//纬度
         longitude:"121.443295",//经度
         title:"上海",
         subtitle:"默认标注，默认泡泡",
         pointType:'0',
         pinColor:'red',
         canShowCallout:'true',
         image:'location_marker'
    }
 
   this.$refs.map.addAnnotation(annotationConfig)
 
     let annotationConfig1={
         latitude:"31.242727",//纬度
         longitude:"121.423295",//经度
         title:"上海",
         subtitle:"自定义标注，默认泡泡",
         pointType:'1',
         pinColor:'green',
         canShowCallout:'true',
         image:'location_marker'
     }
 
   this.$refs.map.addAnnotation(annotationConfig1)
 
     let annotationConfig2={
         latitude:"31.242727",//纬度
         longitude:"121.403295",//经度
         title:"上海",
         subtitle:"默认标注，自定义泡泡",
         pointType:'0',
         pinColor:'green',
         paopaoType:'1',
         canShowCallout:'true',
         image:'location_marker'
     }
 
    this.$refs.map.addAnnotation(annotationConfig2)
 
     let annotationConfig3={
         latitude:"31.242727",//纬度
         longitude:"121.383295",//经度
         title:"上海",
         subtitle:"自定义标注，自定义泡泡",
         pointType:'1',
         paopaoType:'1',
         pinColor:'red',
         canShowCallout:'false',
         image:'http://tcmdefaultbucket-1253294191.cossh.myqcloud.com/img/upload/avatar/654b64f2-e820-490a-81f1-a29a2b75da8e.jpg_small.jpg'
     }
 
    this.$refs.map.addAnnotation(annotationConfig3)
 
    let annotationConfig4={
         latitude:"31.242727",//纬度
         longitude:"121.363295",//经度
         title:"上海",
         subtitle:"自定义标注，不弹出泡泡",
         pointType:'1',
         paopaoType:'1',
         pinColor:'red',
         canShowCallout:'false',
         image:'/web/assets/sup/sup_address_loction.png'
    }
 
    this.$refs.map.addAnnotation(annotationConfig4)
 //添加一组标注
 // this.$refs.map.addAnnotations([annotationConfig4,annotationConfig3,annotationConfig2,annotationConfig1,annotationConfig])
 },
 selectBubble(event){
     //点击标注泡泡的方法
     modal.alert({message:'泡泡:'+JSON.stringify(event.rawData)},ev=>{})
 },
 autoAddAnnotation(event){
    //点击地图空白处添加标注
    modal.alert({message:'标注:'+JSON.stringify(event.data)},ev=>{})
 }
 
 annotationConfig说明：
 pointType:0:默认标注 1:自定义标注图标
 paopaoType:0:默认泡泡，1:自定义泡泡
 canShowCallout:设置气泡是否可以弹出true或false
 select:设置标注是否弹出气泡true或false，只能选中一个
 pinColor:pointType为0时有效 pinColor取值：red,green,purple
 image:设置标注图片,在pointType为1时有效；设置泡泡图片paopaoType为1时有效
 title:若title为nil，则无法弹出泡泡
 subtitle:副标题
 
 */
