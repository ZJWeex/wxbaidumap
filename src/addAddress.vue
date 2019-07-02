<template>
    <div class='wrapper'>
        <navigation title="添加地址"/>
        <scroller style="width:750px;flex:1;" alwaysScrollableVertical='true'>
            <div class="box">
                <input type="text" class="input"
                        placeholder="收货人"
                        max-length=10
                        maxlength=10
                        :value="addressmodel.true_name" 
                        @change="onchange(1,$event)" 
                        @input="oninput(1,$event)"/>
                <div style="padding-right:20px;padding-left:40px;" @click="cancelInput">
                    <image v-if="addressmodel.true_name != ''" style="width: 30px; height: 30px; margin: 10px;" resize="contain" src='/web/assets/imgs/sup_personal_cancle_input.png' @click="cancelInput"/>
                </div>
            </div>
            <div class="box">
                <input type="tel" class="input" 
                        placeholder="输入手机号码" 
                        max-length=11
                        maxlength=11
                        :value="addressmodel.telephone" 
                        @change="onchange(2,$event)" 
                        @input="oninput(2,$event)"/>
            </div>
            <div class="box" @click="citypicker(1)">
                <div class="address-marker">
                    <text v-if="cityName.length>0" class="city-div">{{cityName}}</text>
                    <text v-else class="city-des">所在城市</text>
                    <image style="width:20px;height:40px;" src="/web/assets/imgs/sup_personal_next.png"/>
                </div>
            </div>
            <div class="box" @click="goToMap">
                <div class="address-marker">
                    <div style="flex-direction: row;align-items: center;">
                        <image style="width:28px;height:34px;" src="/web/assets/imgs/sup_address_loction.png"/>
                        <text v-if="addressmodel.area_name.length>0" class="area-text">{{addressmodel.area_name}}</text>
                        <text v-else class="area-des">小区／写字楼</text>
                    </div>
                    <image style="width:20px;height:40px;" src="/web/assets/imgs/sup_personal_next.png"/>
                </div>
            </div>
            <div style="margin-bottom:40px;">
                <textarea class="textarea" placeholder="楼号门牌" 
                        :value="addressmodel.area_info" 
                        @change="onchange(10,$event)" 
                        @input="oninput(10,$event)"></textarea>
            </div>
            <div class="box">
                <div class="address-marker" @click="selectMarkerClick">
                    <text style="color:#333333;font-size:30px;">地址标签</text>
                    <div style="flex-direction: row;align-items: center;">
                        <text v-if="addressMarker.addrType==10" style="color:#999999;font-size:28px;">{{addressMarker.name}}</text>
                        <image v-else-if="addressMarker.addrType>0" style="width:50px;height:50px;" :src="addressMarker.img"/>
                        <text v-else style="color:#999999;font-size:28px;">请选择</text>
                        <image style="width:20px;height:40px;" src="/web/assets/imgs/sup_personal_next.png"/>
                    </div>
                </div>
            </div>
            <div v-if="!isDefaultAddress" class="box">
                <div class="address-marker">
                    <text style="color:#333333;font-size:30px;">设为默认地址</text>
                    <image v-if="defaultAddress" style="width:80px;height:50px;margin-right:40px;" src="/web/assets/imgs/sup_address_swtchselect.png" @click="setDefaultAddressClick"/>
                    <image v-else style="width:80px;height:50px;margin-right:40px;" src="/web/assets/imgs/sup_address_swtch.png" @click="setDefaultAddressClick"/>
                </div>
            </div>
            <div class="box box-top" v-if="addressmodel.addr_id.length>0">
                <text class="delete-Address" @click="deleteAddressClick">删除收货地址</text>
            </div>
            <div class="save-address | save-button" @click="saveAddressClick">
                <text class="save-text">保存收货地址</text>
            </div>
        </scroller>
    </div>
</template>

<script>
import citys from "@/citys.js";
import navigation from "@/components/NavigationBar.vue";

const storage = weex.requireModule("storage");
const picker = weex.requireModule('picker')
const modal = weex.requireModule('modal');

export default {
    components: { navigation },
    data() {
        return {
            isAndroid: WXEnvironment.platform === "android",
            loading: false,
            isDefaultAddress:false,
            defaultAddress:false,
            showPopup:false,
            popupHeight:680,
            addressMarker:{img:'',name:'',addrType:'0'},//地址标签
            selectAddressIndex:0,
            province:'',//省
            cityName:'',//市
            areaName:'',
            addressmodel:{
                    telephone: "",
                    true_name: "",
                    areaId:'',////行政区Id 如 普陀区Id
		            areas: [ {
			            areaId: "",
			            areaName: "",
			            level: ""//0省、1市、2区、3详细地址
		            }],
                    area_info: "",//详细地址
                    area_name: "",
                    addr_id: "",
                    lng: "",
                    lat: "",
                    addrType:'0',
                    custom_label:'',
            },
            
        }
    },
    created() {
        var self = this;
        //选择定位地址回调
        const loctionChannel = new BroadcastChannel("loctionAddressChannel");
        loctionChannel.onmessage = function (event){
            console.log('通道名称：',event.data) 
            let model = JSON.parse(event.data)
            if(model.province&&self.province != model.province){
                self.province = model.province;
            }
            if(model.city&&self.cityName != model.city){
                self.cityName = model.city;
            }
            self.areaName = model.area;
            self.addressmodel.areaId = citys.getArea_id(self.province,self.cityName,self.areaName);
            self.addressmodel.lng = model.longitude;
            self.addressmodel.lat = model.latitude;
            self.addressmodel.area_name = model.name;
            self.addressmodel.area_info = model.address;
            console.log('areaId:',self.addressmodel.areaId)
            modal.toast({message:'请补全门牌号'})
        }
        //地址编辑传值
        storage.getItem('addressEdit', event => {
          console.log('get value:', event.data)
          
          if(event.data &&event.data != 'undefined'){
              let param = JSON.parse(event.data)
              var addrId = param.addressId;
              let acquiescent_addr = param.acquiescent_addr;
              if(acquiescent_addr == 1){
                  self.defaultAddress = true;
                  self.isDefaultAddress = true
              }else{
                  self.defaultAddress = false;
                  self.isDefaultAddress = false
              }
              self.addressmodel.addrType = param.addrType

              storage.removeItem('addressEdit',event => {})
          }else{
              storage.getItem(Define.kPhone, event => {
                  if(event.data != 'undefined'){
                    //   console.log('kPhone:', event.data)
                      //$set可触发视图变化，self.addressmodel.telephone=value无效
                      self.$set(self.addressmodel,'telephone',event.data)
                  }
              })
          }
          
        })
    },
    methods: {
        goToMap:function(street){
            let mapSearchParam = {cityName:this.cityName}
            if((typeof street) == 'string'){
                //老地址搜索内容
                mapSearchParam.address = street
            } 
            //用于排序
            mapSearchParam.area_name = this.addressmodel.area_name
            //用于地址编辑，给当前地址添加标注
            mapSearchParam.longitude = this.addressmodel.lng
            mapSearchParam.latitude = this.addressmodel.lat

            storage.setItem('city_POI',JSON.stringify(mapSearchParam),event =>{})
            let url = 'addressExample.html'
             navigation.push({url:url, title:'地址选择'}, event =>{});
        },
        //输入事件
        onchange:function(index,event){
            console.log("index:"+index+"\nchange:", event.value);
            if(index==1){
                this.addressmodel.true_name = event.value;
            }else if(index == 2){
                 this.addressmodel.telephone = event.value;
            }else if(index == 3){
                 
            }else if(index == 10){
                 this.addressmodel.area_info = event.value;
            }
        },
        oninput:function(index,event) {
            console.log("index:"+index+"\ninput:", event.value);
            if(index==1){
                this.addressmodel.true_name = event.value;
            }else if(index == 2){
                 this.addressmodel.telephone = event.value;
            }else if(index == 3){
                
            }else if(index == 10){
                 this.addressmodel.area_info = event.value;
            }else if(index == 11){
                 let value = event.value;
                 let item = this.markerList[0]
                 item.name = value 
            }
        },
        inputGetFocus:function(e){
            this.selectAddressIndex = 0
        },
        cancelInput:function(){
            this.$set(this.addressmodel,'true_name','')
        },
        //选择地址
        citypicker:function(tag) {
            const self = this;
            var items = []
            var title = '请选择'
            if(tag == 1){
                items = citys.province_list();
                title = '请选择省市'
            }else if(tag == 2){
                if(self.province.length<=0)return;
                items = citys.city_list(self.province);
                title = '请选择城市'
            }else if(tag == 3){
                if(self.cityName.length<=0)return;
                items = citys.areaorcounty_list(self.province,self.cityName);
                title = '请选择区域'
            }
            var options = {
                index:0,
                items:items,
                confirmTitle:'确认',
                cancelTitle:'取消',
                confirmTitleColor:'#ff0033',
                cancelTitleColor:'#999999',
                title:title
            }
            picker.pick(options,function(ret){
                if(ret.result === 'success'){
                    let index = ret.data;
                    if(tag == 1){
                        let province = citys.getProvinceName(ret.data);
                        if(self.province != province){
                            // self.cityName = '';
                            self.areaName = '';
                        }
                        self.province = province;
                        console.log('province:',province)
                        setTimeout(() => {
                             self.citypicker(2)
                        }, 300)
                    }else if(tag == 2){
                        let cityName = citys.getCityName(self.province,ret.data);
                        if(self.cityName != cityName){
                            self.cityName = ''
                            self.areaName = ''
                            self.addressmodel.areaId = ''
                            self.addressmodel.area_info = ''
                            self.addressmodel.area_name = ''
                            self.addressmodel.lng = ''
                            self.addressmodel.lat = ''
                        }
                        self.cityName = cityName;
                    }else if(tag == 3){
                        self.areaName = citys.getAreaName(self.province,self.cityName,ret.data);
                        self.addressmodel.areaId = citys.getArea_id(self.province,self.cityName,self.areaName);
                    }
                }
                
            })

        },
        
        //设置默认地址
        setDefaultAddressClick:function(){
            this.defaultAddress = !this.defaultAddress;
        },

        //删除地址
        deleteAddressClick:function(){
            const self = this
            modal.confirm({message:'确定删除该地址吗？',okTitle:'确定',cancelTitle:'取消'},result=>{
                if(result == '确定'){
                    console.log('删除该地址')
                }
            })
        },
        
        
        //删除地址
        deleteAddressHandle:function(addressId) {
            const self = this;
            var param = {mulitId:addressId}
            
        },
        //保存收货地址
        saveAddressClick:function(){
            //数据校验
            var msg = '';
            if(this.Trim(this.addressmodel.lng.toString()).length == 0){
                msg = '无定位坐标，无法保存';
            }
            
            if(this.Trim(this.addressmodel.area_info).length == 0){
                msg = '请填写详细地址';
            }
            if(this.addressmodel.area_name.length == 0){
                msg = '请选择小区／写字楼';
            }
            if(this.Trim(this.cityName).length == 0){
                msg = '请选择城市';
            }
            
            if(this.Trim(this.addressmodel.telephone).length == 0){
                msg = '请输入手机号';
            }
            if(this.Trim(this.addressmodel.true_name).length == 0){
                msg = '请输入联系人';
            }
            if(msg.length > 0){
                modal.toast({message:msg,duration: 1.0})
                return;
            }
            // 数据整理
            var param = {
                lng:Number(this.addressmodel.lng).toFixed(6).toString(),
                lat:Number(this.addressmodel.lat).toFixed(6).toString(),
                district_id:this.addressmodel.areaId,//行政区areaId
                area_name:this.addressmodel.area_name,
                area_info:this.addressmodel.area_info,
                telephone:this.addressmodel.telephone,
                trueName:this.addressmodel.true_name,
                addrType:this.addressmodel.addrType.toString(),
                custom_label:this.addressMarker.name,
                code:'',
            }
            if(this.addressmodel.addr_id && this.addressmodel.addr_id.length > 0){
                //编辑地址使用
                param.addr_id = this.addressmodel.addr_id;
            }
            console.log("发送前参数："+JSON.stringify(param));
            
        },
        //设置默认地址
        setDefaultAddress:function(addressId,callBlock){
            console.log('地址类型：',typeof addressId)
        },
        //去除首尾空格
         Trim:function(str){ 
            return str.replace(/(^\s*)|(\s*$)/g, ""); 
        },
    }
}
</script>

<style scoped>
.wrapper { 
    width: 750px;
    flex: 1;
    background-color: #f5f5f9;
}
.box {
    flex-direction: row;
    align-items: center;
    height: 90px;
    border-bottom-width: 2px;
    border-bottom-color: #f5f5f9;
    background-color: #ffffff;
}
.input {
    margin-right: 40px;
    margin-left: 40px;
    height: 70px;
    width: 500px;
}
.city-div {
    color:#333333;
    font-size:30px;
    padding:10px;
}
.city-des {
    color:#999999;
    font-size:30px;
    padding:10px;
}
.area-text {
    color:#333333;
    font-size:30px;
    padding:10px;
    width: 620px;
}
.area-des {
    color:#999999;
    font-size:30px;
    padding:10px;
}
.textarea {
    width: 750px;
    height: 120px;
    padding: 20px;
    font-size: 30px;
    color: #333333;
    background-color: white;
}
.address-marker{
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    flex: 1;
    margin-left:40px;
    margin-right:20px;
}
.box-top {
    margin-top: 40px;
}
.delete-Address {
    margin-left: 40px;
    font-size:30px;
    color: #d0104c;
}
.delete-Address:active {
    color: rgb(112, 0, 16);
}

.save-address {
    justify-content: center;
    align-items: center;
    height: 80px;
    margin-top: 60px;
    margin-right: 20px;
    margin-left: 20px;
    border-radius: 40px;
}
.save-button {
    background-color: #d0104c;
}
.save-button:active {
    background-color: rgb(112, 0, 16);
}
.save-text {
    color: white;
    font-size: 30px;
}

.popup-content{
    margin: 40px;
    flex: 1;
    border-radius: 20px;
    background-color: #ffffff;
    /* align-items: center; */
}
.select-marker{
    width:30px;
    height:30px;
    margin-right:30px;
}

.complete-btn {
    height:60px;
    width:350px;
    border-radius: 30px;
    align-items: center;
    justify-content:center;
    background-image: linear-gradient(to right,#e42a8b,#ff565a);
}

</style>
