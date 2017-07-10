//
//  NYLockIndicator.h
//  XXDNew
//
//  Created by Akries on 2016/11/17.
//  Copyright © 2016年 Ak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NYLockSudoku;

@protocol NYLockSudokuDelegate <NSObject>

- (void)Sudoku:(NYLockSudoku *)Sudoku passcodeDidCreate:(NSString *)passcode;

@end

@interface NYLockSudoku : UIView

@property (nonatomic, weak) id<NYLockSudokuDelegate> delegate;

- (instancetype)init;
- (void)showErrorPasscode:(NSString *)errorPasscode;
- (void)reset;

@end
