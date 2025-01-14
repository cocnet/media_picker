//
//  NSString+JYCategory.m
//  VideoClip
//
//  Created by yzh on 2019/4/29.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "NSString+JYCategory.h"
#import "FBVideoCLipHeader.h"
#import "NSString+Utilities.h"
#import "JYHandleFile.h"

@implementation NSString (JYCategory)

- (NSString *)URLEncodedString {
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

- (NSString *)URLDecodedString {
    NSString * decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)self, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

-(BOOL)isHasEmpty {
    NSRange range = [self rangeOfString:@" "];
    if (range.location != NSNotFound) {
        return YES; //yes代表包含空格
    }else {
        return NO; //反之
    }
}

/// 是否为空或者是空格
- (BOOL)isEmpty {///< 是否为空或者是空格
    NSString * newSelf = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(nil == self
       || self.length ==0
       || [self isEqualToString:@""]
       || [self isEqualToString:@"<null>"]
       || [self isEqualToString:@"(null)"]
       || [self isEqualToString:@"null"]
       || newSelf.length ==0
       || [newSelf isEqualToString:@""]
       || [newSelf isEqualToString:@"<null>"]
       || [newSelf isEqualToString:@"(null)"]
       || [newSelf isEqualToString:@"null"]
       || [self isKindOfClass:[NSNull class]]) {
        
        return YES;
        
    } else {
        // <object returned empty description> 会来这里
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [self stringByTrimmingCharactersInSet:set];
        
        return [trimedString isEqualToString: @""];
    }
    
    return NO;
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)compareCurrentTime:(NSDate *)compareDate {
    NSTimeInterval timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:NSLocalizedString(@"刚刚", nil)];
    } else if((temp = timeInterval / 60) <60) {
        result = [NSString stringWithFormat:@"%ld%@",temp,NSLocalizedString(@"分钟前", nil)];
    } else if((temp = temp / 60) <24){
        result = [NSString stringWithFormat:@"%ld%@",temp,NSLocalizedString(@"小时前", nil)];
    } else if((temp = temp / 24) <30){
        result = [NSString stringWithFormat:@"%ld%@",temp,NSLocalizedString(@"天前", nil)];
    } else if((temp = temp / 30) <12){
        result = [NSString stringWithFormat:@"%ld%@",temp,NSLocalizedString(@"月前", nil)];
    } else{
        temp = temp / 12;
        result = [NSString stringWithFormat:@"%ld%@",temp,NSLocalizedString(@"年前", nil)];
    }
    return result;
}

- (CGSize)singleLineSizeWithFont:(UIFont *)font {
    NSDictionary *dic = @{NSFontAttributeName:font};
    CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:dic
                                     context:nil];
    return rect.size;
}

- (NSString *)correctSandboxPath {
    NSArray *arr = @[
        @"Documents",
        @"Cache"
    ];
    
    for (NSString *str in arr) {
        if ([self containsString:str]) {
            NSRange range = [self rangeOfString:str];
            NSString *path = [LOCALDIR stringByAppendingString:[self substringFromIndex:range.location + range.length]];
            return path;
        }
    }
    return self;
}

-(NSString*)musicSandboxPath{
    NSString *cachePath = [[JYHandleFile getSDKMusicDataDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",[self md5String]]];
    if([[NSFileManager defaultManager] fileExistsAtPath:cachePath]){
        return cachePath;
    }
    return self;
}

+ (NSString *_Nullable)convertTimecodePrecision:(int64_t)time {
    time += 50000;
    int min = (int)(time / 60000000);
    int sec = (int)((time % 60000000) / 100000);
    int decimal = sec % 10;
    sec /= 10;
    if (min >= 10 && sec >= 10)
        return [NSString stringWithFormat:@"%d:%d.%d", min, sec, decimal];
    else if (min >= 10)
        return [NSString stringWithFormat:@"%d:0%d.%d", min, sec, decimal];
    else if (sec >= 10)
        return [NSString stringWithFormat:@"0%d:%d.%d", min, sec, decimal];
    else
        return [NSString stringWithFormat:@"0%d:0%d.%d", min, sec, decimal];
}


@end
