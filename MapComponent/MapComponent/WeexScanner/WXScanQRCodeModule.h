//
//  WXScanQRCodeModule.h
//  TCMBuyer
//
//  Created by ZZJ on 2019/7/18.
//  Copyright © 2019 Taocaimall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WeexSDK/WeexSDK.h>

NS_ASSUME_NONNULL_BEGIN
@protocol TCMScanQRCodeControllerDelegate <NSObject>
-(void)scanQRCodeController:(UIViewController*)vc byMessage:(NSString*)message;
@end

@interface TCMScanQRCodeController : UIViewController

@property(nonatomic,weak)id <TCMScanQRCodeControllerDelegate>delegate;

@end

@interface WXScanQRCodeModule : NSObject <WXModuleProtocol>

@end

NS_ASSUME_NONNULL_END
