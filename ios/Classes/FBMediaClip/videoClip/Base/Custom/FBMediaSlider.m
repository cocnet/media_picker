//
//  FBMediaSlider.m
//  multi_image_picker
//
//  Created by amzwin on 2022/4/8.
//

#import "FBMediaSlider.h"
#import <Masonry/Masonry.h>
#import "UIView+frame.h"
#import "UIColor+NvColor.h"
#import "TZImagePickerController.h"



@interface FBMediaSlider()
@property(nonatomic,strong) UIView *defFlagView;
@end

@implementation FBMediaSlider

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.maxValue = 1.0;
        self.minValue = 0.f;
        [self addSubviews];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.maxValue = 1.0;
        self.minValue = 0.f;
    }
    return self;
}

-(void)setValue:(CGFloat)value{
    _slider.value = value;
}
-(CGFloat)value{
    return _slider.value;
}

-(void)setDefalutValue:(CGFloat)defalutValue{
    _defalutValue = defalutValue;
    _defFlagView.hidden = NO;
    CGFloat l = (1.*_defalutValue / self.maxValue) * (self.width) - 3;// - 2.5;
    [_defFlagView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(l);
    }];
}

/*
 添加子视图
 Add subview
 */

-(UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaleImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

- (void)addSubviews {
    self.slider = [[ASValueTrackingSlider alloc] init];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(sliderValueEnd:) forControlEvents:UIControlEventTouchUpOutside];
    [self.slider setThumbImage:[UIImage tz_imageNamedFromMyBundle:@"slider_thumb_btn"] forState:UIControlStateNormal];
    [self.slider setMinimumTrackImage:nil forState:UIControlStateNormal];
    [self.slider setMaximumValue:self.maxValue];
    [self.slider setMinimumValue:self.minValue];
    self.slider.minimumTrackTintColor = [UIColor whiteColor];
    self.slider.maximumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#434343"];
    self.slider.dataSource = self;
    self.slider.popUpViewCornerRadius = 0;
    [self.slider setMaxFractionDigitsDisplayed:0];
    self.slider.popUpViewArrowLength = 0;
    self.slider.popUpViewColor = [UIColor clearColor];
    self.slider.font = [UIFont systemFontOfSize:12];
    self.slider.textColor = [UIColor whiteColor];
    [self addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(30);
    }];
    
    self.defFlagView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
    self.defFlagView.layer.masksToBounds = YES;
    self.defFlagView.layer.cornerRadius = 3;
    self.defFlagView.backgroundColor = [UIColor whiteColor];
    self.defFlagView.hidden=YES;
    [self addSubview:self.defFlagView];
    [self.defFlagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(self.slider.mas_centerY).offset(0);
        make.size.mas_equalTo(CGSizeMake(6, 6));
    }];
}


- (void)setMaxValue:(CGFloat)maxValue {
    _maxValue = maxValue;
    _slider.maximumValue = _maxValue;
}

- (void)setMinValue:(CGFloat)minValue {
    _minValue = minValue;
    _slider.minimumValue = minValue;
}
#pragma mark - 滑动回调
/*
 滑动回调
 Sliding callback
 
 @param paramSender 当前滑杆 Current slider
 
 */
-(void)sliderValueChanged:(UISlider *)paramSender{
    if(self.sliderValueChanged){
        self.sliderValueChanged(self.slider);
    }
}

#pragma mark - 滑动结束回调
/*
 滑动结束回调
 Sliding end callback
 
 @param paramSender 当前滑杆 Current slider
 
 */
-(void)sliderValueEnd:(UISlider *)paramSender{
    if(self.sliderValueEnd){
        self.sliderValueEnd(self.slider);
    }
}


- (NSString *)slider:(ASValueTrackingSlider *)slider stringForValue:(float)value{
    CGFloat s = 100/(slider.maximumValue-slider.minimumValue);
    return  [NSString stringWithFormat:@"%.f",slider.value*s];
}
@end
