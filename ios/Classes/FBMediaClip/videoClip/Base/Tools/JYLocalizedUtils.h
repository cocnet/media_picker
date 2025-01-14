//
//  JYLocalizedUtils.h
//  VideoClip
//
//  Created by yzh on 2019/8/19.
//  Copyright © 2019 JYKJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    JYLanguageTypeCN,
    JYLanguageTypeEN,
} JYLanguageType;
@interface JYLocalizedModel : NSObject

@property (nonatomic) NSString *zhString;
@property (nonatomic) NSString *enString;

+ (instancetype)initWithZhString:(NSString *)zhString enString:(NSString *)enString;

@end

NS_ASSUME_NONNULL_END
