//
//  Toast.h
//  VideoClip
//
//  Created by 刘浩 on 2019/4/24.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JYToast : NSObject


+(void)show:(NSString*)string;

+(void)showActivity:(NSString*)string;
+(void)showActivity;
+(void)hideActivity;

//影响点击的toast
+(void)showAnimationActivity;
+(void)hideAnimationActivity;

//不影响点击的toast
+(void)showTouchableAnimationActivity;
+(void)hideTouchableAnimationActivity;

+(void)showLoadingStr:(NSString*)loadingStr;
+(void)hideLoadingStr;

@end

NS_ASSUME_NONNULL_END
