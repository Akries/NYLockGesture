//
//  NYLockIndicator.h
//  XXDNew
//
//  Created by Akries on 2016/11/17.
//  Copyright © 2016年 Ak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LAContext.h>

@interface NYLockTool : NSObject

#pragma mark - 手势密码管理

/**
 是否允许手势解锁(应用级别的)

 @return BOOL
 */
+ (BOOL)isGestureUnlockEnabled;

/**
 设置是否允许手势解锁功能

 @param enabled enabled
 */
+ (void)setGestureUnlockEnabled:(BOOL)enabled;

/**
 当前已经设置的手势密码

 @return NSString
 */
+ (NSString *)currentGesturePasscode;

/**
 设置新的手势密码

 @param passcode passcode
 */
+ (void)setGesturePasscode:(NSString *)passcode;

#pragma mark - 指纹解锁管理

/**
 是否支持指纹识别(系统级别的)

 @return BOOL
 */
+ (BOOL)isTouchIdSupported;

/**
 是否允许指纹解锁(应用级别的)

 @return BOOL
 */
+ (BOOL)isTouchIdUnlockEnabled;

/**
 设置是否允许指纹解锁功能

 @param enabled enabled
 */
+ (void)setTouchIdUnlockEnabled:(BOOL)enabled;


/**
 设置是否开启指纹支付
 */
+ (void)setTouchIdPaymentIsOpen:(BOOL)isOpen;

/**
 获取用户是否设置指纹支付
 */
+ (BOOL)isTouchIdPaymentOpen;

+ (void)setTouchIdPayPassword:(NSString *)payPassword;

+ (NSString *)touchIdPayPassword;


@end
