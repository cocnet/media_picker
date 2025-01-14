//
//  FBFullScreenBottomView.m
//  multi_image_picker
//
//  Created by amzwin on 2022/4/7.
//

#import "FBFullScreenBottomView.h"
#import <Masonry/Masonry.h>
#import "UIView+frame.h"
#import "TZImagePickerController.h"
#import "UIView+frame.h"
#import "UIColor+NvColor.h"
#import "UIView+frame.h"

@implementation FBFullScreenBottomView
{
   
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.bgMaskView = [[UIView alloc] initWithFrame:frame];
        self.bgMaskView .backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTap:)];
        [self.bgMaskView  addGestureRecognizer:tap];
        [self addSubview:self.bgMaskView ];
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [[self class] height])];
//        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1f1f1f"];
        self.contentView.clipsToBounds = YES;
        self.contentView.layer.masksToBounds = YES;
        [self.contentView setBorderWithCornerRadius:8 type:UIViewCornerTypeTop];
        [self addSubview:self.contentView];
//        self.contentView.layer.cornerRadius = 8;
    }
    return self;
}

-(void)bgTap:(id)sender{
    [self hide];
}

+(CGFloat)height{
    return 220;
}

- (void)showInView:(UIView *)inView {
    [self removeFromSuperview];
    [inView addSubview:self];
    [self.bgMaskView setUserInteractionEnabled:NO];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_bottom);
        make.height.mas_equalTo([[self class] height]);
    }];
    [inView layoutIfNeeded];
    
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_bottom).offset(-[[self class] height]);
        make.height.mas_equalTo([[self class] height]);
    }];
    self.bgMaskView.alpha = 0;
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:15 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [inView layoutIfNeeded];
        self.bgMaskView.alpha = 1;
    } completion:^(BOOL finished) {
        [self.bgMaskView setUserInteractionEnabled:YES];
    }];
}

- (void)hide {
    if (self.superview == nil) {
        return;
    }
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.mas_bottom);
        make.height.mas_equalTo([[self class] height]);
    }];
    self.bgMaskView.alpha = 1;
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:15 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.superview layoutIfNeeded];
        self.bgMaskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    if(self.didHide){
        self.didHide();
    }
}
@end
