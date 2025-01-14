//
//  FBFullScreenBottomView.h
//  multi_image_picker
//
//  Created by amzwin on 2022/4/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBFullScreenBottomView : UIView
@property(nonatomic,strong)  UIView *bgMaskView;
@property(nonatomic,strong) UIView *contentToolView;
@property (nonatomic,strong) UIView* contentView;

@property (nonatomic, copy) void(^didHide)(void);

- (void)showInView:(UIView *)inView;
- (void)hide;
@end

NS_ASSUME_NONNULL_END
