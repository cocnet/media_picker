 //
//  UIView+frame.m
//  TYMhouse
//
//  Created by yzh on 15/7/19.
//  Copyright (c) 2015年 yzh. All rights reserved.
//

#import "UIView+frame.h"
#import "NSBundle+TZImagePicker.h"
#import <Toast/Toast.h>

static UILabel *_label;

@implementation UIView (frame)

/** 获取控件宽度 */
- (CGFloat)width
{
    return self.frame.size.width;
}

/**
 *  设置控件的宽度
 */
- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

/** 获取控件高度 */
- (CGFloat)height
{
    return self.frame.size.height;
}


/**
 *  设置控件的高度
 */
- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

/** 获取控件X值 */
- (CGFloat)x
{
    return self.frame.origin.x;
}
/**
 *  设置控件的X
 */
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

/** 获取控件Y值 */
- (CGFloat)y
{
    return self.frame.origin.y;
}

/**
 *  设置控件的Y值
 */
- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

/** 获取控件中心点X值 */
- (CGFloat)centerX
{
    return self.center.x;
}
/**
 *  设置控件中心点的X
 */
- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

/** 获取控件中心点Y值 */
- (CGFloat)centerY
{
    return self.center.y;
}
/**
 *  设置控件中心点的X
 */
- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}


+ (instancetype)viewFromXib
{
    return [[[NSBundle tz_imagePickerBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}


- (void)increaseAnimationWithString:(NSString *)string withColor:(UIColor *)color
{
    _label = [self creatLabel];
    _label.textColor =  color ? color : [UIColor greenColor];
    _label.text = [NSString stringWithFormat:@"+ %@",string];
    [_label sizeToFit];
    _label.center = self.center;
    if (string.integerValue == 0) {
        return;
    }
    [self animationWithView:_label];
}

- (void)decreaseAnimationWithString:(NSString *)string withColor:(UIColor *)color
{
    _label = [self creatLabel];
    _label.textColor =  color ? color : [UIColor redColor];
    _label.text = [NSString stringWithFormat:@"- %@",string];
    [_label sizeToFit];
    _label.center = self.center;
    if (string.integerValue == 0) {
        return;
    }
    [self animationWithView:_label];
}

- (UILabel *)creatLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15.0];
    _label = label;
    [self.superview   addSubview:_label];
    _label.hidden = YES;
    return _label;
}

- (void)animationWithView:(UIView *)view
{
    view.hidden = NO;
    view.alpha = 1.0;
    __block typeof(UIView *)weakView = view;
    [UIView animateWithDuration:1 animations:^{
        view.y -= 15;
        view.alpha = 0;
    } completion:^(BOOL finished) {
        view.hidden = YES;
        [view removeFromSuperview];
        weakView = nil;
    }];
}


-(void)addTapPressed:(SEL)tapViewPressed target:(id)target{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:tapViewPressed];
    [self addGestureRecognizer:tap];
}
- (UIViewController *)findViewController{
    for (UIView* next = self; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

-(void)shwoOnlyWordToast:(NSString*)tips{
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor whiteColor];
    style.titleFont = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    style.backgroundColor = [UIColor clearColor];
    style.displayShadow = YES;
    style.shadowOffset = CGSizeMake(0, 2);
    style.shadowOpacity = 0.8;
    [[self findViewController].view hideAllToasts];
//    [[self findViewController].view makeToast:tips
//                                     duration:1.0
//                                     position:CSToastPositionCenter style:style];
    
    [[self findViewController].view makeToast:tips
                                     duration:1.0
                                     position:[NSValue valueWithCGPoint:CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, 160)] style:style];
}

-(void)shwoOnlyWordToast:(NSString*)tips inView:(UIView*)inView{
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor whiteColor];
    style.titleFont = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    style.backgroundColor = [UIColor clearColor];
    style.displayShadow = YES;
    style.shadowOffset = CGSizeMake(0, 2);
    style.shadowOpacity = 0.8;
    [[self findViewController].view hideAllToasts];
    [inView makeToast:tips
                                     duration:1.0
                                     position:CSToastPositionCenter style:style];
}


#pragma mark 绘制圆角
-(void)setBorderWithCornerRadius:(CGFloat)cornerRadius type:(UIViewCornerType)type{
    UIRectCorner corners;
    if (type == UIViewCornerTypeLeft) {
        corners = UIRectCornerTopLeft | UIRectCornerBottomLeft;
    }else if (type == UIViewCornerTypeRight) {
        corners = UIRectCornerTopRight | UIRectCornerBottomRight;
    }else if (type == UIViewCornerTypeTop) {
        corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    }else if (type == UIViewCornerTypeBottom){
        corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    }else{
        corners = UIRectCornerAllCorners;
    }
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setBorderWithCornerRadius:(CGFloat)cornerRadius corners:(UIRectCorner)corners {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}


- (void)setBorderWithCornerRadius:(CGFloat)cornerRadius
                      borderWidth:(CGFloat)borderWidth
                      borderColor:(UIColor *)borderColor
                             type:(UIRectCorner)corners {
     
    //    UIRectCorner type = UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft;
     
    //1. 加一个layer 显示形状
    CGRect rect = CGRectMake(borderWidth/2.0, borderWidth/2.0,
                             CGRectGetWidth(self.frame)-borderWidth, CGRectGetHeight(self.frame)-borderWidth);
    CGSize radii = CGSizeMake(cornerRadius, borderWidth);
     
    //create path
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
     
    //create shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = borderColor.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
     
    shapeLayer.lineWidth = borderWidth;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.path = path.CGPath;
     
    [self.layer addSublayer:shapeLayer];
     
     
     
     
    //2. 加一个layer 按形状 把外面的减去
    CGRect clipRect = CGRectMake(0, 0,
                                 CGRectGetWidth(self.frame)-1, CGRectGetHeight(self.frame)-1);
    CGSize clipRadii = CGSizeMake(cornerRadius, borderWidth);
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:clipRect byRoundingCorners:corners cornerRadii:clipRadii];
     
    CAShapeLayer *clipLayer = [CAShapeLayer layer];
    clipLayer.strokeColor = borderColor.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
 
    clipLayer.lineWidth = 1;
    clipLayer.lineJoin = kCALineJoinRound;
    clipLayer.lineCap = kCALineCapRound;
    clipLayer.path = clipPath.CGPath;
 
    self.layer.mask = clipLayer;
}
@end
