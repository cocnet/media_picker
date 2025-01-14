//
//  FBBottomSheetBaseView.h
//  multi_image_picker
//
//  Created by amzwin on 2022/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBBottomSheetBaseView : UIView
//底部工具栏，包含 关闭 确认 两个按钮
//@property(nonatomic,strong) UIView *bottomView;
//@property(nonatomic,assign) BOOL isBottomViewHide;
@property(nonatomic, copy) void (^ _Nonnull didCloseTap)(void);
@property(nonatomic, copy) void (^ _Nonnull didConfrimTap)(void);

- (void)showInView:(UIView *)inView;
- (void)hide;

//to override
+(CGFloat)height;
//-(void)bottomCloseTap;
//-(void)bottomConfirmTap;
@end

NS_ASSUME_NONNULL_END
