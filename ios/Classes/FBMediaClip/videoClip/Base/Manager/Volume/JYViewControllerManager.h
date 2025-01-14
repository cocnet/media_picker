//
//  JYViewControllerManager.h
//  VideoClip
//
//  Created by fzy on 2019/5/17.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JYViewControllerManager : NSObject

+ (UIViewController *)getCurrentVC;

+ (UINavigationController *)getCurrentNC;

@end

NS_ASSUME_NONNULL_END
