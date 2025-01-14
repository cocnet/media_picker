//
//  FBResourceModel.m
//  multi_image_picker
//
//  Created by 杨志豪 on 4/28/22.
//

#import "FBResourceModel.h"

@implementation FBMeisheLibModel

- (NSString *)getMeisheUdid {
    if (self.fileName.length > 10 && [self.fileName containsString:@"."]) {
        return [self.fileName componentsSeparatedByString:@"."].firstObject;
    }
    return @"";
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"strength" : @"strong"};
}

@end

@implementation FBResourceModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"stickerArray" : [FBMeisheLibModel class],
             @"musicArray" : [FBMeisheLibModel class],
             @"fftArray" : [FBMeisheLibModel class],
             @"captionArray" : [FBMeisheLibModel class],
             @"filterArray" : [FBMeisheLibModel class]
    };
}

@end
