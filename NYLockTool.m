//
//  NYLockIndicator.h
//  XXDNew
//
//  Created by Akries on 2016/11/17.
//  Copyright © 2016年 Ak. All rights reserved.
//

#import "NYLockTool.h"
#import "NYLockConfig.h"

@implementation NYLockTool

#pragma mark - 手势密码管理

/**
 是否允许手势解锁(应用级别的)
 
 @return BOOL
 */
+ (BOOL)isGestureUnlockEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kNYLockGestureUnlockEnabled];
}

/**
 设置是否允许手势解锁功能
 
 @param enabled enabled
 */
+ (void)setGestureUnlockEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kNYLockGestureUnlockEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 当前已经设置的手势密码
 
 @return NSString
 */
+ (NSString *)currentGesturePasscode
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kNYLockPasscode];
}

/**
 设置新的手势密码
 
 @param passcode passcode
 */
+ (void)setGesturePasscode:(NSString *)passcode
{
    [[NSUserDefaults standardUserDefaults] setObject:passcode forKey:kNYLockPasscode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 指纹解锁管理

/**
 是否支持指纹识别(系统级别的)
 
 @return BOOL
 */
+ (BOOL)isTouchIdSupported
{
    NSError *error;
    
    return [[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
}

/**
 是否允许指纹解锁(应用级别的)
 
 @return BOOL
 */
+ (BOOL)isTouchIdUnlockEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kNYLockTouchIdUnlockEnabled];
}

/**
 设置是否允许指纹解锁功能
 
 @param enabled enabled
 */
+ (void)setTouchIdUnlockEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kNYLockTouchIdUnlockEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 设置是否开启指纹支付
 */
+ (void)setTouchIdPaymentIsOpen:(BOOL)isOpen {
    [[NSUserDefaults standardUserDefaults] setBool:isOpen forKey:kNYLockTouchIdPaymentIsOpen];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 获取用户是否设置指纹支付
 */
+ (BOOL)isTouchIdPaymentOpen {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kNYLockTouchIdPaymentIsOpen];
}

+ (void)setTouchIdPayPassword:(NSString *)payPassword {
    [[NSUserDefaults standardUserDefaults] setObject:[payPassword md5Mod32] forKey:kNYLockTouchIdPayPassword];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)touchIdPayPassword {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kNYLockTouchIdPayPassword];
}

@end
