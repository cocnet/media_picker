//================================================================================
//
// (c) Copyright China Digital Video (Beijing) Limited, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Dec 29. 2016
//   Author:        NewAuto video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"

/*! \anchor ARSCENE_DETECTION_MODE */
/*!
 *  \if ENGLISH
 *   @name AR Scene detection mode.
 *  \else
 *   @name AR场景检测模式。
 *  \endif
 */
//!@{
typedef enum {
    NvsARSceneDetectionMode_Video = 0x01,           //!< \if ENGLISH video detection mode  \else 视频检测 \endif
    NvsARSceneDetectionMode_Image = 0x02,           //!< \if ENGLISH image detection mode  \else 图像检测 \endif
    NvsARSceneDetectionMode_SemiImage = 0x10,       //!< \if ENGLISH Semi-image detection mode  \else 半图像检测 \endif
    NvsARSceneDetectionMode_SingleThread = 0x04,    //!< \if ENGLISH single thread detection  \else 单线程检测 \endif
    NvsARSceneDetectionMode_MultiThread = 0x08,     //!< \if ENGLISH multi-thread detection  \else 多线程检测 \endif
} NvsARSceneDetectionMode;

/*! \if ENGLISH
 *  \brief Face feature info, landmarks is an array of CGPoints, visibilities is an array of float
 *  \else
 *  \brief 美妆特效渲染层数据, landmarks是CGPoints数组, visibilities是float数组
 *  \endif
 *  \since 2.15.0
 */
@interface NvsFaceFeatureInfo : NSObject

@property (nonatomic, assign) int faceId;
@property (nonatomic, assign) NvsRect boundingBox;
@property (nonatomic, strong) NSMutableArray<NSValue *> *landmarks;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *visibilities;
@property (nonatomic, assign) float yaw;
@property (nonatomic, assign) float pitch;
@property (nonatomic, assign) float roll;

@end

@protocol NvsARSceneManipulateDelegate <NSObject>
@optional

/*! \if ENGLISH
 *  \brief Get the callback of the original enclosing rectangle for the face.
 *  <br>Please pay special attention: this function is called in the background thread, not in the UI thread. Please consider thread safety issues!!
 *  \param faceIds Array of face tag
 *  \param boundingRects Array of face range
 *  \param count Count of face arrays. When the count is 0, the pointers of "faceIds" and "boundingRects" are nil.
 *  \else
 *  \brief 获取人脸的原始包围矩形框回调
 *  <br>请特别注意:这个函数被调用是在后台的线程,而不是在UI线程.使用请考虑线程安全的问题!!
 *  \param faceIds 人脸标记数组
 *  \param boundingRects 人脸范围数组
 *  \param count 人脸数组数量，当数量为0时，faceIds和boundingRects的指针为空
 *  \endif
 *  \since 2.7.0
*/
- (void)notifyFaceBoundingRectWithId:(int*)faceIds boundingRect:(NvsRect*)boundingRects faceCount:(int)count;

/*! \if ENGLISH
 *  \brief Get the callback of the face features for the face.
 *  <br>Please pay special attention: this function is called in the background thread, not in the UI thread. Please consider thread safety issues!!
 *  \param faceFeatureInfos Array of face feature info
 *  \else
 *  \brief 获取人脸特征信息回调
 *  <br>请特别注意:这个函数被调用是在后台的线程,而不是在UI线程.使用请考虑线程安全的问题!!
 *  \param faceFeatureInfos 人脸特征信息数组
 *  \endif
 *  \since 2.15.0
*/
- (void)notifyFaceFeatureInfos:(NSMutableArray<NvsFaceFeatureInfo *> *)faceFeatureInfos;

/*! \if ENGLISH
 *  \brief Notify if custom avatar realtime resources is preloaded or not.
    Note: This function can only be called in backend thread, not in UI thread.
          Please pay attention to thread safety.
 *  \param isPreloaded custom avatar realtime resources is preloaded or not.
 *  \else
 *  \brief 通知捏脸特效实时模式下所需预加载的资源是否已加载。
    请特别注意:这个函数被调用是在后台的线程,而不是在UI线程.使用请考虑线程安全的问题!!
 *  \param isPreloaded 资源是否已加载。
 *  \endif
 */
- (void)notifyCustomAvatarRealtimeResourcesPreloaded:(BOOL)isPreloaded;

/*! \if ENGLISH
 *  \brief Notify detection time spent.
    Note: This function can only be called in backend thread, not in UI thread.
          Please pay attention to thread safety.
 *  \param time detection time spent.
 *  \else
 *  \brief 通知人脸检测用时。
    请特别注意:这个函数被调用是在后台的线程,而不是在UI线程.使用请考虑线程安全的问题!!
 *  \param time 人脸检测用时。
 *  \endif
 */
- (void)notifyDetectionTimeCost:(float)time;


/*! \if ENGLISH
 *  \brief Notify total time spent.
    Note: This function can only be called in backend thread, not in UI thread.
          Please pay attention to thread safety.
 *  \param  time total time spent.
 *  \else
 *  \brief 通知总用时。
    请特别注意:这个函数被调用是在后台的线程,而不是在UI线程.使用请考虑线程安全的问题!!
 *  \param time 用时。
 *  \endif
 */
- (void)notifyTotalTimeCost:(float)time;

@end

/*! \if ENGLISH
 *  \brief AR scene processing interface
 *
 *  \warning In the NvsARSceneManipulate class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief AR场景处理接口
 *
 *  \warning NvsARSceneManipulate类中，所有public API都在UI线程使用！！！
 *  \endif
*/
@interface NvsARSceneManipulate : NSObject

@property (nonatomic, weak) id<NvsARSceneManipulateDelegate> delegate;

/*!
 *  \if ENGLISH
 *  \brief Set detection mode.
 *  \param mode detection mode, for all supported mode, please refer to [ARSCENE_DETECTION_MODE].
 *  \else
 *  \brief 设置检测模式。
 *  \param mode 检测模式, 当前支持的检测模式请参见[AR场景检测模式](@ref ARSCENE_DETECTION_MODE)。
 *  \endif
*/
- (void)setDetectionMode:(NvsARSceneDetectionMode)mode;

/*!
 *  \if ENGLISH
 *  \brief Reset tracking.
 *  \else
 *  \brief 重置跟踪。
 *  \endif
*/
- (void)resetTracking;

/*!
 *  \if ENGLISH
 *  \brief Reset skin color.
 *  \else
 *  \brief 重置肤色。
 *  \endif
*/
- (void)resetSkinColor;

/*!
 *  \if ENGLISH
 *  \brief Set automatically probe face orientation or not.
 *  \param autoProbe automatically probe or not.
 *  \else
 *  \brief 设置是否自动探测人脸朝向。
 *  \param autoProbe 是否自动探测人脸朝向。
 *  \endif
*/
- (void)setDetectionAutoProbe:(bool)autoProbe;

- (void)setInternalObject:(void *)internalObject;

@end
