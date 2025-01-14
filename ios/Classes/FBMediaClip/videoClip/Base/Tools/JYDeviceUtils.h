//
//  JYDeviceUtils.h
//  VideoClip
//
//  Created by yzh on 2019/8/19.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JYDeviceUtils : NSObject

+ (BOOL)isZHLanguage;
+ (BOOL)isZHRegion;

+ (BOOL)isIphoneXSeries;
+ (BOOL)isIphone6Under;

+ (NSString *)currentVersion;
+ (NSString *)currentBuildVersion;

+ (BOOL)isCanRecord;

@end

NS_ASSUME_NONNULL_END
