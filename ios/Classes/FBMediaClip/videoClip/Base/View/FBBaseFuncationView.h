//
//  FBBaseFuncationView.h
//  multi_image_picker
//
//  Created by 杨志豪 on 3/21/22.
//

#import <UIKit/UIKit.h>
#import "FBVideoCLipHeader.h"
#import "FBBaseTypeModel.h"

NS_ASSUME_NONNULL_BEGIN


@protocol FBBaseFuncationViewDelegate <NSObject>

- (void)selectType:(FBClipType)type;

@end

@interface FBBaseFuncationView : UIView

@property (nonatomic,weak) id<FBBaseFuncationViewDelegate> delegate;

+(CGFloat)height;
///这里的typeArray要传FBClipType类型
+ (FBBaseFuncationView*) initFactionView:(NSArray<NSNumber*> *)typeArray
                               isEditImg:(BOOL)isEditImg;

@end

NS_ASSUME_NONNULL_END
