//
//  FBFuncationBottomView.h
//  multi_image_picker
//
//  Created by 杨志豪 on 4/26/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBFuncationBottomView : UIView

+ (FBFuncationBottomView *)showWithTitle:(NSString *)title;

+ (FBFuncationBottomView *)showWithTwoTitlesLeftTitle:(NSString *)left rightTitle:(NSString *)right;

@property (nonatomic) void(^sureAction)(void);

@property (nonatomic) void(^cancelAction)(void);

@property (nonatomic) void(^leftTitleAction)(void);

@property (nonatomic) void(^rightTitleAction)(void);

-(void)upadteTitle:(NSString*)title;
@end

NS_ASSUME_NONNULL_END
