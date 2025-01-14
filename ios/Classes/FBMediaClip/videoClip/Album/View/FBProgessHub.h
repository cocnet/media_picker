//
//  FBProgessHub.h
//  multi_image_picker
//
//  Created by amzwin on 2022/3/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBProgessHub : NSObject
//显示加载进度
-(void)showProgressHubInView:(UIView*)view;
-(void)updateProgressHUB:(CGFloat)progress;
-(void)hideHUB;

//显示菊花+提示文字
-(void)showLoadingInView:(UIView*)view msg:(NSString*)msg;

//白色背景
-(void)showWhiteLoadingInView:(UIView*)view msg:(NSString*)msg;
@end

NS_ASSUME_NONNULL_END
