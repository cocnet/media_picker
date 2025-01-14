//
//  JYViewControllerManager.m
//  VideoClip
//
//  Created by fzy on 2019/5/17.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "JYViewControllerManager.h"

@implementation JYViewControllerManager

+ (UIViewController *)getCurrentVC {
    UIViewController *result = nil;

    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }

    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];

    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;

    return result;
}

+ (UINavigationController *)getCurrentNC {
    UINavigationController * nv = [JYViewControllerManager getCurrentVC];
    if ([nv isKindOfClass:UINavigationController.class]) {
        return nv;
    } else {
        return nv.navigationController;
    }
}

@end
