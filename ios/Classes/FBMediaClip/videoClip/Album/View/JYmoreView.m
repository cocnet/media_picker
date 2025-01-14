//
//  JYmoreView.m
//  VideoClip
//
//  Created by yzhon 2019/4/17.
//  Copyright © 2019 admin. All rights reserved.
//

#import "JYmoreView.h"
#import <CoreGraphics/CoreGraphics.h>

#define kPopupTriangleHeigh 12
#define kPopupTriangleWidth 12
#define kBorderOffset     0//0.5f
@implementation JYmoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
} 

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
//    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
//    NSArray *points =[NSArray new];
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGPoint currentPoint = [[points objectAtIndex:6] CGPointValue];
//    CGContextMoveToPoint(ctx, currentPoint.x, currentPoint.y);
//
//    CGPoint pointA, pointB;
//    CGFloat radius;
//
//    int i = 0;
//    while(1) {
//
//        // 整个过程需要7次循环
//        if (i > 6)
//            break;
//
//        // 箭头处(0,1,2三个点)是三个尖角，矩形框是四个圆角
//        radius = i < 3 ?  0 : 10;
//        // radius = i < 3 ? 4 : 10; // 全画成圆角
//        pointA = [[points objectAtIndex:i] CGPointValue];
//        // 画矩形框最后一个圆角的时候，pointB就是points[0]
//        pointB = [[points objectAtIndex:(i+1)%7] CGPointValue];
//
//        CGContextAddArcToPoint(ctx, pointA.x, pointA.y, pointB.x, pointB.y, radius);
//        i = i + 1;
//    }
//
//    // 获取path
//    CGContextClosePath(ctx);
//    CGPathRef path = CGContextCopyPath(ctx);
//    CGContextRelease(ctx);
//
//    // 生成layer
//    self.maskLayer = [CAShapeLayer layer];
//    self.maskLayer.path = path;
    CGFloat viewW = rect.size.width;
    CGFloat viewH = rect.size.height;
    
    CGFloat strokeWidth = 1;
    CGFloat borderRadius = 5;
    CGFloat offset = strokeWidth + kBorderOffset;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineJoin(context, kCGLineJoinRound); //
    CGContextSetLineWidth(context, strokeWidth); // 设置画笔宽度
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor); // 设置画笔颜色
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor); // 设置填充颜色
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, borderRadius+offset, kPopupTriangleHeigh-offset);
    CGContextAddLineToPoint(context, round(viewW -kPopupTriangleWidth) + offset, kPopupTriangleHeigh-offset);
    CGContextAddLineToPoint(context, round(viewW- offset), offset);
    CGContextAddLineToPoint(context, round(viewW- offset), viewH -kPopupTriangleHeigh);
    
    CGContextAddArcToPoint(context, viewW-offset, kPopupTriangleHeigh-offset, viewW-offset, viewH -kPopupTriangleHeigh, borderRadius-strokeWidth);
    CGContextAddArcToPoint(context, viewW-offset, viewH, viewW-borderRadius-offset, viewH, borderRadius-strokeWidth);
    CGContextAddArcToPoint(context, offset, viewH, offset, viewH -borderRadius-offset, borderRadius-strokeWidth);
    CGContextAddArcToPoint(context, offset, kPopupTriangleHeigh-offset, borderRadius+offset, kPopupTriangleHeigh-offset, borderRadius-strokeWidth);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}
@end
