<template>
    <div class='root' @viewappear="viewappear">
        <navigation title="地址搜索"/>
        <div class="search">
            <div class="input-content">
                <image style="height:30px;width:30px;margin-left:30px;" src="/web/assets/imgs/sup_homeSearch_icon.png"/>
                <input type="text" placeholder="输入要搜索的地方" 
                    class="input" :autofocus="false" 
                    ref="searchInput"
                    :value="inputStr"
                   return-key-type="search"  @input="onInput" @keyboard='keyboardClick'/>
                <div style="padding-right:10px;padding-left:10px;" @click="cancelInput">
                    <image v-if="inputStr != ''" style="width: 30px; height: 30px; margin: 10px;" resize="contain" src='/web/assets/imgs/sup_personal_cancle_input.png' @click="cancelInput"/>
                </div>
            </div>
        </div>
        <div :style="{height:inputStr.length==0&&!isShowEmty?700:0}">
            <map class="map-div" :style="{left:inputStr.length==0&&!isShowEmty?0:750}"
                    ref='map' 
                    @mapLoaded="mapLoaded"
                    @selectBubble="selectBubble"
                    zoomLevel='18' 
                    showTraffic='false' 
                    :userLocation="userLocation"
                    showScaleBar="true" 
                    :scaleBarPosition="{x:10,y:700-40}"></map>
        </div>
        <list style="width:750px;flex:1;">
            <cell>
                <div v-if="isShowEmty" class="emty-view">
                    <image style="width:130px;height:130px;margin-bottom:40px;" src="/web/assets/imgs/sup_homeSearch_icon.png"/>
                    <div style="flex-direction: row;">
                        <text style="color:#666;font-size:30px;">你所选的城市是“</text>
                        <text style="color:#fcc477;font-size:30px;">{{cityName}}</text>
                        <text style="color:#666;font-size:30px;">”</text>
                    </div>
                    <text style="color:#666;font-size:30px;">请搜索该城市内的写字楼、小区</text>
                </div>
            </cell>
            <cell v-for="(item,i) in resultArray" :index="i" :key="i">
                <div class="cell-content" @click="didSelectAddress(item)">
                    <text style="color:#333333;font-size:30px;">{{item.name}}</text>
                    <text style="color:#999999;font-size:26px;">{{item.address}}</text>
                    <!-- <text v-if="item.area">{{item.area}}</text> -->
                </div>
            </cell>
            <cell v-if="resultArray.length==0&&inputStr.length>0" class="emty-view">
                <image style="width:130px;height:130px;margin-bottom:40px;" src="/web/assets/sup/sup_address_mapSearch.png"/>
                <text style="color:#666;font-size:30px;">没有搜索到相关地址</text>
            </cell>
        </list>
    </div>
</template>

<script>

import navigation from "@/components/NavigationBar.vue";

const location = weex.requireModule("location");
const storage = weex.requireModule("storage");
const modal = weex.requireModule('modal');

export default {
    components: { navigation},
    data() {
        return {
            inputStr:'',
            nearAddresses:[],
            isShowEmty:false,
            cityName:'海市',
            userLocation:{},
            resultArray:[],
            area_name:'',//前个界面带过来的地址信息，用于排序
        }
    },
    created() {
        const self = this
        let promiseLocation = function () {
            return new Promise((resolve,reject) => {
                try {
                    location.location(function(ev){
                        if(ev.result == 'success'){
                            /* 
                            ev.data:{
                                latitude:'纬度',
                                longitude:'经度',
                                city:'城市',
                                locationDescribe:'位置语义化结果的定位点在什么地方周围的描述信息，例如：天地软件园'
                            }
                            */
                            resolve(ev.data)  
                        }else{
                            reject(ev)
                        }
                        
                    })
                }catch(e){
                    reject(e)
                }
                
            })
        }

        let promiseGeoSearch = function(userLocation){
            return storage.getItem('city_POI',event => {
                console.log('city_POI:',event.data)
                // 字段说明：cityPoi={cityName:'城市名称',area_name:'用于位置信息排序',address:'老地址搜索内容',longitude:'',latitude:'用于地址编辑，给当前地址添加标注'}
                let cityPoi = JSON.parse(event.data)
                
                if(cityPoi.area_name){
                    self.area_name = cityPoi.area_name;
                }
                storage.removeItem('city_POI',event => {})
                //1,获取到用户位置；2，所选城市名和定位城市相同；3，不包含街道地址信息；4,不包含经纬度
                let isUseLocation = userLocation
                                    &&(!cityPoi.cityName || cityPoi.cityName == userLocation.city)
                                    &&(!cityPoi.address || cityPoi.address.length==0)
                                    &&!(cityPoi.longitude||cityPoi.latitude)

                if(isUseLocation){
                    self.cityName = userLocation.city;
                    //所选城市和定位城市相同而且没传经纬度，则使用用户定位 
                    self.userLocation = userLocation;
                    if(cityPoi.longitude){
                        setTimeout(()=>{
                            self.addCityAddressAnnotation(cityPoi)
                            self.reverseGeoSearch(cityPoi);
                        },100)
                    }else{
                        self.reverseGeoSearch(userLocation);
                    }
                }else if(cityPoi.longitude){
                    self.cityName = cityPoi.cityName
                    //地址编辑定位在当前地址附近
                    self.addCityAddressAnnotation(cityPoi)
                    self.reverseGeoSearch(cityPoi)
                }else{
                    self.cityName = cityPoi.cityName
                    var geoCodeParam = {'city':self.cityName}
                    let searchContent = cityPoi.address
                    if(searchContent&&searchContent.length>0){
                        self.inputStr = searchContent;
                        geoCodeParam.address = searchContent
                    }
                    location.geoCode(geoCodeParam,function(result){
                        console.log('根据城市返回：',result);
                        if(result.result == 'success'){
                            self.addCityAddressAnnotation(result.data)
                            self.reverseGeoSearch(result.data)
                        }else{
                            self.resultArray = []
                        }
                    }) 
                }
            })
        }
        promiseLocation().then((userLocation)=>{
            console.log('promiseLocation:',userLocation)
            return promiseGeoSearch(userLocation)
        },reject =>{
            //定位失败，采用地理编码
            promiseGeoSearch()
        })
        
    },
    methods: {
         viewappear:function(){
             let searchInputEl =  this.$refs.searchInput
             if(searchInputEl){
                  this.$refs.searchInput.blur();
             }
        },
        mapLoaded(){
            console.log('地图记载完成')
            if(WXEnvironment.platform != 'web'){
                return
            }
            //地图加载完成后，添加一个标注
           let annotationConfig={latitude:"31.242727",//纬度
                      longitude:"121.443295",//经度
                      title:"上海",
                      subtitle:"默认标注，默认泡泡",
                      pointType:'0',
                      pinColor:'red',
                      canShowCallout:'true',
                      image:'location_marker'}
            
            this.$refs.map.addAnnotation(annotationConfig)

            let annotationConfig1={latitude:"31.242727",//纬度
                      longitude:"121.423295",//经度
                      title:"上海",
                      subtitle:"自定义标注，默认泡泡",
                      pointType:'1',
                      pinColor:'green',
                      canShowCallout:'true',
                      image:'location_marker'}
            
            this.$refs.map.addAnnotation(annotationConfig1)

            let annotationConfig2={latitude:"31.242727",//纬度
                      longitude:"121.403295",//经度
                      title:"上海",
                      subtitle:"默认标注，自定义泡泡",
                      pointType:'0',
                      pinColor:'green',
                      paopaoType:'1',
                      canShowCallout:'true',
                      image:'location_marker'}
            
            this.$refs.map.addAnnotation(annotationConfig2)

            let annotationConfig3={latitude:"31.242727",//纬度
                      longitude:"121.383295",//经度
                      title:"上海",
                      subtitle:"自定义标注，自定义泡泡",
                      pointType:'1',
                      paopaoType:'1',
                      pinColor:'red',
                      canShowCallout:'false',
                      image:'http://tcmdefaultbucket-1253294191.cossh.myqcloud.com/img/upload/avatar/654b64f2-e820-490a-81f1-a29a2b75da8e.jpg_small.jpg'}
            
            this.$refs.map.addAnnotation(annotationConfig3)

            let annotationConfig4={latitude:"31.242727",//纬度
                      longitude:"121.363295",//经度
                      title:"上海",
                      subtitle:"自定义标注，不弹出泡泡",
                      pointType:'1',
                      paopaoType:'1',
                      pinColor:'red',
                      canShowCallout:'false',
                      image:'/web/assets/sup/sup_address_loction.png'}
            
            this.$refs.map.addAnnotation(annotationConfig4)
            //添加一组标注
            // this.$refs.map.addAnnotations([annotationConfig4,annotationConfig3,annotationConfig2,annotationConfig1,annotationConfig])
        },
        reverseGeoSearch:function(coordinate){
            const self = this
            location.reverseGeoCode(coordinate,function(result){
                   
                   if(result.result == 'success'){
                       //将传过来的地址排序在第一个
                       console.log('area_address:',self.area_name)
                       if(self.area_name.length>0){
                           let index = -1
                          index = result.data.poiList.map(function(e){
                               return e.name
                           }).indexOf(self.area_name)

                           if(index>-1){
                               let item = result.data.poiList.splice(index,1);
                               result.data.poiList.unshift(item[0])
                           }
                       }
                       self.resultArray = result.data.poiList
                   }else{
                       self.resultArray = []
                   }
                   self.nearAddresses = self.resultArray;
               })
        },
        //添加城市标注
        addCityAddressAnnotation:function(param){
            let annotationConfig1={latitude:param.latitude,//纬度
                      longitude:param.longitude,//经度
                      title:"城市",
                      subtitle:"自定义标注，默认泡泡",
                      pointType:'1',
                      pinColor:'green',
                      canShowCallout:'false',
                      image:'location_marker'}
            let mapEl =  this.$refs.map
            if(mapEl){
                mapEl.addAnnotation(annotationConfig1)
            } 
        },
        selectBubble(event){
            //点击标注泡泡的方法
            // modal.alert({message:'泡泡:'+JSON.stringify(event.rawData)},ev=>{})
        },
        onInput:function(event){
            this.inputStr = event.value;
            if(this.inputStr.length==0){
                this.isShowEmty = true;
                this.resultArray = this.nearAddresses;
            }else{
                this.isShowEmty = false;
            }
            this.searchAddressMethod(this.inputStr)
        },
        keyboardClick:function(keyboard){
            if(this.inputStr.length==0){
                if(keyboard.isShow){
                    this.isShowEmty = true;
                }else{
                    this.isShowEmty = false;
                    this.resultArray = this.nearAddresses;
                    return;
                }
                
            }
            this.searchAddressMethod(this.inputStr)
        },
        cancelInput:function(){
            this.inputStr = ''
            this.isShowEmty = true;
            this.resultArray = []
        },
        searchAddressMethod:function(keyword){
            const self = this
            location.POISearch({city:self.cityName,keyword:this.inputStr},function(event){
                // modal.alert({message:'搜索结果:'+JSON.stringify(event)},call=>{})
                if(event.result == 'success'){
                    /*
                    [{name:'',address:'',area:''}]
                    */
                    self.resultArray = event.data
                }else{
                   self.resultArray = [] 
                }
                
            })
        },

        //选择地址点击事件
        didSelectAddress:function(item){
            let poiInfo = JSON.stringify(item)
            const loctionChannel = new BroadcastChannel("loctionAddressChannel");
            loctionChannel.postMessage(poiInfo);
            this.$refs.searchInput.blur();
            //返回
            navigation.pop({},function(value){});
        },

    }
}
</script>

<style scoped>
.root {
    width: 750px;
    flex: 1;
}
.search {
    flex-direction: row;
    justify-content: center;
    align-items: center;
    height: 90px;
}
.input-content {
    flex-direction: row;
    align-items: center;
    height: 66px;
    margin-right: 15px;
    margin-left: 15px;
    flex: 1;
    border-radius: 33px;
    background-color: #f5f5f9;
}
.input {
    font-size: 26px;
    /* text-align: right; */
    margin-right: 25px;
    padding-left:20px;
    padding-right:20px;
    height: 66px;
    flex: 1;
}
.map-div {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    width:750px;
    height: 700px;
}
.cell-content {
    padding: 20px;
    border-bottom-width: 2px;
    border-bottom-color: #f5f5f9;
}
.emty-view {
    align-items: center;
    margin-top: 100px;
}
</style>
