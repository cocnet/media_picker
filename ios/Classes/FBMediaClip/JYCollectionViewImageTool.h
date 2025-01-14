//
//  JYCollectionViewImageTool.h
//  VideoClip
//
//  Created by 杨志豪 on 2019/5/22.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JYCollectionViewImageTool : NSObject

+(instancetype)shareInstance;

//从缓存里取
- (UIImage *)getImageForKey:(NSString *)string;

//存到缓存容器中去
- (void)saveImage:(UIImage *)image key:(NSString *)string;

- (void)removeAllData;

@end

NS_ASSUME_NONNULL_END
