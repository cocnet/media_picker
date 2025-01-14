//
//  JYCommonProgressView.h
//  VideoClip
//
//  Created by 杨志豪 on 2019/5/7.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JYCommonProgressViewDelegate <NSObject>

@optional
- (void)progressViewCancel;

@end

@interface JYCommonProgressView : UIView

@property (nonatomic,weak) id<JYCommonProgressViewDelegate>delegate;
@property (nonatomic,assign) BOOL hiddenCancelButton;

- (void)showTitle:(NSString *)title progress:(float)progress;

- (void)changeProgress:(float)progress;

- (void)dissmiss;

@end

NS_ASSUME_NONNULL_END
