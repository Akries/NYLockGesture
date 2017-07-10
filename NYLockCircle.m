//
//  NYLockIndicator.h
//  XXDNew
//
//  Created by Akries on 2016/11/17.
//  Copyright © 2016年 Ak. All rights reserved.
//

#import "NYLockCircle.h"
#import "NYLockConfig.h"

@interface NYLockCircle ()

@end

@implementation NYLockCircle

- (instancetype)initWithDiameter:(CGFloat)diameter
{
    self = [super initWithFrame:CGRectMake(0, 0, diameter, diameter)];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.diameter = diameter;
        self.state = NYLockCircleStateNormal;
    }
    
    return self;
}

- (void)updateCircleState:(NYLockCircleState)state
{
    [self setState:state];
    [self setNeedsDisplay];
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, kCircleWidth);
    
    if (self.state == NYLockCircleStateNormal)
    {
//        [self drawEmptyCircleWithContext:context
//                                    rect:CGRectMake(kCircleWidth / 2,
//                                                    kCircleWidth / 2,
//                                                    self.diameter - kCircleWidth,
//                                                    self.diameter - kCircleWidth)
//                             strokeColor:NY_LOCK_COLOR_NORMAL
//                               fillColor:NY_LOCK_COLOR_BACKGROUND];
        [self drawSolidCircleWithContext:context
                                    rect:CGRectMake(self.diameter * (0.5 - kCircleCenterRatio / 2),
                                          self.diameter * (0.5 - kCircleCenterRatio / 2),
                                          self.diameter * kCircleCenterRatio,
                                          self.diameter * kCircleCenterRatio)
                             strokeColor:NY_LOCK_COLOR_NORMAL];
    }
    else if (self.state == NYLockCircleStateSelected)//选中
    {
        [self drawCenterCircleWithContext:context
                                     rect:CGRectMake(kCircleWidth / 2,
                                                     kCircleWidth / 2,
                                                     self.diameter - kCircleWidth,
                                                     self.diameter - kCircleWidth)
                               centerRect:CGRectMake(self.diameter * (0.5 - kCircleCenterRatio / 2),
                                                     self.diameter * (0.5 - kCircleCenterRatio / 2),
                                                     self.diameter * kCircleCenterRatio,
                                                     self.diameter * kCircleCenterRatio)
                              strokeColor:NY_LOCK_COLOR_SELECTED
                                fillColor:NY_LOCK_COLOR_BACKGROUND];
    }
    else if (self.state == NYLockCircleStateFill)//指示器
    {
        [self drawSolidCircleWithContext:context
                                    rect:CGRectMake(self.diameter * (0.5 - kCircleCenterRatio / 2),
                                                    self.diameter * (0.5 - kCircleCenterRatio / 2),
                                                    self.diameter * kCircleCenterRatio,
                                                    self.diameter * kCircleCenterRatio)
                             strokeColor:NY_LOCK_COLOR_SELECTED];
    }
    else if (self.state == NYLockCircleStateError)
    {
        [self drawCenterCircleWithContext:context
                                     rect:CGRectMake(kCircleWidth / 2,
                                                     kCircleWidth / 2,
                                                     self.diameter - kCircleWidth,
                                                     self.diameter - kCircleWidth)
                               centerRect:CGRectMake(self.diameter * (0.5 - kCircleCenterRatio / 2),
                                                     self.diameter * (0.5 - kCircleCenterRatio / 2),
                                                     self.diameter * kCircleCenterRatio,
                                                     self.diameter * kCircleCenterRatio)
                              strokeColor:NY_LOCK_COLOR_ERROR
                                fillColor:NY_LOCK_COLOR_BACKGROUND];
    }
}

#pragma mark Private

/**
 空心圆环

 @param context     context
 @param rect        rect
 @param strokeColor strokeColor
 @param fillColor   fillColor
 */
- (void)drawEmptyCircleWithContext:(CGContextRef)context
                              rect:(CGRect)rect
                       strokeColor:(UIColor *)strokeColor
                         fillColor:(UIColor *)fillColor
{
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);//画笔颜色
    CGContextSetFillColorWithColor(context, fillColor.CGColor);//填充颜色
    CGContextAddEllipseInRect(context, rect);//添加一个椭圆
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路劲+填充
}

/**
 实心圆

 @param context     context
 @param rect        rect
 @param strokeColor strokeColor
 */
- (void)drawSolidCircleWithContext:(CGContextRef)context
                              rect:(CGRect)rect
                       strokeColor:(UIColor *)strokeColor
{
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, strokeColor.CGColor);
    CGContextAddEllipseInRect(context, rect);
    CGContextDrawPath(context, kCGPathFillStroke);
}

/**
 圆环 + 中心小圆

 @param context     context
 @param rect        rect
 @param centerRect  centerRect
 @param strokeColor strokeColor
 @param fillColor   fillColor
 */
- (void)drawCenterCircleWithContext:(CGContextRef)context
                               rect:(CGRect)rect
                         centerRect:(CGRect)centerRect
                        strokeColor:(UIColor *)strokeColor
                          fillColor:(UIColor *)fillColor
{
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextAddEllipseInRect(context, rect);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextSetFillColorWithColor(context, strokeColor.CGColor);
    CGContextAddEllipseInRect(context, centerRect);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
