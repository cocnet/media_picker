//
//  JYHandleFile.m
//  SDKDemo
//
//  Created by yzhon 2019/3/25.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "JYHandleFile.h"
#import <FCFileManager/FCFileManager.h>
#import <CommonCrypto/CommonDigest.h>
#import "NSString+Utilities.h"
@implementation JYHandleFile

+ (NSString *)videoCacheFile {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Caches"];
    if (![fm fileExistsAtPath:cachePath]) {
        
        [fm createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return cachePath;
}

+ (NSString *)videoCompileFile {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *compilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Compiles"];
    if (![fm fileExistsAtPath:compilePath]) {
        
        [fm createDirectoryAtPath:compilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return compilePath;
}

+ (NSString *)filePathWithFileName:(NSString *)fileName {
    
    NSString *filePath = [[self videoCacheFile] stringByAppendingPathComponent:fileName];
    
    return filePath;
}

+ (NSString *)compileFilePathWithFileName:(NSString *)fileName {
    
    NSString *filePath = [[self videoCompileFile] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
    
    return filePath;
}

+ (NSString *)getCompileFilePathWithFileName:(NSString *)fileName {
    
    NSString *filePath = [[self videoCompileFile] stringByAppendingPathComponent:fileName];
    
    return filePath;
}

+ (NSArray *)getCompileVideos {
    
    NSFileManager * fileManger = [NSFileManager defaultManager];
    NSString *path = [self videoCompileFile];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    
    if (isExist) {
        
        if (isDir) {
            
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            NSLog(@"path == %@",path);
            return dirArray;
        }else{
            NSString *fileName = [[path componentsSeparatedByString:@"/"] lastObject];
            if ([fileName hasSuffix:@".m"]) {
                //do anything you want
            }
            return nil;
        }
    } else {
        
        //NSLog(@"this path is not exist!");
    }
    return nil;
}

+ (void)clearDocCaches {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Caches"];
    if ([fm fileExistsAtPath:cachePath]) {
        
        [fm removeItemAtPath:cachePath error:nil];
    }
}


/// 获取用户数据根目录
+ (NSString*)getUserDataDirectory{
    NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    NSString *path = [NSString stringWithFormat:@"%@/media_editor/", docPath];
    if(![FCFileManager existsItemAtPath:path]){
        [FCFileManager createDirectoriesForPath:path];
    }
    return path;
}

/// 获取sdk缓存数据根目录
+ (NSString*)getSDKDataDirectory{
    NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    NSString *path = [NSString stringWithFormat:@"%@/meishe/", docPath];
    if(![FCFileManager existsItemAtPath:path]){
        [FCFileManager createDirectoriesForPath:path];
    }
    return path;
}

+ (NSString*)getSDKMusicDataDirectory{
    NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    NSString *path = [NSString stringWithFormat:@"%@/meishe/music/", docPath];
    if(![FCFileManager existsItemAtPath:path]){
        [FCFileManager createDirectoriesForPath:path];
    }
    return path;
}

/// 通过requestid 创建用户草稿目录
+ (NSString*)getDirectoryByRequestId:(NSString*)requestId{
    NSString *userDataPath = [[self class] getUserDataDirectory];
    NSString *path = [NSString stringWithFormat:@"%@%@/",userDataPath, requestId];
    if(![FCFileManager existsItemAtPath:path]){
        [FCFileManager createDirectoriesForPath:path];
    }
    return path;
}

+ (NSString*)getLiveDirectory{
    NSString *userDataPath = [[self class] getUserDataDirectory];
    NSString *path = [NSString stringWithFormat:@"%@Live/",userDataPath];
    if(![FCFileManager existsItemAtPath:path]){
        [FCFileManager createDirectoriesForPath:path];
    }
    return path;
}

+ (NSString*)getImgCropDirectory{
    NSString *userDataPath = [[self class] getUserDataDirectory];
    NSString *path = [NSString stringWithFormat:@"%@imgCrop/",userDataPath];
    if(![FCFileManager existsItemAtPath:path]){
        [FCFileManager createDirectoriesForPath:path];
    }
    return path;
}

+ (NSString*)getRelativePath:(NSString*)absolutePath{
//    NSString *doc = [FCFileManager pathForDocumentsDirectory];
    NSString *userPath = [self getUserDataDirectory];
    NSString *path = [absolutePath stringByReplacingOccurrencesOfString:userPath withString:@""];
    return path;
}

+(void)deleteDirectoryByRequestId:(NSString*)requestId{
    NSString *userDataPath = [[self class] getUserDataDirectory];
    NSString *path = [NSString stringWithFormat:@"%@%@/",userDataPath, requestId];
    if([FCFileManager existsItemAtPath:path]){
        [FCFileManager removeItemAtPath:path];
    }
}

+(NSString *)md5HashOfPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Make sure the file exists
    if( [fileManager fileExistsAtPath:path isDirectory:nil] ){
        NSData *data = [NSData dataWithContentsOfFile:path];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5( data.bytes, (CC_LONG)data.length, digest );
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        
        for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ )
        {
            [output appendFormat:@"%02x", digest[i]];
        }
        
        return output;
    }else{
        return @"";
    }
}

+(void)deleteFile:(NSString*)path{
    if([FCFileManager existsItemAtPath:path]){
        [FCFileManager removeItemAtPath:path];
    }
}

+(NSString*)cacheName:(NSString*)remoteUrl ext:(NSString*)ext{
    if(ext == nil){
        ext = @"";
    }
    return [NSString stringWithFormat:@"%@.%@", [remoteUrl md5String], ext];
}

+(BOOL)isFilePathExist:(NSString*)path{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
//    return [FCFileManager existsItemAtPath:path];
}

+(NSString*)removeAbsolutePathPrefix:(NSString*)absolutePath{
    NSString *userPath = [self getUserDataDirectory];
    NSString *pathForCachesDirectory = [FCFileManager pathForCachesDirectory];
    NSString *pathForDocumentsDirectory = [FCFileManager pathForDocumentsDirectory];
    NSString *pathForTemporaryDirectory = [FCFileManager pathForTemporaryDirectory];
    NSString *pathForLibraryDirectory = [FCFileManager pathForLibraryDirectory];
   
    if([absolutePath containsString:userPath]) return [absolutePath stringByReplacingOccurrencesOfString:userPath withString:@""];
    
    if([absolutePath containsString:pathForCachesDirectory]) return [absolutePath stringByReplacingOccurrencesOfString:pathForCachesDirectory withString:@""];
   
    if([absolutePath containsString:pathForDocumentsDirectory]) return [absolutePath stringByReplacingOccurrencesOfString:pathForDocumentsDirectory withString:@""];
   
    if([absolutePath containsString:pathForTemporaryDirectory]) return [absolutePath stringByReplacingOccurrencesOfString:pathForTemporaryDirectory withString:@""];
    
    if([absolutePath containsString:pathForLibraryDirectory]) return [absolutePath stringByReplacingOccurrencesOfString:pathForLibraryDirectory withString:@""];
    
    return absolutePath;
}
+(NSString*)findAbsolutePath:(NSString*)path{
    //sdk use data
    NSString* sandPath =  [[JYHandleFile getUserDataDirectory] stringByAppendingPathComponent:path];
    if([JYHandleFile isFilePathExist:sandPath]) return sandPath;
    
    //doc cahce
    sandPath =  [[FCFileManager pathForDocumentsDirectory] stringByAppendingPathComponent:path];
    if([JYHandleFile isFilePathExist:sandPath]) return sandPath;
    
    //cache
    sandPath =  [[FCFileManager pathForCachesDirectory] stringByAppendingPathComponent:path];
    if([JYHandleFile isFilePathExist:sandPath]) return sandPath;
    
    //library
    sandPath =  [[FCFileManager pathForLibraryDirectory] stringByAppendingPathComponent:path];
    if([JYHandleFile isFilePathExist:sandPath]) return sandPath;
    
    //tmp
    sandPath =  [[FCFileManager pathForTemporaryDirectory] stringByAppendingPathComponent:path];
    if([JYHandleFile isFilePathExist:sandPath]) return sandPath;
    
    return path;
}
@end
