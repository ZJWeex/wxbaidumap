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
                    <text
                        v-if="leftText"
                        class="icon-text"
                        :style="{ color: textColor }"
                    >{{leftText}}</text>
                </slot>
            </div>
            <slot name="middle">
                <text v-if="title" class="middle-title" :style="{ color: textColor }">{{title}}</text>
                <text
                    v-else-if="pageName"
                    class="middle-title"
                    :style="{ color: textColor }"
                >{{pageName}}</text>
            </slot>
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
                        :style="{ color: textColor }"
                    >{{rightText}}</text>
                </slot>
            </div>
        </div>
        <div v-if="breakLineColor != ''" :style="{ backgroundColor: breakLineColor, height: 0.8 }"></div>
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
        leftButton: {
            type: String,
            default: "/web/assets/imgs/sup_setting_supermarkets_fh.png"
        },
        textColor: {
            type: String,
            default: "#ff0033"
        },
        rightButton: {
            type: String,
            default: ""
        },
        title: {
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
                    if (WXEnvironment.appName == "superior"){
                        if (weex.config.tag !== 'shopping_index.js' && weex.config.tag !== 'brandstory_index.js'){
                            this.removeEventListener();                            
                        } 
                    } else {
                        this.removeEventListener();
                    }
                    weex.requireModule("MyNavigatorModule").pop(
                        { tag: weex.config.tag },
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
        rightButtonClicked() {
            const hasRightContent =
                this.rightText ||
                this.rightButton ||
                (this.$slots && this.$slots.right);
            hasRightContent && this.$emit("wxcMinibarRightButtonClicked", {});
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
            return this.navigationBarHeight() + this.statusBarHeight();
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
     * 状态栏高度
     */
    statusBarHeight() {
        return this.methods.statusBarHeight();
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
        if (WXEnvironment.appName != "superior") {
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
    width: 150px;
    padding-left: 32px;
}
.left-button {
    width: 53px;
    height: 46px;
}
.middle-title {
    font-size: 36px;
    color: #ffffff;
    height: 36px;
    line-height: 36px;
    font-weight: bold;
}
.right {
    width: 150px;
    padding-right: 32px;
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