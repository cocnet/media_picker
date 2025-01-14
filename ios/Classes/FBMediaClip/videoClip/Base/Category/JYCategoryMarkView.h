//
//  JYCategoryMarkView.h
//  VideoClip
//
//  Created by yzh on 2019/12/17.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import "JXCategoryTitleView.h"
#import "JYCategoryMarkCell.h"
#import "JYCategoryMarkCellModel.h"
#import "JXCategoryIndicatorBackgroundView.h"

@interface JYCategoryMarkView : JXCategoryTitleView

//@[@(布尔值)]数组，控制MARK是否显示
@property (nonatomic, strong) NSArray <NSNumber *> *markStates;
@property (nonatomic) JYCategoryMarkRelativePosition relativePosition;
@property (nonatomic) UIImage *markImage;
@property (nonatomic) CGPoint markOffset;

@end
