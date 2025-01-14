//
//  JYVolumeManager.m
//  VideoClip
//
//  Created by yzh on 2019/4/29.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "JYVolumeManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface JYVolumeManager ()

@property (nonatomic, strong) void(^volumeBlock)(float volume);

@property (nonatomic, strong) UISlider * volumeSlider;

@end

@implementation JYVolumeManager

+ (JYVolumeManager *)share {
    static JYVolumeManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [JYVolumeManager new];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    });
    return manager;
}

+ (float)currentVolume {
    return [JYVolumeManager share].volumeSlider.value;
}

+ (void)setVolume:(float)volume {
    [[JYVolumeManager share].volumeSlider setValue:volume animated:NO];
    [[JYVolumeManager share].volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

+ (void)volumeChangeBlock:(void (^)(float volume))changeBlock {
    [JYVolumeManager share].volumeBlock = changeBlock;
}

- (void)volumeChanged:(NSNotification *)notification {
    float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    self.volumeBlock(volume);
}

- (UISlider *)volumeSlider {
    if (!_volumeSlider) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *view in volumeView.subviews) {
            if ([view isKindOfClass:[UISlider class]]) {
                _volumeSlider = (UISlider *)view;
                break;
            }
        }
    }
    return _volumeSlider;
}

@end
