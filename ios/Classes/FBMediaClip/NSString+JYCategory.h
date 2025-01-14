//
//  NSString+JYCategory.h
//  VideoClip
//
//  Created by yzh on 2019/4/29.
//  Copyright © 2019 Ray. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSString (JYCategory)

- (NSString *)URLEncodedString;

- (NSString *)URLDecodedString;

-(BOOL)isHasEmpty;

-(BOOL)isEmpty;

- (NSString *)trim;

- (NSString *)correctSandboxPath;

+ (NSString *)compareCurrentTime:(NSDate *)compareDate;

- (CGSize)singleLineSizeWithFont:(UIFont *)font;

+ (NSString *)convertTimecode:(int64_t)time;

-(NSString*)musicSandboxPath;
@end

NS_ASSUME_NONNULL_END
