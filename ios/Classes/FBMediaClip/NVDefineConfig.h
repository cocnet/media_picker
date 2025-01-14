//
//  DefineConfig.h
//  demoTool
//
//  Created by ms20180425 on 2018/5/23.
//  Copyright © 2018年 ms20180425. All rights reserved.
//

#ifndef NVDefineConfig_h
#define NVDefineConfig_h

#define NvEditModePlaceholder (-99)
#define NvEditModeFreeRatioPlaceholderPoint CGPointMake(1, 1)
typedef enum {
    NvEditMode16v9 = 0,
    NvEditMode1v1,
    NvEditMode9v16,
    NvEditMode3v4,
    NvEditMode4v3,
    NvEditMode18v9,
    NvEditModeFree = -1
} NvEditMode;

#define NV_FILTER_PAGE_SIZE 30
#define NV_TIME_BASE 1000000

#define NV_1S_TO_PT 50 //1秒所占的物理距离
#define NV_TIME_DEVIATION (NV_TIME_BASE / 40)
#define NV_TIME_DEVIATION_LEVEL_2 (NV_TIME_BASE / 20)
#define NV_TIME_ONE_FRAME 40000
#define NV_ASSET_SPACE (NV_TIME_BASE / 4) //素材最小间隔时间

// 素材下载路径
#define NV_ASSET_DOWNLOAD_PATH                                  @"/Documents/meishe"
#define NV_ASSET_DOWNLOAD_PATH_FILTER                           @"/Documents/meishe/Filter"
#define NV_ASSET_DOWNLOAD_PATH_THEME                            @"/Documents/meishe/Theme"
#define NV_ASSET_DOWNLOAD_PATH_CAPTION                          @"/Documents/meishe/Caption"
#define NV_ASSET_DOWNLOAD_PATH_ANIMATEDSTICKER                  @"/Documents/meishe/AnimatedSticker"
#define NV_ASSET_DOWNLOAD_PATH_TRANSITION                       @"/Documents/meishe/Transition"
#define NV_ASSET_DOWNLOAD_PATH_CAPTURE_SCENE                    @"/Documents/meishe/CaptureScene"
#define NV_ASSET_DOWNLOAD_PATH_FONT                             @"/Documents/meishe/Font"
#define NV_ASSET_DOWNLOAD_PATH_PARTICLE                         @"/Documents/meishe/Particle"
#define NV_ASSET_DOWNLOAD_PATH_FACE_STICKER                     @"/Documents/meishe/FaceSticker"
#define NV_ASSET_DOWNLOAD_PATH_CUSTOM_ANIMATED_STICKER          @"/Documents/meishe/CustomAnimatedSticker"
#define NV_ASSET_DOWNLOAD_PATH_FACE1_STICKER                    @"/Documents/meishe/Face1Sticker"
#define NV_CUSTOM_ANIMATED_STICKER_PIC                          @"/Documents/meishe/CustomAnimatedStickerPic"
#define NV_ASSET_DOWNLOAD_PATH_WATERMARK                        @"/Documents/meishe/Watermark"
#define NV_PATH_TEMP                                            @"/Documents/meishe/Temp"
#define NV_ASSET_DOWNLOAD_PATH_SUPERZOOM                        @"/Documents/meishe/Superzoom"
#define NV_ASSET_DOWNLOAD_PATH_ARSCENE                          @"/Documents/meishe/ARScene"
#define NV_ASSET_DOWNLOAD_PATH_SOUNDEFFECT                      @"/Documents/meishe/SoundEffect"
#define NV_PATH_BACKGROUND_COLOR                                @"/Documents/meishe/Background/Color"
#define NV_PATH_BACKGROUND_IMAGE                                @"/Documents/meishe/Background/Image"
#define NV_PATH_BACKGROUND_CUSTOMIMAGE                          @"/Documents/meishe/Background/CustomImage"

// UI设计相关
#define SCREANSCALE [UIScreen mainScreen].bounds.size.width / 375.0
#define SCREANWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREANHEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREANBOUNDS [UIScreen mainScreen].bounds
#define FONT12 [UIFont systemFontOfSize:12];
#define FONT14 [UIFont systemFontOfSize:14];
#define FONT16 [UIFont systemFontOfSize:16];
#define NV_CAPTURE_SPEEDBAR_COLOR       @"52D3FF"
#define NV_CAPTURE_PROGRESS_BACKGROUND  @"EAEAEA"
#define STYLE_COLOR         [UIColor nv_colorWithHexARGB:@"#FF52D3FF"]
#define TEXT_DISABLE_COLOR  [UIColor nv_colorWithHexARGB:@"#FF999CB0"]
#define TEXT_ENABLE_COLOR   [UIColor whiteColor]

//获取屏幕尺寸
#define SCREEN_WDITH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGTH [[UIScreen mainScreen] bounds].size.height

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IOS_11  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.f)
//是否是iPhoneX
#define KIsiPhoneX (IS_IOS_11 && IS_IPHONE && (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 375 && MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 812))

#define NV_STATUSBARHEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NV_NAV_BAR_HEIGHT 44

#define INDICATOR ((NV_STATUSBARHEIGHT>20)?34:0)

//视频录制保存的路径
#define LOCALDIR [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define VIDEO_PATH(string) [LOCALDIR stringByAppendingPathComponent:string]

//转码保存的路径
#define CONVERTPATH [LOCALDIR stringByAppendingPathComponent:@"ConvertFile"]

//水印保存路径
#define WATEMARK_PATH [LOCALDIR stringByAppendingPathComponent:@"warkmark"]

//画中画package保存路径
#define PIPPACKAGE_PATH [LOCALDIR stringByAppendingPathComponent:@"PIPPackage"]

//获取用户设置的value，参数是key
#define NV_UserInfo(key) [[NSUserDefaults standardUserDefaults] objectForKey:key];

//布局比例
#define SCREANSCALE [UIScreen mainScreen].bounds.size.width / 375.0
#define SCREANSCALEHEIGHT [UIScreen mainScreen].bounds.size.height / 667.0

//获取手机系统
#define  IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//调试模式下做判断
#ifdef DEBUG
#define TLog(format, ...) printf("%s\n\n",[[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String])
#else
#define TLog(format, ...)
#endif

//16进制颜色值
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//rgb颜色值
#define UIColorWithRGBA(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
//video
#define RECORD_MAX_TIME 8.0           //最长录制时间
#define VIDEO_FOLDER @"videoFolder" //视频录制存放文件夹

#endif /* NVDefineConfig_h */
