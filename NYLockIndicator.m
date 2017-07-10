//
//  NYLockIndicator.h
//  XXDNew
//
//  Created by Akries on 2016/11/17.
//  Copyright © 2016年 Ak. All rights reserved.
//

#import "NYLockIndicator.h"
#import "NYLockConfig.h"
#import "NYLockCircle.h"

@interface NYLockIndicator ()

@property (nonatomic, strong) NSMutableArray *circleArray;//总圈圈
@property (nonatomic, strong) NSMutableArray *selectedCircleArray;//被选中的圈圈
@property (nonatomic, assign) CGFloat        circleMargin;//指示圈圈 间隔 指示器大小/15

@end

@implementation NYLockIndicator

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self setup];
        [self createCircles];
    }
    
    return self;
}

- (void)setup
{
    self.backgroundColor     = [UIColor clearColor];
    self.clipsToBounds       = YES;
    
    self.circleArray         = [NSMutableArray array];
    self.selectedCircleArray = [NSMutableArray array];
    self.circleMargin        = kIndicatorSideLength / 15;
}

- (void)createCircles
{
    for (int i = 0; i < 9; i++)
    {
        float x = self.circleMargin * (4.5 * (i % 3) + 1.5);
        float y = self.circleMargin * (4.5 * (i / 3) + 1.5);
        
        NYLockCircle *circle = [[NYLockCircle alloc] initWithDiameter:self.circleMargin*3];
        [circle setTag:kIndicatorLevelBase + i];
        [circle setFrame:CGRectMake(x, y, self.circleMargin*3, self.circleMargin*3)];
        [self.circleArray addObject:circle];
        [self addSubview:circle];
    }
}

#pragma mark - Public

- (void)showPasscode:(NSString *)passcode
{
    [self reset];
    
    NSMutableArray *numbers = [[NSMutableArray alloc] initWithCapacity:passcode.length];
    for (int i = 0; i < passcode.length; i++)
    {
        NSRange range = NSMakeRange(i, 1);
        NSString *numberStr = [passcode substringWithRange:range];
        NSNumber *number = [NSNumber numberWithInt:numberStr.intValue];
        [numbers addObject:number];
        [self.circleArray[number.intValue] updateCircleState:NYLockCircleStateFill];
        [self.selectedCircleArray addObject:self.circleArray[number.intValue]];
    }
    
    [self setNeedsDisplay];
}

- (void)reset
{
    for (NYLockCircle *circle in self.circleArray)
    {
        [circle updateCircleState:NYLockCircleStateNormal];
    }
    
    [self.selectedCircleArray removeAllObjects];
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect
{
    if (self.selectedCircleArray.count == 0)
    {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, kIndicatorTrackWidth);
    [NY_LOCK_COLOR_SELECTED set];
    
    CGPoint addLines[9];
    int count = 0;
    for (NYLockCircle *circle in self.selectedCircleArray)
    {
        CGPoint point = CGPointMake(circle.center.x, circle.center.y);
        addLines[count++] = point;
    }
    
    CGContextAddLines(context, addLines, count);
    CGContextStrokePath(context);
}

@end
