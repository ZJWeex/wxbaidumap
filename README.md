# 百度地图map组件 for iOS

<img width="320" src="http://img2.downza.cn/edu/android/yyjc-1014/2016-05-12/069ba37e06c12729691496ebdf2425db.jpg" />

一个百度地图的组件，运行在iOS端。相关[文章阅读](http://blog.sina.com.cn/s/blog_133384b110102z4mt.html)👉

## 快速开始
1.首先在百度地图开放平台注册应用AK。

2.在iOS的工程中引入weexSDK,以及百度地图、定位SDK:

```
  pod 'MJExtension', '~> 3.0.17'
  pod 'WeexSDK', '~> 0.24.0'
  pod 'SDWebImage', '~> 5.0'
  pod 'BaiduMapKit', '~> 4.3.2'
  pod 'BMKLocationKit', '~> 1.6.0'
  pod 'SocketRocket', '0.4.2'
```
3.设置项目定位权限，否则定位功能无法使用！

4.在weexSDK启动后，再注册百度AK.
```
    [WeexSDKManager setup];
    //weexSDK初始化后调用，因为在内部注册了map和loction组件。
    [[TCMLocationManager instance] registerWithKey:@"你的应用ak" result:^(BMKLocationAuthErrorCode authCode) {
        if (authCode == BMKLocationAuthErrorSuccess) {
                
        }
    }];
```
5.在native项目的DemoDefine.h中修改IP为你的服务IP。
  在NSURL+XZOL.m的HTTP_RemoteResourceReplace方法中设置远程线上服务器地址
  ```
  + (NSString *)HTTP_RemoteResourceReplace{
      //例如：http://www.baidu.com/weex/dist/
        return @"你的正式环境服务器地址";
    }
  ```
  6.配置入口文件
   在WXTabBarController.m中，修改数组urlList对应的路径为你的weex项目入口文件路径，
   TabBar我们采用原生的TabBarController。
   ```
   _urlList = @[
                 @"index.js",
                 @"find.js",
                 @"",
                 @"base/personal.js",
                 ];
   ```
   其他设置可根据需要配置。


## 编辑你的weex文件

添加一个展示地图的文件:
```
<template>
    <div class='root'>
        <navigation title="地图界面"/>
        <div style="flex:1;background-color: orange;">
            <map class="map-div" :style="{height:mapHeight}"
                    @mapLoaded="mapLoaded"
                    zoomLevel='19' 
                    :userLocation="userLocation"
                    showScaleBar="true" 
                    :scaleBarPosition="{x:20,y:mapHeight-40}"></map>
        </div>
    </div>
</template>

<script>
import navigation from "@/components/NavigationBar.vue";
const location = weex.requireModule("location");
const modal = weex.requireModule('modal');

export default {
    components: { navigation },
    data() {
        return {
            mapHeight:WXEnvironment.deviceHeight/WXEnvironment.scale*2-2*90,
             userLocation:{},
        }
    },
    created() {
        const self = this
        location.location(function(ev){
            if(ev.result == 'success'){
                let userLocation = ev.data;
                self.userLocation = userLocation;
            }
        })
    },
    methods: {
        mapLoaded:function(){
            console.log('地图加载完成')
        },
    }
}
</script>

<style scoped>
.root {
    width: 750px;
    flex: 1;
}
.map-div {
    width: 750px;
    margin-bottom: 20px;
}
</style>

```

然后执行：

```
$ npm start
```
新添加的文件需要重新执行上面的命令，否则将不能被编译进去。会提示该文件不存在。

## API

| 属性        | 类型         | Demo  | 描述  |
| ------------- |:-------------:| -----:|----------:|

### 提供给weex使用的属性
  zoomLevel：比例尺等级，默认14。取值范围：4-21；
  zoomControlsEnabled：是否展示地图缩放按钮，默认false。ios不支持；
  showTraffic：是否实时显示路况信息,默认false；
  userLocation：用户位置的经纬度，例：{latitude:'31.242727',longitude:'121.513295'}
  showScaleBar：是否显式比例尺，默认true
  scaleBarPosition：比例尺的位置，例如：{x:10,y:10}

### 提供给weex使用的事件方法
  mapLoaded：地图加载完成事件；
  selectBubble：选中标注事件；
  autoAddAnnotation：点击地图空白处添加标注事件,不实现该方法，无法添加。
### 地图元素添加标注方法
weex使用：
```
   this.$refs.map.addAnnotation(annotationConfig)
```
  annotationConfig配置对象参数说明：
    pointType:0:默认标注 1:自定义标注图标
    paopaoType:0:默认泡泡，1:自定义泡泡
    canShowCallout:设置气泡是否可以弹出true或false
    select:设置标注是否弹出气泡true或false，只能选中一个
    pinColor:pointType为0时有效 pinColor取值：red,green,purple
    image:设置标注图片,在pointType为1时有效；设置泡泡图片paopaoType为1时有效
    title:若title为nil，则无法弹出泡泡
    subtitle:副标题

## location模块
**location** 模块提供了以下展示消息框的 API: `location`、`geoCode`、`reverseGeoCode`、`POISearch`
### location(callback)
说明：返回经纬度及位置信息
返回结果：
```
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
         locationDescribe:'位置语义化结果的定位点在什么地方周围的描述信息，例如：东方明珠'
     }
 }
```
### geoCode(options,callback)
说明：根据位置信息返回经纬度；
参数options：{"city":"城市名称","address":"街道地址"}
返回结果：
```
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
```

### reverseGeoCode(options,callback)
 说明：根据地理编码返回结果
 参数options：{"latitude":"纬度","longitude":"经度"}
 返回结果：
 ```
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
 ```
### POISearch(options,callback)
说明：城市POI搜索服务
参数options：{"city":"城市名称","keyword":"关键字"}
返回结果：
```
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
```

## 展示效果

 ![image](https://github.com/ZJWeex/wxbaidumap/blob/master/userLoc.png)
 ![image](https://github.com/ZJWeex/wxbaidumap/blob/master/annotation.png)
 ![image](https://github.com/ZJWeex/wxbaidumap/blob/master/paopao.png)
 ![image](https://github.com/ZJWeex/wxbaidumap/blob/master/search.png)