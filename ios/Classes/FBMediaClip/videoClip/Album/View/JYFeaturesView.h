//
//  JYFeaturesView.h
//  SDKDemo
//
//  Created by yzhon 2019/3/21.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JYFeaturesViewDelegate <NSObject>

- (void)featuresViewBtnClick:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface JYFeaturesView : UIView

@property (nonatomic, weak) id<JYFeaturesViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
