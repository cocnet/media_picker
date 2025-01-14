//
//  JYUIUtils.m
//  VideoClip
//
//  Created by 杨志豪 on 2019/5/7.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "JYUIUtils.h"
#import "UILabel+JYAlertActionFont.h"
#import "UIAlertController+JYTapGesAlertController.h"
#import "FBVideoCLipHeader.h"
#import "JYColorHex.h"

@implementation JYUIUtils

+ (void)showAlertViewTitle:(NSString *)string message:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(string,nil) message:NSLocalizedString(message,nil) preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    if(![[JYUIUtils getVisibleViewController] isKindOfClass:[UIAlertController class]]){
        [[JYUIUtils getVisibleViewController] presentViewController:alertController animated: YES completion: nil];
    }
}



#pragma mark 有取消、确认按钮的弹框
+ (void)showAlertControllerTwoOptionWithTitle:(NSString *)title
                                      message:(NSString *)message
                                cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler
                                  doneHandler:(void (^ __nullable)(UIAlertAction *action))doneHandler {
    [JYUIUtils showAlertControllerTwoOptionWithTitle:title message:message leftHandler:cancelHandler rightHandler:doneHandler leftString:NSLocalizedString(@"取消",nil) rightString:NSLocalizedString(@"确定",nil)];
}

+ (void)showAlertControllerTwoOptionWithTitle:(NSString *)title
                                      message:(NSString *)message
                                leftHandler:(void (^ __nullable)(UIAlertAction *action))leftHandler
                                  rightHandler:(void (^ __nullable)(UIAlertAction *action))rightHandler
                                   leftString:(NSString *)leftString
                                  rightString:(NSString *)rightString

{
    //控制器
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:[NSString stringWithFormat:@"%@",message] preferredStyle:UIAlertControllerStyleAlert];
    
    //返回和确认按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(leftString,nil) style:UIAlertActionStyleDefault handler:leftHandler];
    [cancelAction setValue:[UIColor colorWithHex:0x999999] forKey:@"titleTextColor"];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(rightString,nil) style:UIAlertActionStyleDefault handler:rightHandler];
    [doneAction setValue:[UIColor colorWithHex:JYColorHexThemeRed] forKey:@"titleTextColor"];
    
    //kvc修改标题和信息样式
    NSMutableAttributedString *hogan1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@",message]];
    [hogan1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, hogan1.length)];
    [hogan1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:7] range:NSMakeRange(0,1)];
    [alertController setValue:hogan1 forKey:@"attributedMessage"];
    NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:title];
    [hogan addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium] range:NSMakeRange(0, hogan.length)];
    [alertController setValue:hogan forKey:@"attributedTitle"];
    [alertController addAction:cancelAction];
    [alertController addAction:doneAction];
    
    if(![[JYUIUtils getVisibleViewController] isKindOfClass:[UIAlertController class]]){
        [[JYUIUtils getVisibleViewController] presentViewController:alertController animated: YES completion: ^{
//            [alertController tapGesAlert];
        }];
    }
}

+ (void)showAlertControllerOneOptionWithTitle:(NSString *)title
                                      message:(NSString *)message
                                  leftHandler:(void (^ __nullable)(UIAlertAction *action))leftHandler
                                   leftString:(NSString *)leftString

{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(leftString,nil) style:UIAlertActionStyleDefault handler:leftHandler];
    [alertController addAction:cancelAction];
    if(![[JYUIUtils getVisibleViewController] isKindOfClass:[UIAlertController class]]){
        [[JYUIUtils getVisibleViewController] presentViewController:alertController animated: YES completion: ^{
//            [alertController tapGesAlert];
        }];
    }
}

+ (UIViewController *) getVisibleViewController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    topController = [JYUIUtils getVisibleViewControllerFrom:topController];
    
    return topController;
}

+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [JYUIUtils getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [JYUIUtils getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [JYUIUtils getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

+ (NSString *)getMinAndSecondTimeStringForSecond:(NSInteger)scond{
    return [NSString stringWithFormat:@"%02d:%02d", scond / 60, scond % 60];
}

+ (CGSize)resultSizeWithMaxSize:(CGSize)maxSize scale:(CGSize)scale {
    if (scale.height <= 0 || scale.width <= 0) {
        return CGSizeZero;
    }
    CGFloat width = maxSize.width;
    CGFloat height = maxSize.height;
    
    if (width / scale.width * scale.height <= height) {
        return CGSizeMake(width, width / scale.width * scale.height);
    } else if (height / scale.height * scale.width <= width) {
        return CGSizeMake(height / scale.height * scale.width, height);
    } else {
        return CGSizeZero;
    }
}

@end
