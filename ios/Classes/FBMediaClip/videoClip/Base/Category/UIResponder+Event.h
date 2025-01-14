//
//  UIResponder+Event.h
//  StarryNight
//
//  Created by zingwin on 2017/3/7.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import <UIKit/UIKit.h>

//调整背景
static NSString * const kDidChangeBgColorEvent = @"kDidChangeBgColorEvent";
static NSString * const kDidChangeBgSizeEvent = @"kDidChangeBgSizeEvent";
static NSString * const kDidChangeBgClearEvent = @"kDidChangeBgClearEvent";

//裁剪
static NSString * const kMeidaClipScaleEvent = @"kMeidaClipScaleEvent";
static NSString * const kMeidaClipRotateCVTEvent = @"kMeidaClipRotateCVTEvent";
static NSString * const kMeidaClipRotateEvent = @"kMeidaClipRotateEvent";
static NSString * const kAdjustSelectModeSwitchEvent = @"kAdjustSelectModeSwitchEvent";

//底部调整按钮关闭确认
static NSString * const kAdjustBottomCancelEvent = @"kAdjustBottomCancelEvent";
static NSString * const kAdjustBottomConfirmEvent = @"kAdjustBottomConfirmEvent";
//调整时间轴选中资源改变
static NSString * const kAdjustTimelineIndexChangedEvent = @"kAdjustTimelineIndexChangedEvent";

static NSString * const kPlayToolbarPlayEvent = @"kPlayToolbarPlayEvent";

@interface UIResponder (Event)
/**
 *  发送一个路由器消息, 对eventName感兴趣的 UIResponsder 可以对消息进行处理
 *
 *  @param eventName 发生的事件名称
 *  @param userInfo  传递消息时, 携带的数据, 数据传递过程中, 会有新的数据添加
 *
 */
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

@end
