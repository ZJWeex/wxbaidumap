//
//  WXTextAreaComponent.h
//  MapComponent
//
//  Created by ZZJ on 2019/6/27.
//  Copyright © 2019 Jion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXComponent.h"
#import "WXTextComponentProtocol.h"

@interface WXEditComponent : WXComponent<UITextViewDelegate,UITextFieldDelegate>

//attribute
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) NSString *placeholderString;
@property (nonatomic, strong) UILabel *placeHolderLabel;

@end


