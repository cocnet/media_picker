//
//  JYCommonProgressView.m
//  VideoClip
//
//  Created by 杨志豪 on 2019/5/7.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "JYCommonProgressView.h"
#import "FBVideoCLipHeader.h"

@interface JYCommonProgressView()
@property (weak, nonatomic) IBOutlet UIButton *blackButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtoneightConstraint;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic,strong) CAShapeLayer *progressLayer;

@property (weak, nonatomic) IBOutlet UIView *mainColorView;
@property (weak, nonatomic) IBOutlet UIView *grayColorView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainColorViewWidthConstraint;

@property (nonatomic,assign) BOOL hasShow;

@end

@implementation JYCommonProgressView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.mainColorView.layer.masksToBounds = YES;
    self.mainColorView.layer.cornerRadius = 4;
    self.grayColorView.layer.masksToBounds = YES;
    self.grayColorView.layer.cornerRadius = 4;
    self.mainView.layer.masksToBounds = YES;
    self.mainView.layer.cornerRadius = 5;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = NSLocalizedString(@"正在剪切音频", nil);
    [self.cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];

}

- (IBAction)cancelButtonAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressViewCancel)]){
        [self.delegate progressViewCancel];
    }
    [self dissmiss];
}


- (void)showTitle:(NSString *)title progress:(float)progress{
    self.progressView.tintColor = [UIColor colorWithHex:JYColorHexThemeRed];
    if (!self.hasShow){
        self.hasShow = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        if (self.hiddenCancelButton){
            self.cancelButton.hidden = YES;
            self.cancelButtoneightConstraint.constant = 20;
            [self layoutIfNeeded];
        } else {
            self.cancelButtoneightConstraint.constant = 40;
        }
    }
    [self layoutIfNeeded];
    [self.cancelButton setTitleColor:[UIColor colorWithHex:JYColorHexThemeRed] forState:UIControlStateNormal];
    self.titleLabel.text = title;
    [self changeProgress:progress];
}

- (void)changeProgress:(float)progress{
    self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",progress * 100];
    self.mainColorViewWidthConstraint.constant = 248 * progress;
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
    }];
   
}

- (void)dissmiss{
    self.hasShow = NO;
    [self removeFromSuperview];
}

@end
