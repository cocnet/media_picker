//
//  JYBaseModel.h
//  VideoClip
//
//  Created by yzhon 2019/4/11.
//  Copyright © 2019 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadStatus.h"
#import "FBBaseModel.h"

@interface JYBaseModel : FBBaseModel

@property (nonatomic, assign) BOOL selected;  //选中、未选中
@property (nonatomic, strong) NSString *coverName;//图片名
@property (nonatomic, strong) NSString *coverDefault;//默认图片名，如果网络请求图片没有显示出来，用这个代替
@property (nonatomic, strong) NSString *displayName;//界面显示名
@property (nonatomic, strong) NSString *displayNameEN;//界面显示名
@property (nonatomic, strong) NSString *builtinName;//如果是内嵌特效，需要设置内嵌名
@property (nonatomic, strong) NSString *packageId;//如果是特效包，需要设置包裹id
@property (nonatomic, strong) NSString *size; //包裹大小
@property (nonatomic, strong) NSString *draw; //支持的画幅比例、道具类型
@property (nonatomic, assign) DownloadState state;//包裹当前状态
@property (nonatomic, assign) NSInteger categoryId;//如果素材有分类，设置不同的值。如粒子会有人脸、手势、全屏、触摸4中分类

@end

