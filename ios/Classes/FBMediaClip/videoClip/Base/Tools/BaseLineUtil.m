//
//  BaseLineUtil.m
//  VideoClip
//
//  Created by 刘浩 on 2019/4/10.
//  Copyright © 2019 admin. All rights reserved.
//

#import "BaseLineUtil.h"

@implementation BaseLineUtil
//[[UIApplication sharedApplication] statusBarFrame];
+(CGFloat)baseLineOfStatusBarHeight{
    float statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        //顶部状态栏高度（包括安全区）
        //windowScene.statusBarManager.statusBarFrame.size.height;
        //顶部安全区高度
        //UIWindow *window = windowScene.windows.firstObject;
        //double sss = window.safeAreaInsets.top;
        UIStatusBarManager *statusBarManager = windowScene.statusBarManager;
        statusBarHeight = statusBarManager.statusBarFrame.size.height;
        
//        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
//        statusBarHeight = statusBarManager.statusBarFrame.size.height;
    }else {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    return MAX(statusBarHeight, 20);
}


+(CGFloat)baseLineOfBottomSafeHeight{
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }else{
        return 0;
    }
}


@end
