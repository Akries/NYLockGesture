//
//  NYLockIndicator.h
//  XXDNew
//
//  Created by Akries on 2016/11/17.
//  Copyright © 2016年 Ak. All rights reserved.
//

#import "NYLockTool.h"
#import "NYLockSudoku.h"
#import "NYLockIndicator.h"

/**
 控制器类型
 */
typedef NS_ENUM(NSInteger, NYLockType)
{
    NYLockTypeCreate, ///< 创建密码控制器
    NYLockTypeModify, ///< 修改密码控制器
    NYLockTypeVerify, ///< 验证密码控制器
    NYLockTypeRemove  ///< 移除密码控制器
};

/**
 推出视图方式
 */
typedef NS_ENUM(NSInteger, NYLockAppearMode)
{
    NYLockAppearModePush,
    NYLockAppearModePresent,
    NYLockAppearModeRootView
};

@class NYLockViewController;

@protocol NYLockViewControllerDelegate <NSObject>

@optional

/**
 密码创建成功

 @param passcode passcode
 */
- (void)passcodeDidCreate:(NSString *)passcode;

/**
 密码修改成功

 @param passcode passcode
 */
- (void)passcodeDidModify:(NSString *)passcode;

/**
 密码验证成功

 @param passcode passcode
 */
- (void)passcodeDidVerify:(NSString *)passcode;

/**
 密码移除成功
 */
- (void)passcodeDidRemove;

@end

@interface NYLockViewController : UIViewController

- (instancetype)initWithDelegate:(id<NYLockViewControllerDelegate>)delegate
                            type:(NYLockType)type
                      appearMode:(NYLockAppearMode)appearMode;

@end
