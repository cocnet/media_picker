//
//  JYCache.h
//  VideoClip
//
//  Created by yzh on 2019/12/23.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JYCache : NSObject

+ (instancetype)shared;

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;

- (id<NSCoding>)objectForKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
