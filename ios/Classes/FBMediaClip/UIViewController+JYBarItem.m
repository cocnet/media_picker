//
//  UIViewController+JYBarItem.m
//  VideoClip
//
//  Created by yzh on 2019/4/24.
//  Copyright © 2019 admin. All rights reserved.
//

#import "UIViewController+JYBarItem.h"
#import "UIImage+JYCategory.h"
#import "TZImagePickerController.h"
#import "UIColor+Hex.h"
#import "UIView+Dimension.h"
#import "JYColorHex.h"

@implementation UIViewController (JYBarItem)

- (void)configDefaultNavigationBar {
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage tz_imageNamedFromMyBundle:@"common_close"] style:UIBarButtonItemStylePlain target:self action:@selector(jy_backClick)];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithHex:JYColorHexBackgroundBlack]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)configLeftBarButtonItemWithTitle:(NSString *)backTitle{
	//返回图标
	UIImageView *backIcon = [[UIImageView alloc] initWithImage:[UIImage tz_imageNamedFromMyBundle:@"common_back"]];
	backIcon.center = CGPointMake(backIcon.width/2, 22);
	
	//返回标题
	UILabel *backTitleLabel = [[UILabel alloc] init];
	backTitleLabel.text = backTitle;
	backTitleLabel.textColor = [UIColor whiteColor];
	backTitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
	backTitleLabel.textAlignment = NSTextAlignmentRight;
	[backTitleLabel sizeToFit];
	backTitleLabel.frame = CGRectMake(CGRectGetMaxX(backIcon.frame) + 20, 0, backTitleLabel.width, 44);
	
	//返回按钮
	UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[backBtn addSubview:backIcon];
	[backBtn addSubview:backTitleLabel];
	backBtn.frame = CGRectMake(0, 0, CGRectGetMaxX(backTitleLabel.frame), 44);
	[backBtn addTarget:self action:@selector(jy_backClick) forControlEvents:UIControlEventTouchUpInside];
	
	self.navigationItem.leftBarButtonItem.customView = backBtn;
}

- (void)jy_backClick {
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    TZImagePickerController *t = (TZImagePickerController*)self.navigationController;
    if(t.didCancelMediaHandle){
        t.didCancelMediaHandle();
    }
}
- (BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}


- (UIViewController *)getTopViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}
@end
