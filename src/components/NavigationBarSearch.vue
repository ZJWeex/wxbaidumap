<template>
    <div v-if="show && isApp" :style="{backgroundColor: backgroundColor,}">
        <div v-if="IOS" :style="{height: sBHeight,}"></div>
        <div
            class="wxc-minibar"
            :style="{backgroundColor: backgroundColor, height:nBHeight}"
            v-if="show"
        >
            <div class="left" @click="leftButtonClicked" aria-label="返回" :accessible="true">
                <slot name="left">
                    <image :src="leftButton" v-if="leftButton && !leftText" class="left-button"></image>
                    <text v-if="leftText" class="icon-text" :style="{color: textColor}">{{leftText}}</text>
                </slot>
            </div>
            <div v-if="showInput == false" class="middle-input-bg" @click="middleButtonClicked">
                <slot name="middle">
                    <image :src="middleIcon" class="middle-icon"></image>
                    <text v-if="title" class="middle-title" :style="{color: titleColor}">{{title}}</text>
                    <text
                        v-else-if="pageName"
                        class="middle-title"
                        :style="{color: titleColor}"
                    >{{pageName}}</text>
                </slot>
            </div>
            <div v-else-if="showInput == true" class="middle-input-bg">
                <slot name="middle">
                    <image :src="middleIcon" class="middle-icon"></image>
                    <input
                        type="text"
                        ref="str_input"
                        placeholder="输入商品名称"
                        class="middle-input"
                        :value="theInputValue"
                        @input="inputListener"
                        @keyboard="keyboardShowOrHide"
                        return-key-type="search"
                        autofocus="true"
                        @return="returnKeyClick"
                    >
                    <div>
                        <image
                            v-if="theInputValue != ''"
                            style="width: 30px; height: 30px; margin-left: 10px;"
                            resize="contain"
                            src="/web/assets/sup/sup_personal_cancle_input.png"
                            @click="cancelInput"
                        ></image>
                    </div>
                    <!-- <text v-if="title" class="middle-title" :style="{color: titleColor}">{{title}}</text>
                    <text v-else-if="pageName" class="middle-title" :style="{color: titleColor}">{{pageName}}</text>-->
                </slot>
            </div>
            <div class="right" @click="rightButtonClicked">
                <slot name="right">
                    <image
                        v-if="rightButton && !rightText"
                        class="right-button"
                        :src="rightButton"
                        :aria-hidden="true"
                    ></image>
                    <text
                        v-if="rightText"
                        class="icon-text"
                        :style="{color: textColor}"
                    >{{rightText}}</text>
                </slot>
            </div>
        </div>
        <div v-if="breakLineColor != ''" :style="{backgroundColor: breakLineColor, height: 0.8}"></div>
    </div>
</template>

<script>
export default {
    components: {},
    props: {
        backgroundColor: {
            type: String,
            default: "white"
        },
        textColor: {
            // 左右按钮文字颜色
            type: String,
            default: "#ff0033"
        },
        titleColor: {
            // 标题文字颜色
            type: String,
            default: "#999999"
        },
        title: {
            type: String,
            default: ""
        },
        leftButton: {
            type: String,
            default: "/web/assets/imgs/sup_setting_supermarkets_fh.png"
        },
        rightButton: {
            type: String,
            default: ""
        },
        leftText: {
            type: String,
            default: ""
        },
        rightText: {
            type: String,
            default: ""
        },
        middleIcon: {
            type: String,
            default: "/web/assets/imgs/sup_homeSearch_icon.png"
        },
        useDefaultReturn: {
            type: Boolean,
            default: true
        },
        show: {
            type: Boolean,
            default: true
        },
        breakLineColor: {
            type: String,
            default: "#f0f0f0"
        },
        barStyle: {
            type: Object
        },
        showInput: {
            type: Boolean,
            default: false
        },
        theInputValue: {
            type: String,
            default: ""
        }
    },
    computed: {},
    data() {
        return {
            sBHeight: 40, //状态栏高度
            nBHeight: 88, //导航栏高度
            isApp: true,
            pageName: "",
            IOS: false
        };
    },
    created() {
        this.pageName = weex.config.title;
        if (this.isAndroid()) {
            var self = this;
            if (weex.config.tag) {
                weex.requireModule("globalEvent").addEventListener(
                    "android_keyboard_back_" + weex.config.tag,
                    event => {
                        self.leftButtonClicked();
                    }
                );
            }
        } else if (this.isIOS()) {
            this.IOS = true;
        } else {
            var reg = new RegExp("(^|&)" + "title" + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) {
                this.pageName = decodeURI(r[2]);
            }
        }
        this.sBHeight = this.statusBarHeight();
        this.nBHeight = this.navigationBarHeight();

        // 添加通知(目的为了点击历史记录，软键盘隐藏)
        const that = this;
        const inputKeyboardChannel = new BroadcastChannel(
            "inputKeyboardDisappear"
        );
        inputKeyboardChannel.onmessage = function(event) {
            console.log("通道名称：", event.data);
            if (that.showInput) {
                //让输入框失去焦点
                that.$refs["str_input"].blur();
            }
        };
    },
    watch: {
        // //属性监听
        // inputValue (newValue, oldValue){
        //   this.theInputValue = newValue
        // }
    },

    methods: {
        /**
         *  移除Android物理键监听
         */
        removeEventListener() {
            if (WXEnvironment.platform.toLowerCase() === "android") {
                weex.requireModule("globalEvent").removeEventListener(
                    "android_keyboard_back_" + weex.config.tag
                );
            }
        },

        /**
         * 导航栏左侧按钮点击事件
         */
        leftButtonClicked() {
            if (this.useDefaultReturn) {
                if (WXEnvironment.platform.toLowerCase() === "android") {
                    if (WXEnvironment.appName !== "superior") {
                        this.removeEventListener();
                    } else if (weex.config.tag !== 'homepage_index.js'){
                        this.removeEventListener();
                    }
                    
                    weex.requireModule("MyNavigatorModule").pop(
                        { tag: weex.config.tag},
                        event => {}
                    );
                } else {
                    weex.requireModule("navigator").pop({}, event => {});
                }
            }
            this.$emit("wxcMinibarLeftButtonClicked", {});
        },

        /**
         * 导航栏右侧按钮点击事件
         */
        rightButtonClicked(event) {
            const hasRightContent =
                this.rightText ||
                this.rightButton ||
                (this.$slots && this.$slots.right);
            hasRightContent &&
                this.$emit("wxcMinibarRightButtonClicked", event);
            if (this.showInput) {
                //让输入框失去焦点
                this.$refs["str_input"].blur();
            }
        },
        middleButtonClicked() {
            this.$emit("wxcMinibarMiddleButtonClicked", {});
        },
        //andriod键盘弹出隐藏事件,ios调用modal组件会死循环
        keyboardShowOrHide: function(event) {
            this.$emit("wxcMinibarMiddleKeyboardShowOrHide", event);
        },
        /**
         * 状态栏高度
         */
        statusBarHeight() {
            var deviceWidth = WXEnvironment.deviceWidth;
            if (this.isAndroid()) {
                if (WXEnvironment.scale != 2.75) {
                    return 50;
                }
            } else if (this.isIOS()) {
                //iPhone X 系列44pt=>
                if (this.isPhoneX()) {
                    //XR系列 44pt * 2
                    return (44 * WXEnvironment.scale * 750) / deviceWidth;
                } else {
                    //iPhone 及 iPhone * Plus 系列 20pt
                    return (20 * WXEnvironment.scale * 750) / deviceWidth;
                }
            }
            return 0;
        },
        /**
         * 导航栏高度
         */
        navigationBarHeight() {
            var deviceWidth = WXEnvironment.deviceWidth;
            if (this.isAndroid()) {
                return 88;
            } else if (this.isIOS()) {
                return (44 * WXEnvironment.scale * 750) / deviceWidth;
            }
            return 88;
        },
        /**
         * 导航条高度
         */
        navigationHeight() {
            console.log(
                "navigationBarHeight:" +
                    this.navigationBarHeight() +
                    "statusBarHeight" +
                    this.statusBarHeight()
            );
            if (this.isAndroid()) {
                return this.navigationBarHeight();
            } else {
                return this.navigationBarHeight() + this.statusBarHeight();
            }
        },
        isPhoneX() {
            if (WXEnvironment.platform.toLowerCase() != "ios") {
                return false;
            }

            var deviceHeight = WXEnvironment.deviceHeight;
            if (
                deviceHeight == 1792 ||
                deviceHeight == 2688 ||
                deviceHeight == 2436
            ) {
                return true;
            }
            return false;
        },
        isAndroid() {
            return WXEnvironment.platform.toLowerCase() === "android";
        },
        isIOS() {
            return WXEnvironment.platform.toLowerCase() === "ios";
        },
        inputListener(event) {
            this.$emit("wxcMinibarMiddleInputChanged", {
                inputChanged: event.value
            });
        },
        cancelInput: function() {
            this.$emit("wxcMinibarCancelInputClick", {});
            if (this.showInput) {
                //让输入框获得焦点
                this.$refs["str_input"].focus();
            }
        },
        returnKeyClick: function(event) {
            this.$emit("wxcMinibarMiddleInputReturnKeyClick", event);
        }
    },

    /**
     * 移除Android键盘监听事件
     * Navigation.removeEventListener()
     */

    removeEventListener() {
        this.methods.removeEventListener();
    },

    /**
     * 进入到下一个页面
     */
    push: function(option, callback) {
        if (WXEnvironment.platform.toLowerCase() === "web") {
            option.url = option.url + "?title=" + option.title;
            option.url = encodeURI(option.url);
        } else {
            if (option.url) {
                option.url = option.url.replace(".html", ".js");
            }
            if (WXEnvironment.platform.toLowerCase() === "android") {
                return weex
                    .requireModule("MyNavigatorModule")
                    .push(option, callback);
            }
        }
        weex.requireModule("navigator").push(option, callback);
    },

    /**
     * 返回到上一个页面
     */
    pop: function(option, callback) {
        if (WXEnvironment.platform.toLowerCase() === "android") {
            return weex
                .requireModule("MyNavigatorModule")
                .pop(option, callback);
        }
        weex.requireModule("navigator").pop(option, callback);
    },

    /**
     * 顶部导航高度
     */
    navigationHeight() {
        return this.methods.navigationHeight();
    },

    /**
     * 底部导航栏高度
     */
    tabBarHeight() {
        if (this.isAndroid()) {
            if (WXEnvironment.scale == 2.75) {
                return 0;
            }
            return 100;
        } else if (this.isIOS()) {
            var height = 48;
            if (this.isPhoneX()) {
                height += 20;
            }
            height =
                (height * WXEnvironment.scale * 750) /
                WXEnvironment.deviceWidth;
            console.log("tabBarHeight:", height);
            return height;
        }
        return 0;
    },
    /**
     * 屏幕高度
     */
    screenHeight() {
        return (WXEnvironment.deviceHeight * 750) / WXEnvironment.deviceWidth;
    },
    /**
     * 页面可用内容高度:tabPage
     */
    pageHeight: function(tabPage) {
        var height = this.screenHeight() - this.methods.navigationHeight();
        console.log(WXEnvironment);
        if (tabPage) {
            return height - this.tabBarHeight();
        }
        return height;
    },

    /**
     * 设备类型判断
     */
    isAndroid() {
        return this.methods.isAndroid();
    },
    isIOS() {
        return this.methods.isIOS();
    },
    isPhoneX() {
        return this.methods.isPhoneX();
    },
    miniProgram() {
        if (WXEnvironment.platform == "Web") {
            return false;
        }
        if (WXEnvironment.appName != "WeexDemo") {
            return true;
        }
    }
};
</script>

<style scoped>
.wxc-minibar {
    width: 750px;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
}
.left {
    width: 94px;
    padding-left: 30px;
}
.left-button {
    width: 53px;
    height: 46px;
}
.middle-normal {
    flex-direction: row;
    align-items: center;
    background-color: #f5f5f9;
    border-radius: 33px;
    height: 66px;
    width: 615px;
}
.middle-input-bg {
    flex-direction: row;
    align-items: center;
    background-color: #f5f5f9;
    border-radius: 33px;
    height: 66px;
    width: 530px;
}
.middle-title {
    font-size: 28px;
    height: 66px;
    line-height: 66px;
    color: #ffffff;
    padding-left: 20px;
    padding-right: 14px;
    lines: 1;
    flex: 1;
}
.middle-icon {
    width: 29px;
    height: 29px;
    margin-left: 35px;
}
.middle-input {
    font-size: 30px;
    height: 66px;
    width: 400px;
    margin-left: 14px;
    background-color: #f5f5f9;
}
.right {
    width: 94px;
    padding-right: 30px;
    align-items: flex-end;
}
.right-button {
    width: 32px;
    height: 32px;
}
.icon-text {
    font-size: 28px;
    color: #ffffff;
}
</style>