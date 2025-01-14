//
//  JYVolumeManager.h
//  VideoClip
//
//  Created by yzh on 2019/4/29.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JYVolumeManager : NSObject

+ (float)currentVolume;

+ (void)setVolume:(float)volume;

+ (void)volumeChangeBlock:(void (^)(float volume))changeBlock;

@end

NS_ASSUME_NONNULL_END
