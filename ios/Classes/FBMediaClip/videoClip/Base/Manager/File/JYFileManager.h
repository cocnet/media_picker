//
//  JYFileManager.h
//  VideoClip
//
//  Created by yzh on 2019/4/26.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYFileManager : NSObject

// 音频目录
+ (NSString *)audioPath;
// 剪辑过的音频目录
+ (NSString *)audioClipPath;

+ (NSString *)audioFilePathWithFileName:(NSString *)fileName;

+ (NSString *)audioDefaultName;

// 封面
+ (NSString *)coverImagePathWithFileName:(NSString *)fileName;

// 所有文件目录
+ (NSArray<NSString *> *)allAudioFilePaths;
// 未剪辑过的文件目录
+ (NSArray<NSString *> *)audioFilePaths;
// 裁剪过的所有文件目录
+ (NSArray<NSString *> *)audioClipFilePaths;

+ (NSArray<NSString *> *)videoCompileFilePaths;

+ (BOOL)isExitAudioFileWithFileName:(NSString *)fileName;
+ (BOOL)isExitAudioFileWithFilePath:(NSString *)filePath;

+ (BOOL)isAudioFileWithFilePath:(NSString *)filePath;

+ (void)renameAudioAtPath:(NSString *)path withName:(NSString *)name;

/**
 创建临时band文件

 @param name 文件名称 /xxx/name.m4a -> name
 @param completion 完成回调 bandPath -> band文件路径，ringtonePath -> 铃声文件路径
 */
+ (void)createBandFileWithName:(NSString *)name complateBlock:(void (^)(NSString * bandPath, NSString * ringtonePath))completion;

/**
 创建临时的MP4文件，目前要用于分享

 @param name 文件名
 @param completion 目标文件路径
 */
+ (void)createTempMp4WithName:(NSString *)name complateBlock:(void (^)(NSString * mp4Path))completion;

+ (void)copyFileFromPath:(NSString *)sourcePath toPath:(NSString *)toPath;

@end
