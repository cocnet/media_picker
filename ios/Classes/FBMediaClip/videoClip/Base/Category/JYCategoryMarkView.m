//
//  JYCategoryMarkView.m
//  VideoClip
//
//  Created by yzh on 2019/12/17.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import "JYCategoryMarkView.h"

@implementation JYCategoryMarkView

- (void)initializeData {
    [super initializeData];

    self.relativePosition = JYCategoryMarkRelativePosition_TopRight;
    self.markOffset = CGPointMake(5, -5);
}

- (Class)preferredCellClass {
    return [JYCategoryMarkCell class];
}

- (void)refreshDataSource {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < self.titles.count; i++) {
        JYCategoryMarkCellModel *cellModel = [[JYCategoryMarkCellModel alloc] init];
        [tempArray addObject:cellModel];
    }
    self.dataSource = tempArray;
}

- (void)refreshCellModel:(JXCategoryBaseCellModel *)cellModel index:(NSInteger)index {
    [super refreshCellModel:cellModel index:index];

    JYCategoryMarkCellModel *myCellModel = (JYCategoryMarkCellModel *)cellModel;
    myCellModel.isMarkHidden = [self.markStates[index] boolValue];
    myCellModel.relativePosition = self.relativePosition;
    myCellModel.markImage = self.markImage;
    myCellModel.markOffset = self.markOffset;
}

@end
