//
//  FBAssetsHandlerProgressView.h
//  FBVideoClip
//
//  Created by amzwin on 2022/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBAssetsHandlerProgressView : UIView
@property(nonatomic,strong) UILabel *label;
@property(nonatomic,strong) UILabel *detailsLabel;

- (void)changeProgressValue:(CGFloat)progress; //[0-1]
@end

NS_ASSUME_NONNULL_END
