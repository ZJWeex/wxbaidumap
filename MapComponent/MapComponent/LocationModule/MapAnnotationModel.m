//
//  MapAnnotationModel.m
//  Superior
//
//  Created by ZZJ on 2019/5/30.
//  Copyright © 2019 淘菜猫. All rights reserved.
//

#import "MapAnnotationModel.h"


//静态街景图
#define StreetImg(ak,bundleIdentifier,lng,lat) [NSString stringWithFormat:@"http://api.map.baidu.com/panorama/v2?ak=%@&mcode=%@&width=256&height=256&location=%@,%@&fov=180",ak,bundleIdentifier,lng,lat] //经度，纬度
@interface MapAnnotationModel ()
@property(nonatomic,strong)NSDictionary *rawData;
@end

@implementation MapAnnotationModel

+(instancetype)modelWithDictionary:(NSDictionary*)dict{
    MapAnnotationModel *model = [MapAnnotationModel mj_objectWithKeyValues:dict];
    model.rawData = dict;
    //设置默认值
    if (!model.pointType) {
        model.pointType = @"0";
    }
    if (!model.canShowCallout) {
        model.canShowCallout = @"false";
    }
    if (!model.image) {
        model.image = @"location_marker";
    }
    if (!model.paopaoType) {
        model.paopaoType = @"0";
    }
    //字符串文字类型转换
    if ([model.pinColor containsString:@"green"]) {
        model.pinColorType = BMKPinAnnotationColorGreen;
    }else if ([model.pinColor containsString:@"purple"]){
        model.pinColorType = BMKPinAnnotationColorPurple;
    }else{
        model.pinColorType = BMKPinAnnotationColorRed;
    }
    
    return model;
}

+(UIImage*)mergeFromImage:(UIImage*)fromImg toImage:(UIImage*)toImg{
    if (!fromImg || !toImg) {
        return nil;
    }
    UIImage *circleImage = [self drawCircleImage:fromImg];
    //以底部图片大小为画布创建上下文
    CGFloat showWidth = toImg.size.width*2.0;
    CGFloat showHight = toImg.size.height*2.0;
    UIGraphicsBeginImageContext(CGSizeMake(showWidth, showHight));
    //先把底部图片 画到上下文中
    [toImg drawInRect:CGRectMake(0, 0, showWidth, showHight)];
    //再把上面图片 放在上下文中
    [circleImage drawInRect:CGRectMake(showWidth*0.1, showWidth*0.1, showWidth*0.8, showWidth*0.8)];
    //从当前上下文中获得最终图片
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    //关闭上下文
    UIGraphicsEndImageContext();
    
    return resultImg;
}

+ (UIImage *)drawCircleImage:(UIImage*)inputImage {
    if (inputImage.size.height != inputImage.size.width) {
        inputImage = [self drawSquareImage:inputImage];
    }
    UIGraphicsBeginImageContextWithOptions(inputImage.size, NO, [UIScreen mainScreen].scale);
    
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, inputImage.size.width, inputImage.size.height) cornerRadius:MIN(inputImage.size.width, inputImage.size.height)/2.0] addClip];
    [inputImage drawInRect:CGRectMake(0, 0, inputImage.size.width, inputImage.size.height)];
    
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return output;
}

+(UIImage*)drawSquareImage:(UIImage*)inputImage{
    CGFloat width = inputImage.size.width;
    CGFloat height = inputImage.size.height;
    if (width * height == 0) {
        return inputImage;
    }
    
    float verticalRadio  = MIN(width,height) * 1.0 / height;
    float horizontalRadio = MIN(width,height) * 1.0 / width;
    
    float radio =1;
    if (verticalRadio <1 || horizontalRadio <1) {
        radio = MIN(verticalRadio, horizontalRadio);
    }
    
    width = width * radio;
    height = height * radio;
    
    CGColorSpaceRef colorSpaceDeviceRGBRef = CGColorSpaceCreateDeviceRGB();
    if (!colorSpaceDeviceRGBRef) {
        return inputImage;
    }
    
    CGImageRef imageRef = inputImage.CGImage;
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    // BGRA8888 (premultiplied) or BGRX8888
    // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpaceDeviceRGBRef, bitmapInfo);
    CGColorSpaceRelease(colorSpaceDeviceRGBRef);
    if (!context) return nil;
    
    CGContextDrawImage(context,CGRectMake(0,0, width, height), imageRef);// decode
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    CGContextRelease(context);
    return newImage;
    
}

+(UIImage*)drawSquareImageView:(UIImage*)inputImage{
    CGFloat size = MIN(inputImage.size.width, inputImage.size.height);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    imgView.contentMode = UIViewContentModeCenter;
    imgView.image = inputImage;
    UIGraphicsBeginImageContextWithOptions(imgView.frame.size, YES, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [imgView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark -- 保存截屏
+(int)saveImage:(BMKMapView*)mapView{
    UIImage *resultImage = [mapView takeSnapshot:mapView.frame];
    NSArray  *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
    
    NSString *filePath=[[paths  objectAtIndex:0] stringByAppendingPathComponent:@"mapImg.png"];
    
    BOOL result = [UIImagePNGRepresentation(resultImage) writeToFile:filePath atomically:YES];
    
    return result;
}

#pragma mark -- 请求全景图

+(void)requsetStreetImgWithCoordinate:(CLLocationCoordinate2D)coordinate callBlock:(void(^)(UIImage *image))block{
    NSString *bundleIdentifier = [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey];
    NSString *ak = [TCMLocationManager appKey];
    NSString *lng = [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    
    if (!bundleIdentifier||!ak) {
        block(nil);
    }
    NSString *url = StreetImg(ak,bundleIdentifier,lng,lat);
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //创建request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval = 15;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpURLResponse =(NSHTTPURLResponse*)response;
        if (httpURLResponse.statusCode==200) {
            UIImage *image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image);
            });
        }else{
            if ([NSJSONSerialization isValidJSONObject:data]) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"%@",dict);
            }
            if (error) {
                NSLog(@"全景图加载失败：%@",error);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                block(nil);
            });
        }
        
    }];
    [dataTask resume];
}


@end
