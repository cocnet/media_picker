//
//  FBProgessHub.m
//  multi_image_picker
//
//  Created by amzwin on 2022/3/22.
//

#import "FBProgessHub.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "FBAssetsHandlerProgressView.h"
#import "UIColor+NvColor.h"
@interface FBProgessHub()
//@property(nonatomic,strong) FBAssetsHandlerProgressView *centerView;
//@property(nonatomic,strong) MBProgressHUD *hud;
@end

@implementation FBProgessHub
{
    MBProgressHUD *_hud;
    FBAssetsHandlerProgressView *_centerView;
}
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)showProgressHubInView:(UIView*)view{
    [self showProgressHUB:view];
}
-(void)showProgressHUB:(UIView*)view{
    _hud = [MBProgressHUD showHUDAddedTo:view animated:NO];
    _hud.animationType = MBProgressHUDAnimationFade;
    _hud.mode = MBProgressHUDModeCustomView;
    _centerView = [[FBAssetsHandlerProgressView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    _hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    _hud.bezelView.layer.cornerRadius = 8;
    [_centerView changeProgressValue:0];
    _hud.bezelView.backgroundColor = [UIColor clearColor];// [UIColor nv_colorWithHexString:@"#000000" alpha:0.85];
    _centerView.label.font = [UIFont systemFontOfSize:15];
    _centerView.label.text = @"素材处理中";
    _centerView.detailsLabel.font = [UIFont systemFontOfSize:12];
    _centerView.detailsLabel.text = @"请不要退出Fanbook哦";
    _hud.customView = _centerView;
}
-(void)updateProgressHUB:(CGFloat)progress{
    [_centerView changeProgressValue:progress];
}
-(void)hideHUB{
    [_hud hideAnimated:YES];
}

-(void)showLoadingInView:(UIView*)view msg:(NSString*)msg{
    _hud = [MBProgressHUD showHUDAddedTo:view animated:NO];
    _hud.animationType = MBProgressHUDAnimationFade;
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    _hud.bezelView.layer.cornerRadius = 8;
    _hud.bezelView.backgroundColor = [UIColor blackColor];
    _hud.label.text = msg;
}

-(void)showWhiteLoadingInView:(UIView*)view msg:(NSString*)msg{
    _hud = [MBProgressHUD showHUDAddedTo:view animated:NO];
    _hud.animationType = MBProgressHUDAnimationFade;
    _hud.mode = MBProgressHUDModeIndeterminate;
//    _hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//    _hud.bezelView.layer.cornerRadius = 8;
//    _hud.bezelView.backgroundColor = [UIColor whiteColor];
    _hud.label.text = msg;
}
@end
