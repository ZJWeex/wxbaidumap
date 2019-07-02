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
