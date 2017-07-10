//
//  NYLockIndicator.h
//  XXDNew
//
//  Created by Akries on 2016/11/17.
//  Copyright © 2016年 Ak. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NYLockCircleState)
{
    NYLockCircleStateNormal = 0,
    NYLockCircleStateSelected,
    NYLockCircleStateFill,
    NYLockCircleStateError
};

@interface NYLockCircle : UIView
//类型
@property (nonatomic, assign) NYLockCircleState state;
//直径
@property (nonatomic, assign) CGFloat diameter;

- (instancetype)initWithDiameter:(CGFloat)diameter;
- (void)updateCircleState:(NYLockCircleState)state;

@end
