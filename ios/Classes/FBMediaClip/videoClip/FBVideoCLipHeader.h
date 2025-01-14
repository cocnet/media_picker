//
//  FBVideoCLipHeader.h
//  FBVideoClip
//
//  Created by 杨志豪 on 3/16/22.
//

#ifndef FBVideoCLipHeader_h
#define FBVideoCLipHeader_h

#import "UIColor+Hex.h"
#import "BaseLineUtil.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import "JYColorHex.h"
#import "Masonry/Masonry.h"
#import "UIColor+NvColor.h"
#import "UIView+frame.h"
#import "TZImagePickerController.h"
#import "NVDefineConfig.h"
#define JYWeakSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self




typedef enum{
    FBClipType_Clip = 0,    //剪辑
    FBClipType_Music,       //音乐
    FBClipType_Caption,    //字幕
    FBClipType_Filter, //滤镜
    FBClipType_Sticker, //贴纸
    FBClipType_Background, //背景
    FBClipType_Paint, //画笔
    FBClipType_Mosaic, //马赛克
    ///----剪辑小分类
    FBClipType_Back,    //返回
    FBClipType_Adjust,    //调整
    FBClipType_Cut,    //分割
    FBClipType_Speed,    //变速
    FBClipType_Delete,    //删除
    FBClipType_Save,    //保存
    FBClipType_Short,    //排序
    FBClipType_Cropping,    //裁剪
}FBClipType;


//沙盒路径
#define LOCALDIR [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

//定义DebugLog
#ifdef DEBUG
#define DebugLog( s, ... ) NSLog( @"<%p %@:(%d)%s> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __func__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog(s, ...)
#endif

//安全的主线程
#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

//屏幕相关
#define JY_SCREAN_WIDTH [UIScreen mainScreen].bounds.size.width
#define JY_SCREAN_SCALE [UIScreen mainScreen].bounds.size.width / 375.0
#define JY_SCREAN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kScreenW [[UIScreen mainScreen] bounds].size.width
#define kScreenH [[UIScreen mainScreen] bounds].size.height
#define kScaleW kScreenW/375

#define JY_NavAndStatusHight (self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height)

#define kNavigationBarHeight ([BaseLineUtil baseLineOfStatusBarHeight] + 44)
#define kSafeAreaBottom [BaseLineUtil baseLineOfBottomSafeHeight]
#define kSafeAreaStatusBarHeight [BaseLineUtil baseLineOfStatusBarHeight]

#define weakify(var) __weak typeof(var) weakSelf = var;
#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = weakSelf ; \
_Pragma("clang diagnostic pop")

//时间相关
#define JYViewAnimationDurationValuePop 0.3
#define JYAnimationDurationOfDefault 0.2
#endif /* FBVideoCLipHeader_h */
