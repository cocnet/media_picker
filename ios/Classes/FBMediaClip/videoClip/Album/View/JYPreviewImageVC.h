//
//  JYPreviewImageVC.h
//  VideoClip
//
//  Created by 杨志豪 on 2019/7/19.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import "JYBaseViewController.h"
#import "TZAssetModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol JYPreviewImageVCDelegate <NSObject>

-(void)passValue:(TZAssetModel *)model withTapIndexPath:(NSIndexPath *)tapIndexPath;

@end

@interface JYPreviewImageVC : JYBaseViewController

@property (nonatomic,strong) TZAssetModel *model;
@property (nonatomic,strong) NSIndexPath *path;

@property (nonatomic,weak) id<JYPreviewImageVCDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
