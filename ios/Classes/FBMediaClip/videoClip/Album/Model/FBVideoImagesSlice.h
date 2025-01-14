//
//  FBVideoImagesSlice.h
//  multi_image_picker
//
//  Created by amzwin on 2022/3/28.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface FBVideoImageModel : NSObject
@property(nonatomic,copy) UIImage * _Nullable cropImage;
@property(nonatomic,assign) CMTime actualTime;
@property(nonatomic,assign) BOOL isSelected;
@property(nonatomic,assign) CMTime requestTime;
@property(nonatomic,assign) NSInteger index;

-(FBVideoImageModel*_Nonnull)initWithImage:(UIImage*_Nullable)image actualTime:(CMTime)actualTime;
@end

NS_ASSUME_NONNULL_BEGIN

@interface FBVideoImagesSlice : NSObject
-(instancetype)initWithVideoUrl:(NSURL*)videoUrl;

-(NSTimeInterval)videoDuration;
@property(nonatomic,assign) CGSize videoNaturalSize;
/// 获取某一帧的f视频封面
/// @param ts  时间 ts 单位秒
/// @param complete  cb
-(void)asyncObtainCoverByTs:(NSTimeInterval)ts
                   complete:(void (^)(FBVideoImageModel *vImage))complete;

/// 获取视频可用封面的时间戳 valueWithCMTime
-(NSArray<NSValue*>*)curVideoSliceTimes;

/// 获取视频拍摄角度
- (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url;


-(void)cancelImageGeneration;


-(NSArray<FBVideoImageModel*>*)curVideoSliceModes;
-(void)asyncRequestVideoImage:(FBVideoImageModel*)model
                     complete:(void (^)(void))complete;
@end

NS_ASSUME_NONNULL_END
