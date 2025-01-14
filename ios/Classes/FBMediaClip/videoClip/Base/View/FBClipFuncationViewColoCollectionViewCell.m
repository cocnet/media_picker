//
//  FBClipFuncationViewColoCollectionViewCell.m
//  multi_image_picker
//
//  Created by 杨志豪 on 4/21/22.
//

#import "FBClipFuncationViewColoCollectionViewCell.h"

@implementation FBClipFuncationViewColoCollectionViewCell



- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = 4;
    self.bgView.layer.masksToBounds = YES;
}

- (void)setDissable:(BOOL)dissable {
    self.mainTitleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:dissable ? 0.4 : 1];
    self.mainImageView.alpha = dissable ? 0.4 : 1;
}
@end
