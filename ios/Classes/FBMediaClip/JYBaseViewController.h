//
//  JYBaseViewController.h
//  VideoClip
//
//  Created by 杨志豪 on 2019/5/28.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+JYBarItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface JYBaseViewController : UIViewController
@property(nonatomic,strong) UIView *customNavBarView;
@property(nonatomic,strong) UILabel *navTitleLabel;

-(void)navBackButtonTap;
-(void)navFinishTap;
-(void)updateNavTitle:(NSString*)title;
-(void)updateNavConfirmTitle:(NSString*)title;
-(void)updateConfirmEnable:(BOOL)enable;
@end

NS_ASSUME_NONNULL_END
