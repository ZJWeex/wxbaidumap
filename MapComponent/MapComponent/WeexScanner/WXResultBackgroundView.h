//
//  WXResultBackgroundView.h
//  MapComponent
//
//  Created by ZZJ on 2019/7/1.
//  Copyright © 2019 Jion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN
extern const NSInteger RESULT_BACKGROUND_VIEW_TAG;

extern const NSInteger RESULT_CREATE_VIEW_TAG;


typedef NS_ENUM(NSUInteger, RESULT_LOADING_STATUS) {
    /** 加载中 */
    RESULT_LOADING_STATUS_LOADING,
    /** 网络异常 */
    RESULT_LOADING_STATUS_NETWORK_ERROR,
    /** 加载失败 */
    RESULT_LOADING_STATUS_LOAD_FAILED,
    /** 文件不存在 */
    RESULT_LOADING_STATUS_NO_FILE,
    /** 加载完成 */
    RESULT_LOADING_STATUS_LOAD_FINISH,
    /** 文件解析失败 */
    RESULT_LOADING_STATUS_FILE_EXECUTION_FAILED,
    /** 渲染完成 */
    RESULT_LOADING_STATUS_RENDER_FINISH,
};
@interface WXResultBackgroundView : UIView

@property (nonatomic, weak) UINavigationBar *navigationBar;
@property (nonatomic, weak) UINavigationItem *navigationItem;


@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic,strong) UIBarButtonItem *leftBarButtonItem;
@property (nullable, nonatomic,strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, assign) RESULT_LOADING_STATUS loadingStatus;

+ (instancetype)objectWithHandler:(void(^)(void))handler;
@end

NS_ASSUME_NONNULL_END
