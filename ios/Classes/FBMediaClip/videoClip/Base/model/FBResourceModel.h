//
//  FBResourceModel.h
//  multi_image_picker
//
//  Created by 杨志豪 on 4/28/22.
//

#import <Foundation/Foundation.h>
#import "FBBaseModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface FBMeisheLibModel : FBBaseModel

@property (nonatomic,strong) NSString *url;

@property (nonatomic,strong) NSString *image;

@property (nonatomic,strong) NSString *fileName;

@property (nonatomic,strong) NSString *md5;

@property (nonatomic,strong) NSString *name;

@property (nonatomic,assign) CGFloat strength;
@property (nonatomic,strong) NSString *lic;
@property (nonatomic,strong) NSString *zip;

- (NSString *)getMeisheUdid;
@end


@interface FBResourceModel : NSObject

//贴纸
@property (nonatomic,strong) NSArray<FBMeisheLibModel *> *stickerArray;
//音乐
@property (nonatomic,strong) NSArray<FBMeisheLibModel *> *musicArray;
//字体
@property (nonatomic,strong) NSArray<FBMeisheLibModel *> *fftArray;
//滤镜
@property (nonatomic,strong) NSArray<FBMeisheLibModel *> *filterArray;
//字幕
@property (nonatomic,strong) NSArray<FBMeisheLibModel *> *captionArray;


@end

NS_ASSUME_NONNULL_END
