//
//  UIView+frame.m
//  TYMhouse
//
//  Created by yzh on 15/7/19.
//  Copyright (c) 2015年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UIViewCornerTypeLeft,     //左边
    UIViewCornerTypeRight,     //右边
    UIViewCornerTypeTop,      //上边
    UIViewCornerTypeBottom,   //底部
    UIViewCornerTypeAll,      //
} UIViewCornerType;

@interface UIView (frame)

@property (assign, nonatomic) CGFloat width;

@property (assign, nonatomic) CGFloat height;

@property (assign, nonatomic) CGFloat x;

@property (assign, nonatomic) CGFloat y;

@property (assign, nonatomic) CGFloat centerX;

@property (assign, nonatomic) CGFloat centerY;

/**
 *  从与view同名的Xib中加载view
 */
+ (instancetype)viewFromXib;

/**
 *  获取当前控制器
 *
 *  @return 返回当前视图所在的控制器
 */
- (UIViewController*)viewController;


- (void)increaseAnimationWithString:(NSString *)string withColor:(UIColor *)color;
- (void)decreaseAnimationWithString:(NSString *)string withColor:(UIColor *)color;

-(void)addTapPressed:(SEL)tapViewPressed target:(id)target;
-(UIViewController *)findViewController;

-(void)shwoOnlyWordToast:(NSString*)tips;
-(void)shwoOnlyWordToast:(NSString*)tips inView:(UIView*)inView;
/*
 * 绘制圆角
 *@param cornerRadius 圆半径
 *@param type
 */
-(void)setBorderWithCornerRadius:(CGFloat)cornerRadius type:(UIViewCornerType)type;

- (void)setBorderWithCornerRadius:(CGFloat)cornerRadius corners:(UIRectCorner)corners;

- (void)setBorderWithCornerRadius:(CGFloat)cornerRadius
                      borderWidth:(CGFloat)borderWidth
                      borderColor:(UIColor *)borderColor
                             type:(UIRectCorner)corners;

@end
