//
//  JYCategoryMarkCellModel.h
//  VideoClip
//
//  Created by yzh on 2019/12/17.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import "JXCategoryTitleCellModel.h"

typedef NS_ENUM(NSUInteger, JYCategoryMarkRelativePosition) {
    JYCategoryMarkRelativePosition_TopLeft = 0,
    JYCategoryMarkRelativePosition_TopRight,
    JYCategoryMarkRelativePosition_BottomLeft,
    JYCategoryMarkRelativePosition_BottomRight,
};

@interface JYCategoryMarkCellModel : JXCategoryTitleCellModel

@property (nonatomic) BOOL isMarkHidden;
@property (nonatomic) JYCategoryMarkRelativePosition relativePosition;
@property (nonatomic) UIImage *markImage;
@property (nonatomic) CGPoint markOffset;

@end
