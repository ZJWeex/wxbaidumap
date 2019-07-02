<template>
    <div @viewappear="viewappear">
        <navigationSearch :title="navTitle"
                          :showInput="false" 
                          left-button=''
                          @wxcMinibarMiddleButtonClicked='wxcMinibarMiddleButtonClicked'>
            </navigationSearch>
        <div class="wrapper">
            <div class="button" @click="onClick(1)">
                <text class="text">显示地图页面</text>
            </div>
            <div class="button" @click="onClick(2)">
                <text class="text">添加标注</text>
            </div>
            <div class="button" @click="onClick(3)">
                <text class="text">附近地理信息</text>
            </div>
            <div class="button" @click="onClick(4)">
                <text class="text">城市内搜索</text>
            </div>
             <div class="button" @click="onClick(5)">
                <text class="text">实际应用</text>
            </div>
        </div>
    </div>
</template>

<script>
import navigationSearch from "@/components/NavigationBarSearch.vue";
const modal = weex.requireModule('modal');

export default {
    components: { navigationSearch },
    data() {
        return {
           navTitle:'搜索商品',
        }
    },
    created() {

    },
    methods: {
        viewappear:function(){
          console.log('viewappear')
        },
         wxcMinibarMiddleButtonClicked () {
            console.log('点击中间了')
        },
        onClick:function(tag){
          let url = ''
            switch (tag) {
              case 1:
                url = 'mapview.html'
                break;
              case 2:
                url = 'mapannotation.html'
                break;
              case 3:
                url = 'nearInfo.html'
                break;
              case 4:
                url = 'searchAddress.html'
                break;
              case 5:
                url = 'addAddress.html'
                break;
            
              default:
                break;
            }
            navigationSearch.push({url:url, title:'地址选择'}, event =>{});
        },
    }
}
</script>

<style scoped>
.wrapper { 
    flex: 1;
    align-items: center;
}
.button {
  flex-direction: row;
  justify-content: center;
  align-items: center;
  height: 90px;
  width:300px;
  margin-top: 100px;
  border-radius: 10px;
  background-color: #ff0033;
}

.button:active{
  background-color: brown;
}

.text{
   color: #ffffff;
   font-size: 32px;
   font-weight: bold;
}
</style>
