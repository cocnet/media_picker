//
//  UIImage+JYCategory.h
//  VideoClip
//
//  Created by fzy on 2019/5/7.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (JYCategory)

+ (UIImage *)createImageWithColor:(UIColor *)color;

+ (UIImage *)createImageWithColor:(UIColor *)color width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
