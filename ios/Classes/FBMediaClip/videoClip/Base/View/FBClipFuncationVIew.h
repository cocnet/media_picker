//
//  FBClipFuncationVIew.h
//  multi_image_picker
//
//  Created by 杨志豪 on 4/21/22.
//

#import <UIKit/UIKit.h>
#import "FBVideoCLipHeader.h"
#import "FBBaseTypeModel.h"
#import "FBBaseFuncationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBClipFuncationVIew : UIView

@property (nonatomic,weak) id<FBBaseFuncationViewDelegate> delegate;

@property (nonatomic,strong) NSArray<FBBaseTypeModel *> * typeArray;

///这里的typeArray要传FBClipType类型
+ (FBClipFuncationVIew*) initFactionView:(NSArray<NSNumber*> *)typeArray;

-(void)updateDissableArray:(NSArray<NSNumber *> *)dissableArray;

@end

NS_ASSUME_NONNULL_END
