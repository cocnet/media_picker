//
//  JYDeviceUtils.m
//  VideoClip
//
//  Created by yzh on 2019/8/19.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import "JYDeviceUtils.h"
#import "DeviceUtil.h"
#import <AVFoundation/AVFoundation.h>
#import "NVDefineConfig.h"
#import "NSBundle+TZImagePicker.h"
@implementation JYDeviceUtils

+ (BOOL)isZHLanguage {
    NSString *preferredLang  = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    return [preferredLang containsString:@"zh"];
}

+ (BOOL)isZHRegion {
    NSString *localeIdentifier = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
    return [localeIdentifier containsString:@"zh"];
}

+ (BOOL)isIphoneXSeries {
    return KIsiPhoneX;
}

+ (BOOL)isIphone6Under {
    DeviceUtil *util = [DeviceUtil new];
    BOOL isIphone6Under =
    util.hardware == IPHONE_2G ||
    util.hardware == IPHONE_3G ||
    util.hardware == IPHONE_3GS ||
    util.hardware == IPHONE_4 ||
    util.hardware == IPHONE_4_CDMA ||
    util.hardware == IPHONE_5 ||
    util.hardware == IPHONE_5_CDMA_GSM ||
    util.hardware == IPHONE_5C_CDMA_GSM ||
    util.hardware == IPHONE_5S ||
    util.hardware == IPHONE_5S_CDMA_GSM ||
    util.hardware == IPHONE_6_PLUS ||
    util.hardware == IPHONE_6;
    return isIphone6Under;
}

+ (NSString *)currentVersion {
    return  [[[NSBundle tz_imagePickerBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)currentBuildVersion {
    return [[[NSBundle tz_imagePickerBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (BOOL)isCanRecord {
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    return bCanRecord;
}

@end
