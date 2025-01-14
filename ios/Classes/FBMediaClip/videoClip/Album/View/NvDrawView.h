//
//  NvDrawView.h
//  multi_image_picker
//
//  Created by amzwin on 2022/3/26.
//

#import <UIKit/UIKit.h>

@class NvDrawView;
@protocol NvDrawViewDelegate <NSObject>

@optional

- (void)NvDrawView:(NvDrawView *)nvDrawView touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

- (void)NvDrawView:(NvDrawView *)nvDrawView touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

- (void)NvDrawView:(NvDrawView *)nvDrawView touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end

@interface NvDrawView : UIView
@property (nonatomic, weak) id<NvDrawViewDelegate> delegate;

@end
