//
//  JYBaseViewController.m
//  VideoClip
//
//  Created by 杨志豪 on 2019/5/28.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "JYBaseViewController.h"
#import "UIColor+NvColor.h"
#import "BaseLineUtil.h"
#import "TZImagePickerController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "Masonry.h"
#import "UIColor+NvColor.h"
@interface JYBaseViewController ()

@end

@implementation JYBaseViewController
{
    UIButton *navFinishButton;
}
- (instancetype)init {
    self = [super init];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor nv_colorWithHexString:@"#141414"];
    [self configBaseCustomNaviBar];
}

-(void)navBackButtonTap{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    TZImagePickerController *tz = (TZImagePickerController*)self.navigationController;
    if(tz.didCancelMediaHandle){
        tz.didCancelMediaHandle();
    }
}

-(void)navFinishTap{
    
}
-(void)updateConfirmEnable:(BOOL)enable{
    [navFinishButton setEnabled:enable];
}

- (void)configBaseCustomNaviBar {
    self.customNavBarView = [[UIView alloc] initWithFrame:CGRectMake(0, [BaseLineUtil baseLineOfStatusBarHeight], [UIScreen mainScreen].bounds.size.width, 44)];
    self.customNavBarView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#141414"];
    [self.view addSubview:self.customNavBarView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setImage:[UIImage tz_imageNamedFromMyBundle:@"nav_back_btn"] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(navBackButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.centerY.mas_equalTo(self.customNavBarView.mas_centerY);
        make.left.mas_equalTo(12);
    }];
    
    navFinishButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 66, 32)];
    [navFinishButton setTitle:@"完成" forState:UIControlStateNormal];
    [navFinishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    navFinishButton.backgroundColor = [UIColor nv_colorWithHexRGB:@"#198CFE"];
    navFinishButton.layer.masksToBounds = YES;
    navFinishButton.layer.cornerRadius = 16;
    navFinishButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [navFinishButton addTarget:self action:@selector(navFinishTap) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addSubview:navFinishButton];
    [navFinishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(66, 32));
        make.centerY.mas_equalTo(self.customNavBarView.mas_centerY);
        make.right.mas_equalTo(-12);
    }];
    
    self.navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    self.navTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.navTitleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.navTitleLabel.textColor = [UIColor whiteColor];
    self.navTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.navTitleLabel.text = @"";
    [self.customNavBarView addSubview:self.navTitleLabel];
    [self.navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.customNavBarView.mas_centerY);
        make.centerX.mas_equalTo(self.customNavBarView.mas_centerX);
    }];
}

-(void)updateNavTitle:(NSString*)title{
    self.navTitleLabel.text = title;
}
-(void)updateNavConfirmTitle:(NSString*)title{
    [navFinishButton setTitle:title forState:UIControlStateNormal];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
//- (UIViewController *)childViewControllerForStatusBarStyle {
//    return self.getTopViewController;
//}
//
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleDarkContent;
////    return [self.topViewController preferredStatusBarStyle];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
