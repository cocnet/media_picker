//
//  FBBottomSheetBaseView.m
//  multi_image_picker
//
//  Created by amzwin on 2022/3/23.
//

#import "FBBottomSheetBaseView.h"
#import <Masonry/Masonry.h>
#import "UIView+frame.h"
#import "TZImagePickerController.h"
#import "UIColor+NvColor.h"
#import "FBFuncationBottomView.h"

@implementation FBBottomSheetBaseView
{
  
//    UIButton *closeButton;
//    UIButton *okButton;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1F1F1F"];
//        [self setupBaseUI];
//        [self setupBaseUILayout];
    }
    return self;
}

+(CGFloat)height{
    return 220;
}

//-(void)setIsBottomViewHide:(BOOL)isBottomViewHide{
//    _isBottomViewHide = isBottomViewHide;
//    _bottomView.hidden = isBottomViewHide;
//}

- (void)showInView:(UIView *)inView {
    [self removeFromSuperview];
    [inView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(inView);
        make.top.equalTo(inView.mas_bottom);
        make.height.mas_equalTo([self height]);
    }];
    [inView layoutIfNeeded];
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(inView);
        make.top.equalTo(inView.mas_bottom).offset(-[self height]);
        make.height.mas_equalTo([self height]);
    }];
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:1 initialSpringVelocity:15 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [inView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide {
    if (self.superview == nil) {
        return;
    }
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.superview);
        make.top.equalTo(self.superview.mas_bottom);
        make.height.mas_equalTo([self height]);
    }];
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:1 initialSpringVelocity:15 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)bottomCloseTap{
    if(self.didCloseTap){
        self.didCloseTap();
    }
    [self hide];
}
-(void)bottomConfirmTap{
    if(self.didConfrimTap){
        self.didConfrimTap();
    }
    [self hide];
}
//
//- (void)setupBaseUI {
//    self.bottomView = [[UIView alloc] init];
//    [self addSubview:self.bottomView];
//
//    closeButton = [[UIButton alloc] init];
//    [closeButton setImage:[UIImage tz_imageNamedFromMyBundle:@"common_close"] forState:UIControlStateNormal];
//    [closeButton addTarget:self action:@selector(bottomCloseTap) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomView addSubview:closeButton];
//
//    okButton = [[UIButton alloc] init];
//    [okButton setImage:[UIImage tz_imageNamedFromMyBundle:@"type_done"] forState:UIControlStateNormal];
//    [okButton addTarget:self action:@selector(bottomConfirmTap) forControlEvents:UIControlEventTouchUpInside];
//    [_bottomView addSubview:okButton];
//}
//
//-(void)setupBaseUILayout{
//    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self);
//        make.height.mas_equalTo(44);
//        if (@available(iOS 11.0, *)) {
//            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
//        } else {
//            make.bottom.equalTo(self.mas_bottom);
//        }
//    }];
//
//    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(30, 30));
//        make.centerY.equalTo(_bottomView.mas_centerY);
//        make.left.mas_offset(12);
//    }];
//
//    [okButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(30, 30));
//        make.centerY.equalTo(_bottomView.mas_centerY);
//        make.right.mas_offset(-12);
//    }];
//}
@end
