//
//  FBVideoPickImageCCell.h
//  multi_image_picker
//
//  Created by amzwin on 2022/3/28.
//

#import <UIKit/UIKit.h>
#import "FBVideoImagesSlice.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBVideoPickImageCCell : UICollectionViewCell
+(NSString*)identifier;
+(CGSize)itemSize;

-(void)fillContentView:(FBVideoImageModel*)image;


@end

NS_ASSUME_NONNULL_END
