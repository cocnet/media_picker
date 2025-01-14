//
//  JYHandleFile.h
//  SDKDemo
//
//  Created by yzhon 2019/3/25.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JYHandleFile : NSObject

+ (NSString *)filePathWithFileName:(NSString *)fileName;
+ (NSString *)compileFilePathWithFileName:(NSString *)fileName;
+ (NSString *)getCompileFilePathWithFileName:(NSString *)fileName;

+ (NSArray *)getCompileVideos;

+ (void)clearDocCaches;

/// 获取用户数据根目录
+ (NSString*)getUserDataDirectory;

/// 获取sdk缓存数据根目录
+ (NSString*)getSDKDataDirectory;
/// sdk 音乐下载存放目录
+ (NSString*)getSDKMusicDataDirectory;

/// 通过requestid 创建用户草稿目录
+ (NSString*)getDirectoryByRequestId:(NSString*)requestId;

/// 获取相对路径
+ (NSString*)getRelativePath:(NSString*)absolutePath;

/// 删除用户草稿以及相应数据
+(void)deleteDirectoryByRequestId:(NSString*)requestId;

/// 拍摄存放目录
+ (NSString*)getLiveDirectory;

/// 获取文件MD5
+ (NSString *)md5HashOfPath:(NSString *)path;

/// 删除指定路径的文件
+(void)deleteFile:(NSString*)path;

/// 通过url得到本地缓存key
+(NSString*)cacheName:(NSString*)remoteUrl ext:(NSString*)ext;

+ (NSString*)getImgCropDirectory;

+(BOOL)isFilePathExist:(NSString*)path;


+(NSString*)findAbsolutePath:(NSString*)path;
+(NSString*)removeAbsolutePathPrefix:(NSString*)absolutePath;
@end

NS_ASSUME_NONNULL_END
