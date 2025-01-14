//
//  FBSelectAssetsPreviewCCell.h
//  FBVideoClip
//
//  Created by amzwin on 2022/3/18.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBSelectAssetsPreviewCCell : UICollectionViewCell
@property(nonatomic, copy) void (^ _Nonnull deleteSeletedImage)(PHAsset* model);

+(NSString*)identifier;
+(CGSize)itemSize;
+(CGSize)itemSizeWidthPading:(CGFloat)padding;

-(void)fillCellContent:(PHAsset*)model;
@end

NS_ASSUME_NONNULL_END
