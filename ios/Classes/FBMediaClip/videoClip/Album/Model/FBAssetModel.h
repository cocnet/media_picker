//
//  FBAssetModel.h
//  multi_image_picker
//
//  Created by amzwin on 2022/8/2.
//

#import "FBBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FBAssetModel : FBBaseModel


////原图地址
@property(nonatomic,strong) NSString *originPath;
////缩略图地址
@property(nonatomic,strong) NSString *thumbPagh;
////送审图地址
@property(nonatomic,strong) NSString *checkPath;
////资源高度
@property(nonatomic,assign) CGFloat height;
////资源宽度
@property(nonatomic,assign) CGFloat width;
////资源时长
@property(nonatomic,assign) CGFloat duration;
////草稿的id
@property(nonatomic,strong) NSString *uuid;
////是否是图片
@property(nonatomic,assign) BOOL isImageType;
////名称
@property(nonatomic,strong) NSString *name;
@end

NS_ASSUME_NONNULL_END
