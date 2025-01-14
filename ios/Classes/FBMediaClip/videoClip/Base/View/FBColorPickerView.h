//
//  FBColorPickerView.h
//  multi_image_picker
//
//  Created by amzwin on 2022/4/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBColorPickerCCell: UICollectionViewCell
+(NSString*)identifier;
+(CGSize)itemSize;

- (void)fillCellContent:(NSString*)colorString isSelected:(BOOL)isSelected;

@end

@interface FBColorPickerView : UIView
@property (nonatomic, copy) void(^colorPicked)(NSString *colorString);
@property(nonatomic,strong)  NSString *curSelectedColor;
- (void)fillViewContent:(NSString*)selColorString;
- (NSString*)updateSelectedIndex:(NSInteger)index;

+(NSArray<NSString*>*)allColors;
@end

NS_ASSUME_NONNULL_END
