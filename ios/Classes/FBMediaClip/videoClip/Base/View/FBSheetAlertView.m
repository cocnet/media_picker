//
//  FBSheetAlertView.m
//  multi_image_picker
//
//  Created by amzwin on 2022/5/12.
//

#import "FBSheetAlertView.h"
#import <Masonry/Masonry.h>
#import "UIView+frame.h"
#import "TZImagePickerController.h"
#import "UIView+frame.h"
#import "UIColor+NvColor.h"
#import <ReactiveObjC/ReactiveObjC.h>
@interface FBSheetAlertView()
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UIButton *okButton;
@property(nonatomic,strong) UIButton *cancelButton;
@property (nonatomic, copy) void(^cancelTap)(void);
@property (nonatomic, copy) void(^confirmTap)(void);
@end

@implementation FBSheetAlertView
+(CGFloat)height{
    return 228-24;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.bgMaskView.backgroundColor =  [UIColor nv_colorWithHexString:@"#000000" alpha:0.55];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = @"";
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor nv_colorWithHexRGB:@"#5C6273"];
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(82);
            make.top.mas_equalTo(self.contentView.mas_top).offset(20);
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.left.mas_equalTo(self.contentView.mas_left).offset(40);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-40);
        }];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 82, [UIScreen mainScreen].bounds.size.width, 0.5)];
        line1.backgroundColor = [UIColor nv_colorWithHexString:@"#8D93A6" alpha:0.1];
        [self.contentView addSubview:line1];
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.5);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(20);
            make.left.right.mas_equalTo(self.contentView);
        }];
        
        
        _okButton = [[UIButton alloc] init];
        [_okButton setTitle:@"" forState:UIControlStateNormal];
        [self.okButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#198CFE"] forState:UIControlStateNormal];
        self.okButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        [self.okButton addTarget:self action:@selector(okTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.okButton];
        [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(52);
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.width.mas_equalTo(self.contentView.mas_width);
            make.top.mas_equalTo(line1.mas_bottom);
        }];
        
        UIView *line2 = [[UIView alloc] init];
        line2.backgroundColor = [UIColor nv_colorWithHexString:@"#F5F6FA" alpha:1];
        [self.contentView addSubview:line2];
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.okButton.mas_bottom);
            make.height.mas_equalTo(8);
        }];
        
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:@"" forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#1F2126"] forState:UIControlStateNormal];
        self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        [self.cancelButton addTarget:self action:@selector(cancelTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.cancelButton];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(52);
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.width.mas_equalTo(self.contentView.mas_width);
            make.top.mas_equalTo(line2.mas_bottom);
        }];
    }
    return self;
}

-(void)cancelTap:(id)sender{
    if(self.cancelTap){
        self.cancelTap();
    }
    [self hide];
}
-(void)okTap:(id)sender{
    if(self.confirmTap){
        self.confirmTap();
    }
    [self hide];
}

+(void)showInView:(UIView*)inView
            title:(NSString*)title
      cancelBtnTitle:(NSString*)cancelTitle
     comfrimBtnTitle:(NSString*)confirmTitle
      cancelCallback:( void(^)(void) )cancelCallback
     confrimCallback:( void(^)(void) )confrimCallback{
    FBSheetAlertView *view = [[FBSheetAlertView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    view.titleLabel.text = title;
    [view.okButton setTitle:confirmTitle forState:UIControlStateNormal];
    [view.cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
    view.confirmTap = confrimCallback;
    view.cancelTap = cancelCallback;
    [view showInView:inView];
}
@end
