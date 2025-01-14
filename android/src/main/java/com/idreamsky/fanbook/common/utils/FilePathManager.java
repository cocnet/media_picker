package com.idreamsky.fanbook.common.utils;

import android.content.Context;

import java.io.File;

public class FilePathManager {
    /// 用户产生的数据（草稿）
    public static String PATH_USER_DATA = "";
    /// 草稿
    public static String PATH_USER_DRAFT_DATA = "";
    /// 预裁剪的图片
    public static String PATH_USER_CROPED_IMAGE = "";
    /// SDK产生的数据（滤镜等）
    public static String PATH_SDK_DATA = "";
    /// 滤镜
    public static String PATH_SDK_DATA_FILTER = "";
    /// 贴纸
    public static String PATH_SDK_DATA_STICKER = "";
    /// 字体
    public static String PATH_SDK_DATA_FONT = "";
    /// 花字
    public static String PATH_SDK_DATA_CAPTION_STYLE = "";
    /// 音乐
    public static String PATH_SDK_DATA_MUSIC = "";
    /// 转场
    public static String PATH_SDK_DATA_TRANSITION = "";
    /// 素材json配置文件(从服务端下载的文件)
    /// 这个配置文件非assets目录下预留的json文件
    public static String PATH_SDK_DATA_ASSET_JSON = "";

    public static void initPath(Context context) {
        PATH_USER_DATA = context.getCacheDir().getAbsolutePath() + "/meishe_sdk/user_data/";
        File userCacheDataDir = new File(PATH_USER_DATA);
        if (!userCacheDataDir.exists()) userCacheDataDir.mkdirs();

        PATH_SDK_DATA = context.getCacheDir().getAbsolutePath() + "/meishe_sdk/sdk_data/";
        File sdkCachedDataDir = new File(PATH_SDK_DATA);
        if (!sdkCachedDataDir.exists()) sdkCachedDataDir.mkdirs();

        PATH_USER_DRAFT_DATA = PATH_USER_DATA + "draft/";
        File userdraftCacheDataDir = new File(PATH_USER_DRAFT_DATA);
        if (!userdraftCacheDataDir.exists()) userdraftCacheDataDir.mkdirs();

        PATH_USER_CROPED_IMAGE = PATH_USER_DATA + "cropedImage/";
        File userCropedImageCacheDataDir = new File(PATH_USER_CROPED_IMAGE);
        if (!userCropedImageCacheDataDir.exists()) userdraftCacheDataDir.mkdirs();

        PATH_SDK_DATA_FILTER = PATH_SDK_DATA + "filter/";
        File sdkFilterCacheDataDir = new File(PATH_SDK_DATA_FILTER);
        if (!sdkFilterCacheDataDir.exists()) sdkFilterCacheDataDir.mkdirs();

        PATH_SDK_DATA_STICKER = PATH_SDK_DATA + "sticker/";
        File sdkStickerCacheDataDir = new File(PATH_SDK_DATA_STICKER);
        if (!sdkStickerCacheDataDir.exists()) sdkStickerCacheDataDir.mkdirs();

        PATH_SDK_DATA_FONT = PATH_SDK_DATA + "font/";
        File sdkFontCacheDataDir = new File(PATH_SDK_DATA_FONT);
        if (!sdkFontCacheDataDir.exists()) sdkFontCacheDataDir.mkdirs();

        PATH_SDK_DATA_CAPTION_STYLE = PATH_SDK_DATA + "caption_style/";
        File sdkCaptionStyleCacheDataDir = new File(PATH_SDK_DATA_CAPTION_STYLE);
        if (!sdkCaptionStyleCacheDataDir.exists()) sdkCaptionStyleCacheDataDir.mkdirs();

        PATH_SDK_DATA_MUSIC = PATH_SDK_DATA + "music/";
        File sdkMusicCacheDataDir = new File(PATH_SDK_DATA_MUSIC);
        if (!sdkMusicCacheDataDir.exists()) sdkMusicCacheDataDir.mkdirs();

        PATH_SDK_DATA_TRANSITION = PATH_SDK_DATA + "transition/";
        File sdkTransitionCacheDataDir = new File(PATH_SDK_DATA_TRANSITION);
        if (!sdkTransitionCacheDataDir.exists()) sdkTransitionCacheDataDir.mkdirs();

        PATH_SDK_DATA_ASSET_JSON = PATH_SDK_DATA + "asset_json/";
        File sdkAssetJsonCacheDataDir = new File(PATH_SDK_DATA_ASSET_JSON);
        if (!sdkAssetJsonCacheDataDir.exists()) sdkAssetJsonCacheDataDir.mkdirs();
    }


}
