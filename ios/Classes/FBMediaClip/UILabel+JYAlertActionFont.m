//
//  UILabel+JYAlertActionFont.m
//  VideoClip
//
//  Created by 杨志豪 on 2019/7/2.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import "UILabel+JYAlertActionFont.h"

@implementation UILabel (JYAlertActionFont)


- (void)setAppearanceFont:(UIFont *)appearanceFont
{
    if(appearanceFont)
    {
        [self setFont:appearanceFont];
    }
}

- (UIFont *)appearanceFont
{
    return self.font;
}

@end
