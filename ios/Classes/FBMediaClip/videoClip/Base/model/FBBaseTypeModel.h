//
//  FBBaseTypeModel.h
//  multi_image_picker
//
//  Created by 杨志豪 on 3/21/22.
//

#import <Foundation/Foundation.h>
#import "FBVideoCLipHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBBaseTypeModel : NSObject

@property (nonatomic, strong) NSString *typeImage;//图片名

@property (nonatomic, strong) NSString *typeName;//图片名

@property (nonatomic, assign) FBClipType type;//类型

+ (FBBaseTypeModel *) createForNumber:(NSNumber *)number
                            isEditImg:(BOOL)isEditImg;

@end

NS_ASSUME_NONNULL_END
