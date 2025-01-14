//
//  UIImage+JYCategory.m
//  VideoClip
//
//  Created by fzy on 2019/5/7.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "UIImage+JYCategory.h"

@implementation UIImage (JYCategory)

+ (UIImage *)createImageWithColor:(UIColor *)color {
    return [UIImage createImageWithColor:color width:1];
}

+ (UIImage *)createImageWithColor:(UIColor *)color width:(CGFloat)width {
    CGRect rect = CGRectMake(0.0f, 0.0f, width, width);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage * theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
