
//
//  PWDVerificationView.m
//  XXDNew
//
//  Created by Akries.Ni on 2017/5/9.
//  Copyright © 2017年 Xinxindai. All rights reserved.
//

#import "PWDVerificationView.h"

@interface PWDVerificationView()<UITextFieldDelegate>
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *enterBtn;
@property (nonatomic, strong) UIButton *forgetBtn;
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) UIView *lineView;
@property (nonatomic,strong) UILabel *titleLabel;


@end
@implementation PWDVerificationView

- (instancetype)initWithFrame:(CGRect)frame  CancelBlock:(CancelBlock)cancel EnterBlock:(EnterBlock)enter FrogetBlock:(ForgetBlock)forget
{
    if (self = [super initWithFrame:frame]) {
        
        _cancelBlock = cancel;
        _forgetBlock = forget;
        _enterBlock = enter;
        
        [self addSubview:self.cancelBtn];
        [self addSubview:self.enterBtn];
        [self addSubview:self.forgetBtn];
        [self addSubview:self.textField];
        [self addSubview:self.lineView];
        [self addSubview:self.titleLabel];

    }
    return self;
}

- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        UIButton *btn = [AkrHandel createBtnFrame:CGRectMake(10, 140, (SELF_WIDTH - 30)/2, 36) title:NSLocalizedString(@"取消", nil) target:self action:@selector(cancelAction)];
        btn.backgroundColor = [UIColor whiteColor];
        btn.layer.cornerRadius = 2;
        [btn setTitleColor:kALittleMoreGray  forState:UIControlStateNormal];
        btn.layer.borderColor = kALittleGray.CGColor;
        btn.layer.borderWidth = 1;
        _cancelBtn = btn;
    }
    return _cancelBtn;
}

- (UIButton *)enterBtn
{
    if (!_enterBtn) {
        UIButton *btn = [AkrHandel createBtnFrame:CGRectMake((SELF_WIDTH - 30)/2 + 15, 140, (SELF_WIDTH - 30)/2, 36) title:NSLocalizedString(@"确认", nil) target:self action:@selector(enterAction)];
        btn.backgroundColor = kThemeColor;
        btn.layer.cornerRadius = 2;
        [btn setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        _enterBtn = btn;
    }
    return _enterBtn;
}

- (UIButton *)forgetBtn
{
    if (!_forgetBtn) {
        UIButton *btn = [AkrHandel createBtnFrame:CGRectMake(SELF_WIDTH - 90, 110, 80, 20) title:NSLocalizedString(@"忘记密码", nil) target:self action:@selector(forgetAction)];
        _forgetBtn = btn;
        [_forgetBtn setTitleColor:kThemeColor forState:UIControlStateNormal];
    }
    return _forgetBtn;
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [AkrHandel createTextFieldWithFrame:CGRectMake(10, 55, SELF_WIDTH - 20, 36) placeHolder:NSLocalizedString(@"请输入登录密码", nil)];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.delegate = self;
        _textField.secureTextEntry = YES;

    }
    return _textField;
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, SELF_WIDTH - 20, 1)];
        _lineView.backgroundColor = kALittleGray;
    }
    return _lineView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [AkrHandel createLabel:CGRectMake(10, 20, SELF_WIDTH - 20, 20) text:NSLocalizedString(@"验证", nil) alignment:NSTextAlignmentCenter textColor:kALittleMoreGray];
    }
    return _titleLabel;
}

- (void)cancelAction
{
    [_textField resignFirstResponder];
    [[GlobalUtil ShareInstance] recordBigData:[BigDataRecordDic ShareInstance].verifyGesturePsdPageDic To:[BigDataRecordDic ShareInstance].verifyGesturePsdPageDic By:[BigDataRecordDic ShareInstance].verifyGesturePsdPageCancelBtnClickDic];
    if (_cancelBlock) {
        _cancelBlock();
    }
}


- (void)enterAction
{
    [[GlobalUtil ShareInstance] recordBigData:[BigDataRecordDic ShareInstance].verifyGesturePsdPageDic To:[BigDataRecordDic ShareInstance].verifyGesturePsdPageDic By:[BigDataRecordDic ShareInstance].verifyGesturePsdPageSureBtnClickDic];
    if (_textField.text.length == 0) {
        [self tt_showToastWithText:@"请输入登录密码"];
        return;
    }
    if (_textField.text.length < 6) {
        [self tt_showToastWithText:@"密码长度不对"];
        return;
    }
    
    if (![[[DataCenter ShareInstance] userCommonInfoModel] userName]) {
        [self tt_showToastWithText:@"未能获取您的用户信息"];
        return;
    }
    
    [_textField resignFirstResponder];
    if (_enterBlock) {
        _enterBlock(_textField.text);
    }
}

- (void)forgetAction
{
    [_textField resignFirstResponder];
    [[GlobalUtil ShareInstance] recordBigData:[BigDataRecordDic ShareInstance].verifyGesturePsdPageDic To:[BigDataRecordDic ShareInstance].verifyGesturePsdPageDic By:[BigDataRecordDic ShareInstance].resetPageInputPhoneNumDic];
    if (_forgetBlock) {
        _forgetBlock();
    }
}


#pragma mark - 实现代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[GlobalUtil ShareInstance] recordBigData:[BigDataRecordDic ShareInstance].verifyGesturePsdPageDic To:[BigDataRecordDic ShareInstance].verifyGesturePsdPageDic By:[[BigDataRecordDic ShareInstance] verifyGesturePsdPageInputLogPsdDicWithValue:textField.text]];
}
@end
