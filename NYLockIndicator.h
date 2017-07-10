//
//  NYLockIndicator.h
//  XXDNew
//
//  Created by Akries on 2016/11/17.
//  Copyright © 2016年 Ak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NYLockIndicator : UIView

- (instancetype)init;
- (void)showPasscode:(NSString *)passcode;
- (void)reset;

@end
