//
//  NvDrawView.m
//  multi_image_picker
//
//  Created by amzwin on 2022/3/26.
//

#import "NvDrawView.h"



@interface NvDrawView()

@end

@implementation NvDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.delegate NvDrawView:self touchesBegan:touches withEvent:event];
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.delegate NvDrawView:self touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.delegate NvDrawView:self touchesEnded:touches withEvent:event];
}

@end


