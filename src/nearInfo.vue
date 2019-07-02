<template>
    <div class='root'>
        <navigation title="附近信息"/>
        <list style="width:750px;flex:1;">
            <cell v-for="(item,i) in nearAddresses" :index="i" :key="i">
                <div class="cell-content" @click="didSelectAddress(item)">
                    <text style="color:#333333;font-size:30px;">{{item.name}}</text>
                    <text style="color:#999999;font-size:26px;">{{item.address}}</text>
                    <text v-if="item.area">{{item.area}}</text>
                </div>
            </cell>
            <cell v-if="nearAddresses.length==0" class="emty-view">
                <image style="width:130px;height:130px;margin-bottom:40px;" src="/web/assets/sup/sup_homeSearch_icon.png"/>
                <text style="color:#666;font-size:30px;">没有搜索到相关地址</text>
            </cell>
        </list>
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
             userLocation:{},
             nearAddresses:[],
        }
    },
    created() {
        const self = this
        location.location(function(ev){
            if(ev.result == 'success'){
                let userLocation = ev.data;
                self.userLocation = userLocation;
                self.reverseGeoSearch(userLocation);
            }
        })
    },
    methods: {
        mapLoaded:function(){
            console.log('地图加载完成')
        },
        didSelectAddress:function(item){
            console.log("选择了：",item)
        },
        reverseGeoSearch:function(coordinate){
            const self = this
            location.reverseGeoCode(coordinate,function(result){
                   
                   if(result.result == 'success'){
                       console.log('area_address:',JSON.stringify(result.data))
                       self.nearAddresses = result.data.poiList;
                   }else{
                       self.nearAddresses = []
                   }
               })
        },
    }
}
</script>

<style scoped>
.root {
    width: 750px;
    flex: 1;
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
