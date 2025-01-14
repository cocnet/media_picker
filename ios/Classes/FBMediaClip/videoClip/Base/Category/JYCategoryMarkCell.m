//
//  JYCategoryMarkCell.m
//  VideoClip
//
//  Created by yzh on 2019/12/17.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import "JYCategoryMarkCell.h"
#import "JYCategoryMarkCellModel.h"

@interface JYCategoryMarkCell ()

@property (nonatomic) UIImageView *markImageView;

@end

@implementation JYCategoryMarkCell

- (void)initializeViews {
    [super initializeViews];

    self.markImageView = [UIImageView new];
    [self.contentView addSubview:self.markImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    JYCategoryMarkCellModel *myCellModel = (JYCategoryMarkCellModel *)self.cellModel;
    self.markImageView.bounds = CGRectMake(0, 0, myCellModel.markImage.size.width, myCellModel.markImage.size.height);
    switch (myCellModel.relativePosition) {
        case JYCategoryMarkRelativePosition_TopLeft:
        {
            self.markImageView.center = CGPointMake(CGRectGetMinX(self.titleLabel.frame) + myCellModel.markOffset.x, CGRectGetMinY(self.titleLabel.frame) + myCellModel.markOffset.y);
        }
            break;
        case JYCategoryMarkRelativePosition_TopRight:
        {
            self.markImageView.center = CGPointMake(CGRectGetMaxX(self.titleLabel.frame) + myCellModel.markOffset.x, CGRectGetMinY(self.titleLabel.frame) + myCellModel.markOffset.y);
        }
            break;
        case JYCategoryMarkRelativePosition_BottomLeft:
        {
            self.markImageView.center = CGPointMake(CGRectGetMinX(self.titleLabel.frame) + myCellModel.markOffset.x, CGRectGetMaxY(self.titleLabel.frame) + myCellModel.markOffset.y);
        }
            break;
        case JYCategoryMarkRelativePosition_BottomRight:
        {
            self.markImageView.center = CGPointMake(CGRectGetMaxX(self.titleLabel.frame) + myCellModel.markOffset.x, CGRectGetMaxY(self.titleLabel.frame) + myCellModel.markOffset.y);
        }
            break;
    }
    [CATransaction commit];
}

- (void)reloadData:(JXCategoryBaseCellModel *)cellModel {
    [super reloadData:cellModel];

    JYCategoryMarkCellModel *myCellModel = (JYCategoryMarkCellModel *)cellModel;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.markImageView.hidden = myCellModel.isMarkHidden;
    self.markImageView.image = myCellModel.markImage;
    [CATransaction commit];

    [self setNeedsLayout];
}

@end
