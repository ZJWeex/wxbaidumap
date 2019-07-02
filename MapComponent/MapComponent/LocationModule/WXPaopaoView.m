//
//  WXPaopaoView.m
//  Superior
//
//  Created by ZZJ on 2019/5/29.
//  Copyright © 2019 淘菜猫. All rights reserved.
//

#import "WXPaopaoView.h"
#define kPortraitMargin     5
#define kPortraitWidth      50
#define kPortraitHeight     50
#define kTitleWidth         150
#define kTitleHeight        20
#define kArrorHeight 10

@interface WXPaopaoView ()
@property (nonatomic, strong) UIImageView *portraitView;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@end
@implementation WXPaopaoView

#pragma mark - draw rect

- (void)drawRect:(CGRect)rect
{
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

- (void)drawInContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
}
- (void)getDrawPath:(CGContextRef)context
{
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    // 添加图片，即商户图
    self.portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(kPortraitMargin, kPortraitMargin, kPortraitWidth, kPortraitHeight)];
    self.portraitView.contentMode = UIViewContentModeScaleAspectFill;
    self.portraitView.layer.masksToBounds = YES;
    self.portraitView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.portraitView];
    
    // 添加标题，即商户名
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin * 2 + kPortraitWidth, kPortraitMargin, kTitleWidth, kTitleHeight)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.text = self.title;
    [self addSubview:self.titleLabel];
    
    // 添加副标题，即商户地址
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin * 2 + kPortraitWidth, kPortraitMargin * 2 + kTitleHeight, kTitleWidth, kTitleHeight)];
    self.subtitleLabel.font = [UIFont systemFontOfSize:12];
    self.subtitleLabel.textColor = [UIColor lightGrayColor];
    self.subtitleLabel.text = self.subtitle;
    [self addSubview:self.subtitleLabel];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (!self.portraitView.image) {
        self.portraitView.frame = CGRectMake(kPortraitMargin, kPortraitMargin, 0, 0);
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.portraitView.frame), self.portraitView.frame.origin.y, [self getPaopaoWidth], kTitleHeight);
        
        self.subtitleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, kPortraitMargin * 2 + kTitleHeight, CGRectGetWidth(self.titleLabel.frame), kTitleHeight);
    }
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle
{
    self.subtitleLabel.text = subtitle;
}

- (void)setImage:(UIImage *)image
{
    self.portraitView.image = image;
}

-(CGFloat)getPaopaoWidth{
    CGRect rect = [self.subtitleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, kTitleHeight) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:self.subtitleLabel.font} context:nil];
    
    CGFloat width = rect.size.width<kTitleWidth?rect.size.width:kTitleWidth;
    if (self.portraitView.image) {
        return width+kPortraitMargin * 3 + kPortraitWidth;
    }else{
        return width+kPortraitMargin * 2;
    }
    
}

@end
