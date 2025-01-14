//
//  Toast.m
//  VideoClip
//
//  Created by 刘浩 on 2019/4/24.
//  Copyright © 2019 Ray. All rights reserved.
//
#import "Toast.h"
#import "JYToast.h"
#import <objc/runtime.h>
#import "FBVideoCLipHeader.h"

static JYToast* instance;
@interface JYToast()
@property(nonatomic,strong)UIView *activityContainerView;

@property(nonatomic,strong)UIActivityIndicatorView *indicatorView;

@property(nonatomic,strong)UIView *loadingStrContainerView;
@property(nonatomic,strong)UILabel *loadingLabel;
@property(nonatomic,strong)UIActivityIndicatorView *loadingIndicatorView;

@end
@implementation JYToast
+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [JYToast new];
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        // this is just one of many style options
        style.messageColor = [UIColor colorWithHex:0xFFFFFF];
        style.backgroundColor = [UIColor colorWithHex:0x1F2126];
        // or perhaps you want to use this style for all toasts going forward?
        // just set the shared style and there's no need to provide the style again
        [CSToastManager setSharedStyle:style];
    });
    return instance;
}
-(UIView *)activityContainerView{
    if (_activityContainerView == nil) {
        _activityContainerView = [UIView new];
        _activityContainerView.frame = [UIScreen mainScreen].bounds;
        _activityContainerView.userInteractionEnabled = YES;
        _activityContainerView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.15];
        [_activityContainerView addSubview:self.indicatorView];
        self.indicatorView.frame = CGRectMake(0, 0, 50, 50);
        self.indicatorView.center = CGPointMake(_activityContainerView.frame.size.width/2.0, _activityContainerView.frame.size.height/2.0);
    }
    return _activityContainerView;
}
-(UIActivityIndicatorView *)indicatorView{
    if (_indicatorView == nil) {
        _indicatorView = [UIActivityIndicatorView new];
        CGAffineTransform transform = CGAffineTransformMakeScale(2.7f, 2.7f);
        _indicatorView.transform = transform;
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    return _indicatorView;
}
+(void)show:(NSString *)string {
    [[UIApplication sharedApplication].keyWindow hideAllToasts];
    [self shareInstance];
    NSTimeInterval time = string.length * 0.06 + 0.5;
    time = time>5?5:time;
    [[UIApplication sharedApplication].keyWindow makeToast:string duration:time position:CSToastPositionCenter];
}
+(void)showAnimationActivity{
    JYToast *tost = [JYToast shareInstance];
    [tost.indicatorView startAnimating];
    tost.activityContainerView.userInteractionEnabled = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:tost.activityContainerView];
}
+(void)hideAnimationActivity{
    JYToast *tost = [JYToast shareInstance];
    [tost.indicatorView stopAnimating];
    [tost.activityContainerView removeFromSuperview];
}
+(void)showTouchableAnimationActivity{
    JYToast *tost = [JYToast shareInstance];
    [tost.indicatorView startAnimating];
    tost.activityContainerView.userInteractionEnabled = NO;
    [[UIApplication sharedApplication].keyWindow addSubview:tost.activityContainerView];
}
+(void)hideTouchableAnimationActivity{
    JYToast *tost = [JYToast shareInstance];
    [tost.indicatorView stopAnimating];
    [tost.activityContainerView removeFromSuperview];
}
+(void)showActivity{
    [self shareInstance];
    [[UIApplication sharedApplication].keyWindow makeToastActivity:CSToastPositionCenter];
}
+(void)showActivity:(NSString*)string{
    [self shareInstance];
    [[UIApplication sharedApplication].keyWindow makeToastActivity:CSToastPositionCenter];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * CSToastActivityViewKey      = @"CSToastActivityViewKey";
        UIView *existingActivityView = (UIView *)objc_getAssociatedObject([UIApplication sharedApplication].keyWindow, &CSToastActivityViewKey);
        if (existingActivityView) {
            UILabel *label = [existingActivityView viewWithTag:10234];
            if (label == nil) {
                label = [[UILabel alloc]init];
                label.tag = 10234;
                [existingActivityView addSubview:label];
                label.font = [UIFont systemFontOfSize:13];
                label.textColor = [UIColor blackColor];
            }
            label.text = string;
            CGSize labelSize = [label sizeThatFits:CGSizeMake(1000, 1000)];
            CGFloat width = labelSize.width+40;
            CGFloat height = 130;
            existingActivityView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-width)/2, ([UIScreen mainScreen].bounds.size.height-height)/2, width, height);
            label.frame = CGRectMake(20, height-30, width-40, 15);
        }
    });
}

+(void)hideActivity{
    [self shareInstance];
    [[UIApplication sharedApplication].keyWindow hideToastActivity];
}

-(UIView *)loadingStrContainerView{
    if (_loadingStrContainerView == nil) {
        _loadingStrContainerView = [UIView new];
        _loadingStrContainerView.frame = [UIScreen mainScreen].bounds;
        _loadingStrContainerView.userInteractionEnabled = YES;
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor colorWithHex:0xe5e5e5];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 10;
        [_loadingStrContainerView addSubview:view];
        self.loadingLabel = [UILabel new];
        [view addSubview:self.loadingLabel];
        self.loadingLabel.textColor = [UIColor colorWithHex:0x333333];
        self.loadingLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.loadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(@0);
            make.centerY.mas_equalTo(@0).offset(15);
        }];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(@0);
            make.width.mas_equalTo(self.loadingLabel.mas_width).offset(40);
            make.height.mas_equalTo(self.loadingLabel.mas_height).offset(60);
        }];
        self.loadingIndicatorView = [UIActivityIndicatorView new];
        CGAffineTransform transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        self.loadingIndicatorView.transform = transform;
        self.loadingIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [view addSubview:self.loadingIndicatorView];
        [self.loadingIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(@0);
            make.centerY.mas_equalTo(@0).offset(-15);
        }];
    }
    return _loadingStrContainerView;
}
+(void)showLoadingStr:(NSString *)loadingStr{
    JYToast *tost = [JYToast shareInstance];
    [[UIApplication sharedApplication].keyWindow addSubview:tost.loadingStrContainerView];
    tost.loadingLabel.text = loadingStr;
    [tost.loadingIndicatorView startAnimating];
}
+(void)showRefreshLoadingStr:(NSString*)str{
    JYToast *tost = [JYToast shareInstance];
    if (tost.loadingStrContainerView && tost.loadingIndicatorView.superview) {
        tost.loadingLabel.text = str;
    }
}
+(void)hideLoadingStr{
    JYToast *tost = [JYToast shareInstance];
    [tost.loadingStrContainerView removeFromSuperview];
    [tost.loadingIndicatorView stopAnimating];
}

@end
