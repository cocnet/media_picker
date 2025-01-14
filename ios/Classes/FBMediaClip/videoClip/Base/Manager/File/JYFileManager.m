//
//  JYFileManager.m
//  VideoClip
//
//  Created by yzh on 2019/4/26.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "JYFileManager.h"
#import <FCFileManager/FCFileManager.h>

#define COVERPATH @"/coverPath"
#define AUDIOPATH @"/audioPath"
#define AUDIOCLIPPATH @"/audioPath/clip"
#define VIDEOCOMPILEPATH @"/Compiles"
#import "NSString+JYCategory.h"
#import "NSBundle+TZImagePicker.h"
@interface JYFileManager ()

@end

@implementation JYFileManager

+ (NSString *)coverPath {
    if (![FCFileManager existsItemAtPath:[FCFileManager pathForDocumentsDirectoryWithPath:COVERPATH]]) {
        [FCFileManager createDirectoriesForPath:COVERPATH];
    }
    return [FCFileManager pathForDocumentsDirectoryWithPath:COVERPATH];
}

+ (NSString *)audioPath {
    if (![FCFileManager existsItemAtPath:[FCFileManager pathForDocumentsDirectoryWithPath:AUDIOPATH]]) {
        [FCFileManager createDirectoriesForPath:AUDIOPATH];
    }
    return [FCFileManager pathForDocumentsDirectoryWithPath:AUDIOPATH];
}

+ (NSString *)audioClipPath {
    if (![FCFileManager existsItemAtPath:[FCFileManager pathForDocumentsDirectoryWithPath:AUDIOCLIPPATH]]) {
        [FCFileManager createDirectoriesForPath:AUDIOCLIPPATH];
    }
    return [FCFileManager pathForDocumentsDirectoryWithPath:AUDIOCLIPPATH];
}

+ (NSString *)videoCompilePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *compilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Compiles"];
    if (![fm fileExistsAtPath:compilePath]) {
        [fm createDirectoryAtPath:compilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return compilePath;
}

+ (NSString *)coverImagePathWithFileName:(NSString *)fileName {
    return [NSString stringWithFormat:@"%@/%@", [JYFileManager coverPath], fileName];
}

+ (NSString *)audioFilePathWithFileName:(NSString *)fileName {
    return [NSString stringWithFormat:@"%@/%@", [JYFileManager audioPath], fileName];
}

+ (NSString *)audioClipFilePathWithFileName:(NSString *)fileName {
    return [NSString stringWithFormat:@"%@/%@", [JYFileManager audioClipPath], fileName];
}

+ (NSString *)audioDefaultName {
    NSDateFormatter * format = [NSDateFormatter new];
    format.dateFormat = @"yyyyMMdd_HHmmss";
    NSString * name = [format stringFromDate:[NSDate new]];
    return name;
}

+ (NSArray<NSString *> *)allAudioFilePaths {
    NSMutableArray * arr = [NSMutableArray new];
    [arr addObjectsFromArray:[JYFileManager audioFilePaths]];
    [arr addObjectsFromArray:[JYFileManager audioClipFilePaths]];
    return arr.copy;
}

+ (NSArray<NSString *> *)audioFilePaths {
    NSArray * allFiles = [FCFileManager listFilesInDirectoryAtPath:AUDIOPATH];
    NSMutableArray * audioFilePaths = [NSMutableArray new];
    for (NSString * filePath in allFiles) {
        if ([[JYFileManager audioFileTypes] containsObject:filePath.pathExtension]) {
            [audioFilePaths addObject:filePath];
        }
    }
    return audioFilePaths.copy;
}

+ (NSArray<NSString *> *)audioClipFilePaths {
    NSArray * allFiles = [FCFileManager listFilesInDirectoryAtPath:AUDIOCLIPPATH];
    NSMutableArray * audioFilePaths = [NSMutableArray new];
    for (NSString * filePath in allFiles) {
        if ([[JYFileManager audioFileTypes] containsObject:filePath.pathExtension]) {
            [audioFilePaths addObject:filePath];
        }
    }
    return audioFilePaths.copy;
}

+ (NSArray<NSString *> *)videoCompileFilePaths {
    NSArray * allFiles = [FCFileManager listFilesInDirectoryAtPath:VIDEOCOMPILEPATH];
    NSMutableArray * videoCompileFilePaths = [NSMutableArray new];
    for (NSString * filePath in allFiles) {
        [videoCompileFilePaths addObject:filePath];
    }
    return videoCompileFilePaths.copy;
}

+ (BOOL)isExitAudioFileWithFileName:(NSString *)fileName {
   // NSLog(@"%@ -- %@", [JYFileManager audioFilePathWithFileName:fileName], [JYFileManager audioClipFilePathWithFileName:fileName]);
    return [JYFileManager isExitAudioFileWithFilePath:[JYFileManager audioFilePathWithFileName:fileName]] || [JYFileManager isExitAudioFileWithFilePath:[JYFileManager audioClipFilePathWithFileName:fileName]];
}

+ (BOOL)isExitAudioFileWithFilePath:(NSString *)filePath {
    return [FCFileManager existsItemAtPath:filePath];
}

+ (BOOL)isAudioFileWithFilePath:(NSString *)filePath {
    return [[JYFileManager audioFileTypes] containsObject:filePath.pathExtension];
}

+ (void)renameAudioAtPath:(NSString *)path withName:(NSString *)name {
    [FCFileManager renameItemAtPath:path withName:[NSString stringWithFormat:@"%@.%@", name, path.pathExtension]];
}

+ (NSArray<NSString *> *)audioFileTypes {
    return @[@"mp3", @"m4a", @"m4r"];
}

+ (void)createBandFileWithName:(NSString *)name complateBlock:(void (^)(NSString * bandPath, NSString * ringtonePath))completion {
    NSString * bPath = [[NSString stringWithFormat:@"%@%@.band", [FCFileManager pathForTemporaryDirectory], name] URLDecodedString];
    [FCFileManager removeItemAtPath:bPath];
    [FCFileManager createDirectoriesForPath:bPath];
    [JYFileManager copyFileFromPath:[[NSBundle tz_imagePickerBundle] pathForResource:@"template" ofType:@"band"] toPath:bPath];
    completion(bPath, [NSString stringWithFormat:@"%@/Media/ringtone.aiff", bPath]);
}

+ (void)createTempMp4WithName:(NSString *)name complateBlock:(void (^)(NSString * mp4Path))completion {
    NSString * mPath = [[NSString stringWithFormat:@"%@%@.mp4", [FCFileManager pathForTemporaryDirectory], name] URLDecodedString];
    [FCFileManager removeItemAtPath:mPath];
    completion(mPath);
}


+ (void)copyFileFromPath:(NSString *)sourcePath toPath:(NSString *)toPath {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray* array = [fileManager contentsOfDirectoryAtPath:sourcePath error:nil];
    for(int i = 0; i<[array count]; i++){
        NSString *fullPath = [sourcePath stringByAppendingPathComponent:[array objectAtIndex:i]];
        NSString *fullToPath = [toPath stringByAppendingPathComponent:[array objectAtIndex:i]];
        //NSLog(@"%@",fullPath);
        //NSLog(@"%@",fullToPath);
        //判断是不是文件夹
        BOOL isFolder = NO;
        //判断是不是存在路径 并且是不是文件夹
        BOOL isExist = [fileManager fileExistsAtPath:fullPath isDirectory:&isFolder];
        if (isExist){NSError *err = nil;
            [[NSFileManager defaultManager] copyItemAtPath:fullPath toPath:fullToPath error:&err];NSLog(@"%@",err);
            if (isFolder){
                [self copyFileFromPath:fullPath toPath:fullToPath];
            }
        }
    }
}
   
@end
