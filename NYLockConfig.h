//
//  NYLockIndicator.h
//  XXDNew
//
//  Created by Akries on 2016/11/17.
//  Copyright © 2016年 Ak. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef NYLockConfig_h
#define NYLockConfig_h

// 背景颜色
#define NY_LOCK_COLOR_BACKGROUND [UIColor whiteColor]

// 正常颜色
#define NY_LOCK_COLOR_NORMAL [UIColor colorWithHexString:@"#d1def4"]
// 选中颜色
#define NY_LOCK_COLOR_SELECTED kThemeColor

// 错误提示颜色
#define NY_LOCK_COLOR_ERROR kRedColor

// 重设按钮颜色
#define NY_LOCK_COLOR_BUTTON [UIColor lightGrayColor]

/**
 *  指示器大小
 */
static const CGFloat kIndicatorSideLength = 60.f;

/**
 *  logo大小
 */
static const CGFloat kLogoViewSideLength = 120.f;


/**
 *  九宫格大小
 */
static const CGFloat kSudokuSideLength = 300.f;

/**
 *  圆圈边框粗细(指示器和九宫格的一样粗细)
 */
static const CGFloat kCircleWidth = 0.5f;

/**
 *  指示器轨迹粗细
 */
static const CGFloat kIndicatorTrackWidth = 0.5f;

/**
 *  九宫格轨迹粗细
 */
static const CGFloat kSudokuTrackWidth = 2.f;

/**
 *  圆圈选中效果中心点和圆圈比例 也就是中间点的大小 
 */
static const CGFloat kCircleCenterRatio = 0.3f;

/**
 *  最少连接个数
 */
static const NSInteger kConnectionMinNum = 4;

/**
 *  指示器标签基数tag(不建议更改)
 */
static const NSInteger kIndicatorLevelBase = 1000;

/**
 *  九宫格标签基数tag(不建议更改)
 */
static const NSInteger kSudokuLevelBase = 2000;

/**
 *  手势解锁开关键(不建议更改)
 */
static NSString * const kNYLockGestureUnlockEnabled = @"NYLockGestureUnlockEnabled";

/**
 *  指纹解锁开关键(不建议更改)
 */
static NSString * const kNYLockTouchIdUnlockEnabled = @"NYLockTouchIdUnlockEnabled";

/**
 *  是否开启指纹支付开关键(不建议更改)
 */
static NSString * const kNYLockTouchIdPaymentIsOpen = @"kNYLockTouchIdPaymentIsOpen";

static NSString * const kNYLockTouchIdPayPassword = @"kNYLockTouchIdPayPassword";



/**
 *  手势密码键(不建议更改)
 */
static NSString * const kNYLockPasscode = @"NYLockPasscode";

/**
 *  错误次数
 */
static NSString * const kNYLockPasscodeWrongTime = @"kNYLockPasscodeWrongTime";

/**
 *  提示文本
 */
static NSString * const kNYLockOtherAccountText  = @"其他账号登录";
static NSString * const kNYLockTouchIdText  = @"指纹解锁";
static NSString * const kNYLockResetText    = @"重新设置";
static NSString * const kNYLockNewText      = @"请绘制新密码";
static NSString * const kNYLockVerifyText   = @"请绘制手势密码";
static NSString * const kNYLockVerifyTouchIdText   = @"请验证指纹密码";
static NSString * const kNYLockAgainText    = @"请再次确认新密码";
static NSString * const kNYLockNotMatchText = @"与上次绘制不一致,请重新绘制";
static NSString * const kNYLockReNewText    = @"请重新绘制新密码";
static NSString * const kNYLockReVerifyText = @"请重新绘制密码";
static NSString * const kNYLockOldText      = @"请绘制原手势密码";
static NSString * const kNYLockOldErrorText = @"密码不正确";
static NSString * const kNYLockReOldText    = @"请输入原手势密码";

#define NY_LOCK_NOT_ENOUGH [NSString stringWithFormat:@"至少连接%ld个点，请重新绘制", (long)kConnectionMinNum]

#endif
