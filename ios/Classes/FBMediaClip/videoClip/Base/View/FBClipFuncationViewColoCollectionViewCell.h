//
//  FBClipFuncationViewColoCollectionViewCell.h
//  multi_image_picker
//
//  Created by 杨志豪 on 4/21/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBClipFuncationViewColoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;


@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIView *dissableView;
- (void)setDissable:(BOOL)dissable;

@end

NS_ASSUME_NONNULL_END
