<template>
    <div class='root'>
        <navigation title="城市内搜索"/>
        <div class="search">
            <div class="input-content">
                <image style="height:30px;width:30px;margin-left:30px;" src="/web/assets/imgs/sup_homeSearch_icon.png"/>
                <input type="text" placeholder="输入要搜索的地方" 
                    class="input" :autofocus="true" 
                    ref="searchInput"
                    :value="inputStr"
                   return-key-type="search"  @input="onInput" @keyboard='keyboardClick'/>
            </div>
        </div>
        <list style="width:750px;flex:1;">
            <cell>
                <div v-if="isShowEmty" class="emty-view">
                    <image style="width:130px;height:130px;margin-bottom:40px;" src="/web/assets/sup/sup_address_mapSearch.png"/>
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
const modal = weex.requireModule('modal');

export default {
    components: { navigation },
    data() {
        return {
            inputStr:'',
            cityName:'上海市',
            isShowEmty:false,
            resultArray:[]
        }
    },
    created() {

    },
    methods: {
        onInput:function(event){
            this.inputStr = event.value;
            if(this.inputStr.length==0){
                this.isShowEmty = true;
                this.resultArray = [];
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
