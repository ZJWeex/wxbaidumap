//
//  WXPointAnnotation.h
//  Superior
//
//  Created by ZZJ on 2019/5/31.
//  Copyright © 2019 淘菜猫. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "MapAnnotationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXPointAnnotation : BMKPointAnnotation

@property(nonatomic,strong)MapAnnotationModel *annotationConfig;

@end

NS_ASSUME_NONNULL_END
