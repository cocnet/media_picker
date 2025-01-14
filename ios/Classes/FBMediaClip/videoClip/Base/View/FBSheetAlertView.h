//
//  FBSheetAlertView.h
//  multi_image_picker
//
//  Created by amzwin on 2022/5/12.
//

#import <UIKit/UIKit.h>
#import "FBFullScreenBottomView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBSheetAlertView : FBFullScreenBottomView



+(void)showInView:(UIView*)inView
            title:(NSString*)title
      cancelBtnTitle:(NSString*)cancelTitle
     comfrimBtnTitle:(NSString*)confirmTitle
      cancelCallback:( void(^)(void) )cancelCallback
  confrimCallback:( void(^)(void) )confrimCallback;

@end

NS_ASSUME_NONNULL_END
