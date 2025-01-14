//
//  JYCache.m
//  VideoClip
//
//  Created by yzh on 2019/12/23.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import "JYCache.h"
#import <YYCache/YYCache.h>

@interface JYCache ()

@property (nonatomic) YYCache *cache;

@end

@implementation JYCache

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static JYCache *shared;
    dispatch_once(&onceToken, ^{
        shared = [JYCache new];
        shared.cache = [[YYCache alloc] initWithName:@"JYCache"];
    });
    return shared;
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
    [self.cache setObject:object forKey:key];
}

- (id<NSCoding>)objectForKey:(NSString *)key {
    return [self.cache objectForKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
    [self.cache removeObjectForKey:key];
}

@end
