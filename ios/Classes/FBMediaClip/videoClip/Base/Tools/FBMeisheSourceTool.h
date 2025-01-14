//
//  FBMeisheSourceTool.h
//  multi_image_picker
//
//  Created by 杨志豪 on 4/28/22.
//

#import <Foundation/Foundation.h>
#import "FBResourceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBMeisheSourceTool : NSObject

+(instancetype)sharedInstance;

- (FBResourceModel *)loadAllSourseData;

- (void)updateNetWorkSource;

@end

NS_ASSUME_NONNULL_END
