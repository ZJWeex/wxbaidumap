<template>
    <div class='root'>
        <navigation title="地图界面"/>
        <div style="flex:1;background-color: orange;">
            <map class="map-div" :style="{height:mapHeight}"
                    ref='map'
                    @mapLoaded="mapLoaded"
                    @selectBubble="selectBubble"
                    @autoAddAnnotation='autoAddAnnotation'
                    zoomLevel='14' 
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
                      image:'http://img2.ph.126.net/2zB3_wWPXlEW0RdwQa8d6A==/2268688312388037455.jpg'}
            
            this.$refs.map.addAnnotation(annotationConfig2)

            let annotationConfig3={latitude:"31.242727",//纬度
                      longitude:"121.383295",//经度
                      title:"上海",
                      subtitle:"自定义标注，自定义泡泡",
                      pointType:'1',
                      paopaoType:'1',
                      pinColor:'red',
                      canShowCallout:'true',
                      image:'http://images.china.cn/attachement/jpg/site1000/20141115/002564bb43f115d12f4a5a.jpg'}
            
            this.$refs.map.addAnnotation(annotationConfig3)

            let annotationConfig4={latitude:"31.242727",//纬度
                      longitude:"121.363295",//经度
                      title:"上海",
                      subtitle:"自定义标注，不弹出泡泡",
                      pointType:'1',
                      paopaoType:'1',
                      pinColor:'red',
                      canShowCallout:'false',
                      image:'/web/assets/imgs/fhb.png'}
            
            this.$refs.map.addAnnotation(annotationConfig4)
            //添加一组标注
            // this.$refs.map.addAnnotations([annotationConfig4,annotationConfig3,annotationConfig2,annotationConfig1,annotationConfig])
        },
        selectBubble(event){
            //点击标注泡泡的方法
            console.log('泡泡:',JSON.stringify(event.rawData))
        },
        //自动添加标注
        autoAddAnnotation(event){
            console.log('自动添加的标注：',event)
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
