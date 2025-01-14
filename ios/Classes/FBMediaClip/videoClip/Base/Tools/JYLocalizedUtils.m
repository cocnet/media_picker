//
//  JYLocalizedUtils.m
//  VideoClip
//
//  Created by yzh on 2019/8/19.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import "JYLocalizedUtils.h"

@implementation JYLocalizedModel

+ (instancetype)initWithZhString:(NSString *)zhString enString:(NSString *)enString {
    JYLocalizedModel *model = [JYLocalizedModel new];
    model.zhString = zhString;
    model.enString = enString;
    return model;
}

@end
