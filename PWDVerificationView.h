//
//  PWDVerificationView.h
//  XXDNew
//
//  Created by Akries.Ni on 2017/5/9.
//  Copyright © 2017年 Xinxindai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ForgetBlock)();
typedef void(^EnterBlock)(NSString *pwd);
typedef void(^CancelBlock)();

@interface PWDVerificationView : UIView
- (instancetype)initWithFrame:(CGRect)frame  CancelBlock:(CancelBlock)cancel EnterBlock:(EnterBlock)enter FrogetBlock:(ForgetBlock)forget;

@property (nonatomic,copy) ForgetBlock forgetBlock;
@property (nonatomic,copy) EnterBlock enterBlock;
@property (nonatomic,copy) CancelBlock cancelBlock;

@end
