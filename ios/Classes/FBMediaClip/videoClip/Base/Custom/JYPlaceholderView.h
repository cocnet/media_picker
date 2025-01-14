//
//  JYPlaceholderView.h
//  VideoClip
//
//  Created by yzh on 2019/4/25.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JYPlaceholderType) {
    JYPlaceholderTypeRingList,
    JYPlaceholderTypeRingMyList,
    JYPlaceholderTypeVideoMyList,
    JYPlaceholderTypeAssetList,
    JYPlaceholderTypeDraftsList, //草稿箱
    JYPlaceholderTypeNoNetworkConnect, //没有网络

};

NS_ASSUME_NONNULL_BEGIN

@interface JYPlaceholderView : UIView

@property (nonatomic, strong) void(^doneBlock)(void);

//忽略头部的高度，不拦截点击事件
@property (nonatomic, assign) CGFloat ignoreHeaderHeight;
//忽略尾部的高度，不拦截点击事件
@property (nonatomic, assign) CGFloat ignoreFooterHeight;

- (instancetype)initWithFrame:(CGRect)frame type:(JYPlaceholderType)type;

@end

NS_ASSUME_NONNULL_END
