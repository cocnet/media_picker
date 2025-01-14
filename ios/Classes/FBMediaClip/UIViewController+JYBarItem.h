//
//  UIViewController+JYBarItem.h
//  VideoClip
//
//  Created by yzh on 2019/4/24.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (JYBarItem)

- (void)configDefaultNavigationBar;

- (void)configLeftBarButtonItemWithTitle:(NSString *)backTitle;

- (void)jy_backClick;

- (UIViewController *)getTopViewController;
@end

NS_ASSUME_NONNULL_END
