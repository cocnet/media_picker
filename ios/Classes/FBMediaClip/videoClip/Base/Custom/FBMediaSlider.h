//
//  FBMediaSlider.h
//  multi_image_picker
//
//  Created by amzwin on 2022/4/8.
//

#import <UIKit/UIKit.h>
#import "ASValueTrackingSlider.h"
NS_ASSUME_NONNULL_BEGIN

@interface FBMediaSlider : UIView
@property(nonatomic,copy) void (^ _Nonnull sliderValueChanged)(UISlider *paramSender);
@property(nonatomic,copy) void (^ _Nonnull sliderValueEnd)(UISlider *paramSender);

@property (nonatomic, assign) CGFloat defalutValue;

/// 最大值 Max value
@property (nonatomic, assign) CGFloat maxValue;

/// 最小值 Max value
@property (nonatomic, assign) CGFloat minValue;

/// 当前滑杆 Current slider
@property (nonatomic, strong) ASValueTrackingSlider *slider;

@property(nonatomic,assign) CGFloat value;
@end

NS_ASSUME_NONNULL_END
