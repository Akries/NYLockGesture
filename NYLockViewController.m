//
//  NYLockIndicator.h
//  XXDNew
//
//  Created by Akries on 2016/11/17.
//  Copyright © 2016年 Ak. All rights reserved.
//

#import "NYLockViewController.h"
#import <LocalAuthentication/LAContext.h>
#import "Masonry.h"
#import "NYLockConfig.h"
#import "PWDVerificationView.h"

#import "LoginAndRegistViewController.h"
#import "ResetPasswordController.h"
typedef NS_ENUM(NSInteger, NYLockStep)
{
    NYLockStepNone = 0,
    NYLockStepCreateNew,
    NYLockStepCreateAgain,
    NYLockStepCreateNotMatch,
    NYLockStepCreateReNew,
    NYLockStepModifyOld,
    NYLockStepModifyOldError,
    NYLockStepModifyReOld,
    NYLockStepModifyNew,
    NYLockStepModifyAgain,
    NYLockStepModifyNotMatch,
    NYLockStepModifyReNew,
    NYLockStepVerifyOld,
    NYLockStepVerifyOldError,
    NYLockStepVerifyReOld,
    NYLockStepRemoveOld,
    NYLockStepRemoveOldError,
    NYLockStepRemoveReOld
};

@interface NYLockViewController () <NYLockSudokuDelegate,UITabBarDelegate,UITabBarControllerDelegate>
@property (nonatomic, strong) DDAnimationManager *animate;

@property (nonatomic, weak) id<NYLockViewControllerDelegate> delegate;
@property (nonatomic, assign) NYLockType       type;//控制器类型
@property (nonatomic, assign) NYLockAppearMode appearMode;//推出视图方式

@property (nonatomic, strong) NYLockIndicator  *indicator;//mini指示器
@property (nonatomic, strong) NYLockSudoku     *Sudoku;//九宫格
@property (nonatomic, strong) UILabel            *noticeLabel;//提示文字
@property (nonatomic, strong) UIButton           *resetButton;//重置按钮

@property (nonatomic,strong) UIButton            *IDButton;//指纹按钮

@property (nonatomic, assign) NYLockStep       step;
@property (nonatomic, strong) NSString           *passcodeTemp;
@property (nonatomic, strong) LAContext          *context;

@property (nonatomic, strong) UIButton           *touchIDBtn;//指纹按钮
@property (nonatomic, strong) UIButton           *otherAccountBtn;//其他账号登录
@property (nonatomic, strong) UIView              *lineView;
@property (nonatomic, strong) UIImageView        *logoView;

@property (nonatomic,strong) PWDVerificationView  *vertifyView;//登录密码
@property (nonatomic,strong) UIView                *bgView;


@property (nonatomic, strong) UILabel             *messLabel;
@property (nonatomic, strong) UIButton            *noremindBtn;
@property (nonatomic, strong) UIButton             *nextBtn;

@property (nonatomic, assign) NSInteger           wrongTime;

@end

@implementation NYLockViewController

#pragma mark - Override
- (void)viewWillAppear:(BOOL)animated
{
    
    self.tabBarController.delegate = self;
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    if ([AkrUSERDEFAULT objectForKey:kNYLockPasscodeWrongTime]) {
        _wrongTime = [[AkrUSERDEFAULT objectForKey:kNYLockPasscodeWrongTime] integerValue];
    }else{
        _wrongTime = 0;
    }
    if (_type == NYLockTypeVerify) {//验证密码
        if (![NYLockTool isGestureUnlockEnabled]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.tabBarController.tabBar.hidden = NO;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
    [self createViews];
    
    switch (self.type)
    {
        case NYLockTypeCreate:
        {
            [self updateUiForStep:NYLockStepCreateNew];
            kSetNavTitleAttribute(NSLocalizedString(@"设置手势密码", nil));
            [self initNavVerify:NO];
        }
            break;
        case NYLockTypeModify:
        {
            kSetNavTitleAttribute(NSLocalizedString(@"修改手势密码", nil));
            [_otherAccountBtn setTitle:NSLocalizedString(@"验证登录密码", nil) forState:UIControlStateNormal];

            [self updateUiForStep:NYLockStepModifyOld];
        }
            break;
        case NYLockTypeVerify:
        {
            [self updateUiForStep:NYLockStepVerifyOld];
            
            if ([NYLockTool isTouchIdUnlockEnabled] && [NYLockTool isTouchIdSupported])
            {
                [self showTouchIdView];
            }
            [self initNavVerify:YES];
        }
            break;
        case NYLockTypeRemove:
        {
            [_otherAccountBtn setTitle:NSLocalizedString(@"验证登录密码", nil) forState:UIControlStateNormal];
            [self updateUiForStep:NYLockStepRemoveOld];
            kSetNavTitleAttribute(NSLocalizedString(@"关闭手势密码", nil));

        }
            break;
        default:
            break;
    }
    
   
}

- (void)initNavVerify:(BOOL)yesOrNo
{
    UIButton *btn;
    if (yesOrNo) {
        
        btn = [AkrHandel createBtnFrame:CGRectMake(0, 0, 40, 40) bgImage:nil image:@"  " title:nil target:self action:@selector(hahaha)];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
        spaceItem.width = -20;
        
        
        self.navigationItem.leftBarButtonItems = @[spaceItem,leftItem];
        
    }else{
        //        btn = [AkrHandel createBtnFrame:CGRectMake(0, 0, 40, 40) bgImage:nil image:@"返回" title:nil target:self action:@selector(turnBackToMainViewConttoller)];
    }
}

#pragma mark - Init

- (instancetype)initWithDelegate:(id<NYLockViewControllerDelegate>)delegate
                            type:(NYLockType)type
                      appearMode:(NYLockAppearMode)appearMode
{
    self = [super init];
    
    if (self)
    {
        self.delegate   = delegate;
        self.type       = type;
        self.appearMode = appearMode;
    }
    
    return self;
}

- (void)setup
{
    self.view.backgroundColor = NY_LOCK_COLOR_BACKGROUND;
    self.step = NYLockStepNone;
    self.context = [[LAContext alloc] init];
    _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    _bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bgView];

}

- (void)createViews
{
    NYLockSudoku *Sudoku = [[NYLockSudoku alloc] init];
    [Sudoku setDelegate:self];
    [self.view addSubview:Sudoku];
    [self setSudoku:Sudoku];
    [Sudoku setFrame:CGRectMake(SCREEN_WIDTH/2 - kSudokuSideLength/2, SCREEN_HEIGHT/2 - 100, kSudokuSideLength, kSudokuSideLength)];
    
    UILabel *noticeLabel = [[UILabel alloc] init];
    noticeLabel.font = kTextMiddleFont;
    [noticeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:noticeLabel];
    [self setNoticeLabel:noticeLabel];
    [noticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(20);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(Sudoku.mas_top).offset(-1);
    }];
    
    
    NYLockIndicator *indicator = [[NYLockIndicator alloc] init];
    [self.view addSubview:indicator];
    [self setIndicator:indicator];
    [indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(noticeLabel.mas_top).offset(0);
        make.size.mas_equalTo(CGSizeMake(kIndicatorSideLength, kIndicatorSideLength));
    }];
    
    UILabel *messLabel = [AkrHandel createLabel:CGRectZero text:NSLocalizedString(@"设置手势密码,可保证账户安全", nil) alignment:NSTextAlignmentCenter textColor:kThemeColor];
    [self.view addSubview:messLabel];
    messLabel.font = kTextMiddleFont;
        [self setMessLabel:messLabel];
    [messLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(90);
        make.height.equalTo(@20);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
    }];

    UIImageView *logoView = [[UIImageView alloc] init];
    logoView.image = [UIImage imageNamed:@"logo_XXD"];
    [self.view addSubview:logoView];
    [self setLogoView:logoView];
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(noticeLabel.mas_top).offset(-10);
        make.size.mas_equalTo(CGSizeMake(kLogoViewSideLength, kLogoViewSideLength));
    }];

    UIButton *IDButton = [AkrHandel createBtnFrame:CGRectMake(SCREEN_WIDTH/2 - 40, SCREEN_HEIGHT/2 - 60, 80, 120) bgImage:nil image:@"touchId" title:@"" target:self action:@selector(showTouchIdView)];
    [self.view addSubview:IDButton];
    [self setIDButton:IDButton];
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [resetButton setTitle:kNYLockResetText forState:UIControlStateNormal];
    [resetButton setTitleColor:NY_LOCK_COLOR_BUTTON forState:UIControlStateNormal];
    [resetButton.titleLabel setFont:kTextSmallFont];
    [resetButton addTarget:self action:@selector(resetButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    [self setResetButton:resetButton];
    [resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(Sudoku.mas_bottom).offset(0);
        make.height.mas_equalTo(20);
    }];
    
//    int paddingUp = 40;
//    
//    UIButton *noremindBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [noremindBtn setTitle:@"不再提醒" forState:UIControlStateNormal];
//    [noremindBtn setTitleColor:NY_LOCK_COLOR_BUTTON forState:UIControlStateNormal];
//    [noremindBtn.titleLabel setFont:kTextMiddleFont];
//    [noremindBtn addTarget:self action:@selector(noRemindAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:noremindBtn];
//    [self setNoremindBtn:noremindBtn];
//    
//    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [nextBtn setTitle:@"下次再说" forState:UIControlStateNormal];
//    [nextBtn setTitleColor:NY_LOCK_COLOR_BUTTON forState:UIControlStateNormal];
//    [nextBtn.titleLabel setFont:kTextMiddleFont];
//    [nextBtn addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:nextBtn];
//    [self setNextBtn:nextBtn];
//    
//    [noremindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).with.offset(80);
//        make.bottom.equalTo(self.view).with.offset(-70);
//        make.right.equalTo(nextBtn.mas_left).with.offset(-paddingUp);
//        make.height.mas_equalTo(@20);
//        make.width.equalTo(nextBtn);
//    }];
//    
//    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.view).with.offset(-80);
//        make.bottom.equalTo(self.view).with.offset(-70);
//        make.left.equalTo(noremindBtn.mas_right).with.offset(paddingUp);
//        make.height.mas_equalTo(@20);
//        make.width.equalTo(noremindBtn);
//    }];

    
    
    

//    int padding = 10;
//    
//    UIButton *touchIDBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [touchIDBtn setTitle:kNYLockTouchIdText forState:UIControlStateNormal];
//    [touchIDBtn setTitleColor:NY_LOCK_COLOR_BUTTON forState:UIControlStateNormal];
//    [touchIDBtn.titleLabel setFont:kTextSmallFont];
//    [touchIDBtn addTarget:self action:@selector(touchIDBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:touchIDBtn];
//    [self setTouchIDBtn:touchIDBtn];
    
    UIButton *otherAccountBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [otherAccountBtn setTitle:kNYLockOtherAccountText forState:UIControlStateNormal];
    [otherAccountBtn setTitleColor:kThemeColor forState:UIControlStateNormal];
    [otherAccountBtn.titleLabel setFont:kTextMiddleFont];
    [otherAccountBtn addTarget:self action:@selector(otherAccountClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:otherAccountBtn];
    [self setOtherAccountBtn:otherAccountBtn];
    
//    [touchIDBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).with.offset(80);
//        make.bottom.equalTo(self.view).with.offset(-70);
//        make.right.equalTo(otherAccountBtn.mas_left).with.offset(-padding);
//        make.height.mas_equalTo(@20);
//        make.width.equalTo(otherAccountBtn);
//    }];
    
//    [otherAccountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//         make.right.equalTo(self.view).with.offset(-80);
//        make.bottom.equalTo(self.view).with.offset(-70);
//        make.left.equalTo(touchIDBtn.mas_right).with.offset(padding);
//        make.height.mas_equalTo(@20);
//        make.width.equalTo(otherAccountBtn);
//    }];
    
    [otherAccountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-70);
        make.height.mas_equalTo(@20);
        make.width.equalTo(@100);
    }];
    
//    UIView *lineView = [[UIView alloc] init];
//    lineView.backgroundColor = NY_LOCK_COLOR_BUTTON;
//    [self.view addSubview:lineView];
//    [self setLineView:lineView];
//    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.view);
//        make.bottom.equalTo(self.view).with.offset(-72);
//        make.height.mas_equalTo(@16);
//        make.width.mas_equalTo(@0.5);
//    }];
}

#pragma mark - Private

- (void)showTouchIdView
{
    [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                 localizedReason:@"通过验证指纹解锁"
                           reply:^(BOOL success, NSError * _Nullable error) {
                               if (success)
                               {
                                   if ([self.delegate respondsToSelector:@selector(passcodeDidVerify:)])
                                   {
                                       [self.delegate passcodeDidVerify:[AkrUSERDEFAULT objectForKey:kNYLockPasscode]];
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self hide];
                                   });
                               }
                           }];
}

- (void)updateUiForStep:(NYLockStep)step
{
    self.step = step;
    
    switch (step)
    {
        case NYLockStepCreateNew:
        {
            self.noticeLabel.text = kNYLockNewText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_SELECTED;
            self.indicator.hidden = NO;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = YES;
            self.lineView.hidden = YES;
            self.logoView.hidden = YES;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
            
            self.messLabel.hidden = NO;
            self.noremindBtn.hidden = NO;
            self.nextBtn.hidden = NO;
        }
            break;
        case NYLockStepCreateAgain:
        {
            self.noticeLabel.text = kNYLockAgainText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_SELECTED;
            self.indicator.hidden = NO;
            self.resetButton.hidden = NO;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = YES;
            self.lineView.hidden = YES;
            self.logoView.hidden = YES;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
            
            self.messLabel.hidden = NO;
            self.noremindBtn.hidden = NO;
            self.nextBtn.hidden = NO;
        }
            break;
        case NYLockStepCreateNotMatch:
        {
            self.noticeLabel.text = kNYLockNotMatchText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_ERROR;
            self.indicator.hidden = NO;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = YES;
            self.lineView.hidden = YES;
            self.logoView.hidden = YES;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
            
            self.messLabel.hidden = NO;
            self.noremindBtn.hidden = NO;
            self.nextBtn.hidden = NO;
        }
            break;
        case NYLockStepCreateReNew:
        {
            self.noticeLabel.text = kNYLockReNewText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_SELECTED;
            self.indicator.hidden = NO;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = YES;
            self.lineView.hidden = YES;
            self.logoView.hidden = YES;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
            
            self.messLabel.hidden = NO;
            self.noremindBtn.hidden = NO;
            self.nextBtn.hidden = NO;
        }
            break;
        case NYLockStepModifyOld:
        {
            self.noticeLabel.text = kNYLockOldText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_SELECTED;
            self.indicator.hidden = YES;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.logoView.hidden = NO;
            self.otherAccountBtn.hidden = NO;
            self.lineView.hidden = YES;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
        }
            break;
        case NYLockStepModifyOldError:
        {
            self.noticeLabel.text = kNYLockOldErrorText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_ERROR;
            self.indicator.hidden = YES;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = NO;
            self.lineView.hidden = YES;
            self.logoView.hidden = NO;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
        }
            break;
        case NYLockStepModifyReOld:
        {
            self.noticeLabel.text = kNYLockReOldText;
            if (_wrongTime > 0) {
                self.noticeLabel.text = [NSString stringWithFormat:@"密码错误，还可以再输入%ld次",5 - _wrongTime];
            }
            self.noticeLabel.textColor = NY_LOCK_COLOR_SELECTED;
            self.indicator.hidden = YES;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = NO;
            self.lineView.hidden = YES;
            self.logoView.hidden = NO;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
        }
            break;
        case NYLockStepModifyNew:
        {
            self.noticeLabel.text = kNYLockNewText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_SELECTED;
            self.indicator.hidden = YES;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = NO;
            self.lineView.hidden = YES;
            self.logoView.hidden = NO;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
        }
            break;
        case NYLockStepModifyAgain:
        {
            self.noticeLabel.text = kNYLockAgainText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_SELECTED;
            self.indicator.hidden = NO;
            self.resetButton.hidden = NO;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = NO;
            self.lineView.hidden = YES;
            self.logoView.hidden = NO;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
        }
            break;
        case NYLockStepModifyNotMatch:
        {
            self.noticeLabel.text = kNYLockNotMatchText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_ERROR;
            self.indicator.hidden = YES;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = NO;
            self.lineView.hidden = YES;
            self.logoView.hidden = NO;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
        }
            break;
        case NYLockStepModifyReNew:
        {
            self.noticeLabel.text = kNYLockReNewText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_SELECTED;
            self.indicator.hidden = YES;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = NO;
            self.lineView.hidden = YES;
            self.logoView.hidden = NO;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
        }
            break;
        case NYLockStepVerifyOld:
        {
            
            if ([NYLockTool isGestureUnlockEnabled]) {
                self.noticeLabel.text = kNYLockVerifyText;
            }else if ([NYLockTool isTouchIdUnlockEnabled]){
                self.noticeLabel.text = kNYLockVerifyTouchIdText;
            }
            
            self.noticeLabel.textColor = NY_LOCK_COLOR_SELECTED;
            self.indicator.hidden = YES;
            self.resetButton.hidden = YES;
            self.logoView.hidden = NO;
            self.otherAccountBtn.hidden = NO;
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
            
            if ([NYLockTool isTouchIdUnlockEnabled] && [NYLockTool isTouchIdSupported])
            {
                self.touchIDBtn.hidden = NO;
                self.lineView.hidden = NO;
                
                self.Sudoku.hidden = YES;
                self.IDButton.hidden = NO;
            }
            else
            {
                self.touchIDBtn.hidden = YES;
                self.lineView.hidden = YES;
                
                self.Sudoku.hidden = NO;
                self.IDButton.hidden = YES;
            }
        }
            break;
        case NYLockStepVerifyOldError:
        {
            self.noticeLabel.text = kNYLockOldErrorText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_ERROR;
            self.indicator.hidden = YES;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = NO;
            self.lineView.hidden = YES;
            self.logoView.hidden = NO;
            
            if ([NYLockTool isTouchIdUnlockEnabled] && [NYLockTool isTouchIdSupported])
            {
                self.Sudoku.hidden = YES;
                self.IDButton.hidden = NO;
            }
            else
            {
                self.Sudoku.hidden = NO;
                self.IDButton.hidden = YES;
            }
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
        }
            break;
        case NYLockStepVerifyReOld:
        {
            self.noticeLabel.text = kNYLockReVerifyText;
            if (_wrongTime > 0) {
                self.noticeLabel.text = [NSString stringWithFormat:@"密码错误，还可以再输入%ld次",5 - _wrongTime];
            }
            self.noticeLabel.textColor = NY_LOCK_COLOR_SELECTED;
            self.indicator.hidden = YES;
            self.resetButton.hidden = YES;
            self.logoView.hidden = NO;
            self.otherAccountBtn.hidden = NO;
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
            
            
            if ([NYLockTool isTouchIdUnlockEnabled] && [NYLockTool isTouchIdSupported])
            {
                self.touchIDBtn.hidden = NO;
                self.lineView.hidden = NO;
                
                self.Sudoku.hidden = YES;
                self.IDButton.hidden = NO;
            }
            else
            {
                self.touchIDBtn.hidden = YES;
                self.lineView.hidden = YES;
                
                self.Sudoku.hidden = NO;
                self.IDButton.hidden = YES;
            }
        }
            break;
        case NYLockStepRemoveOld:
        {
            self.noticeLabel.text = kNYLockOldText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_SELECTED;
            self.indicator.hidden = YES;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = NO;
            self.lineView.hidden = YES;
            self.logoView.hidden = NO;
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
        }
            break;
        case NYLockStepRemoveOldError:
        {
            self.noticeLabel.text = kNYLockOldErrorText;
            self.noticeLabel.textColor = NY_LOCK_COLOR_ERROR;
            self.indicator.hidden = YES;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = YES;
            self.lineView.hidden = YES;
            self.logoView.hidden = NO;
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
        }
            break;
        case NYLockStepRemoveReOld:
        {
            self.noticeLabel.text = kNYLockReOldText;
            if (_wrongTime > 0) {
                self.noticeLabel.text = [NSString stringWithFormat:@"密码错误，还可以再输入%ld次",5 - _wrongTime];
            }
            self.noticeLabel.textColor = NY_LOCK_COLOR_SELECTED;
            self.indicator.hidden = YES;
            self.resetButton.hidden = YES;
            self.touchIDBtn.hidden = YES;
            self.otherAccountBtn.hidden = YES;
            self.lineView.hidden = YES;
            self.logoView.hidden = NO;
            
            self.messLabel.hidden = YES;
            self.noremindBtn.hidden = YES;
            self.nextBtn.hidden = YES;
            
            self.Sudoku.hidden = NO;
            self.IDButton.hidden = YES;
        }
        default:
            break;
    }
}

- (void)shakeAnimationForView:(UIView *)view
{
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint left = CGPointMake(position.x - 10, position.y);
    CGPoint right = CGPointMake(position.x + 10, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:left]];
    [animation setToValue:[NSValue valueWithCGPoint:right]];
    [animation setAutoreverses:YES];
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    [viewLayer addAnimation:animation forKey:nil];
}

#pragma mark - Action事件
#pragma mark -
- (void)hide
{
    if (self.appearMode == NYLockAppearModePush)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (self.appearMode == NYLockAppearModePresent)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else if (self.appearMode == NYLockAppearModeRootView)//程序启动  解锁
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(passcodeDidVerify:)])
            {
                [self.delegate passcodeDidVerify:@"0000"];
            }
        });
    }

}


- (void)resetButtonClicked
{
     [[GlobalUtil ShareInstance] recordBigData:[BigDataRecordDic ShareInstance].setGesturePsdSurePageDic To:[BigDataRecordDic ShareInstance].setGesturePsdSurePageDic By:[BigDataRecordDic ShareInstance].setGesturePsdSurePageResetClickDic];
    [self.indicator showPasscode:@""];
    if (self.type == NYLockTypeCreate)
    {
        [self updateUiForStep:NYLockStepCreateNew];
    }
    else if (self.type == NYLockTypeModify)
    {
        [self updateUiForStep:NYLockStepModifyNew];
    }
}

- (void)touchIDBtnClicked
{
    [self showTouchIdView];
}

- (void)otherAccountClicked//其他账号
{
    
    if (self.type == NYLockTypeVerify){
         [[GlobalUtil ShareInstance] recordBigData:[BigDataRecordDic ShareInstance].verifyGesturePsdPageDic To:[BigDataRecordDic ShareInstance].verifyGesturePsdPageDic By:[BigDataRecordDic ShareInstance].verifyGesturePsdPageVerifyLogPsd];
        NYAlertView *nyAlert = [[NYAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"更换账号登录", nil)];
        [nyAlert addBtnTitle:NSLocalizedString(@"重新登录", nil) action:^{
            
            [[GlobalUtil ShareInstance]removeAllUserDefault];
            [NYLockTool setGestureUnlockEnabled:NO];
            [NYLockTool setTouchIdUnlockEnabled:NO];
            [NYLockTool setTouchIdPaymentIsOpen:NO];
            [NYLockTool setTouchIdPayPassword:nil];
            [AkrUSERDEFAULT removeObjectForKey:kNYLockPasscode];
            [AkrUSERDEFAULT removeObjectForKey:kNYLockPasscodeWrongTime];//错误密码次数
            [AkrUSERDEFAULT removeObjectForKey:riskSelectedKey];
            [AkrUSERDEFAULT removeObjectForKey:kHomeProfitListDateKey];
            [AkrUSERDEFAULT removeObjectForKey:kNYLockTouchIdPayPassword];
            [AkrUSERDEFAULT removeObjectForKey:kRDVTabPreviousKey];
            [AkrUSERDEFAULT removeObjectForKey:kCurrentComimitTime];
            [DataCenter destroyDataCenter];// 销毁dataCenter
            
            
            DDWS(weakSelf)
            LoginAndRegistViewController *rlv = [[LoginAndRegistViewController alloc]init];
            [rlv setWrongTimelimitNoLoginBlock:^{
                
                if (self.appearMode == NYLockAppearModePush){
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                }else if (self.appearMode == NYLockAppearModePresent){
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }else if (self.appearMode == NYLockAppearModeRootView){//程序启动  解锁
                    if ([weakSelf.delegate respondsToSelector:@selector(passcodeDidVerify:)])
                    {
                        [weakSelf.delegate passcodeDidVerify:@"wrongTime"];
                    }
                }
            }];
            [self presentViewController:rlv animated:YES completion:^{
            }];

        }];[nyAlert addBtnTitle:NSLocalizedString(@"取消", nil) action:^{
            
        }];
        [nyAlert showAlertWithSender:self];
    }else{
        _otherAccountBtn.enabled = NO;
        [self showVerifyView:_otherAccountBtn];
    }
}

- (DDAnimationManager *)animate {
    if (!_animate) {
        _animate = [[DDAnimationManager alloc]init];
    }
    return _animate;
}

- (PWDVerificationView *)vertifyView
{
    DDWS(weakSelf);
    if (!_vertifyView) {
        _vertifyView = [[PWDVerificationView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - kSudokuSideLength/2, - 320, kSudokuSideLength, 320)CancelBlock:^{
            [weakSelf.animate popSpringSlide:weakSelf.vertifyView
                                      ToRect:CGRectMake(SCREEN_WIDTH/2 - kSudokuSideLength/2, ViewHeight + 320, kSudokuSideLength, 320)
                                ComleteBlock:^(id res) {
                                }];
            [_bgView removeFromSuperview];
            _otherAccountBtn.enabled = YES;
        } EnterBlock:^(NSString *pwd){
            
            DDWS(weakSelf)
            AkrLog(@"mima======%@",[[pwd md5Mod32] md5Mod32]);
            NSDictionary *dic = @{@"userName":[[[DataCenter ShareInstance] userCommonInfoModel] userName],
                                      @"password":[[pwd md5Mod32] md5Mod32]};
            [[UtilSupportClass ShareInstance]showProgress:NSLocalizedString(@"验证中...", @"") ViewController:weakSelf];
            [[HttpCenter ShareInstance]userLoginPostHttp:dic
                                            SuccessBlock:^(id res) {
                                                AkrLog(@"successed====%@",res);
                                                [DataCenter ShareInstance].userCommonInfoModel = [UserCommonInfoModel xxd_objFromKeyValue:res[@"data"]];
                                                [[UtilSupportClass ShareInstance]hideProgress];
//                                                [weakSelf.view tt_showToastWithText:@"手势密码已移除"];
//                                                [NYLockTool setGestureUnlockEnabled:NO];
//                                                [NYLockTool setTouchIdUnlockEnabled:NO];
//                                                [AkrUSERDEFAULT removeObjectForKey:kNYLockPasscode];
//                                                [AkrUSERDEFAULT removeObjectForKey:kNYLockPasscodeWrongTime];//错误密码次数
//                                                [weakSelf.navigationController popViewControllerAnimated:YES];
                                                [weakSelf updateUiForStep:NYLockStepModifyNew];
                                                [AkrUSERDEFAULT removeObjectForKey:kNYLockPasscodeWrongTime];//错误密码次数
                                                [weakSelf.animate popSpringSlide:weakSelf.vertifyView
                                                                          ToRect:CGRectMake(SCREEN_WIDTH/2 - kSudokuSideLength/2, ViewHeight + 320, kSudokuSideLength, 320)
                                                                    ComleteBlock:^(id res) {
                                                                    }];
                                                _otherAccountBtn.enabled = YES;
                                                
                                                
                                            }
                                             FailedBlock:^(id res) {
                                                 DDLog(@"failed====%@",res);
                                                 [[UtilSupportClass ShareInstance]hideProgress];
                                                 if ([res isKindOfClass:[NSString class]]) {
                                                     [weakSelf.view tt_showToastWithText:res];
                                                 }
                                                 _otherAccountBtn.enabled = YES;
                                             }];
            [_bgView removeFromSuperview];
        } FrogetBlock:^{
//            [weakSelf.animate popSpringSlide:weakSelf.vertifyView
//                                      ToRect:CGRectMake(SCREEN_WIDTH/2 - kSudokuSideLength/2, ViewHeight + 320, kSudokuSideLength, 320)
//                                ComleteBlock:^(id res) {
//                                }];
            [_bgView removeFromSuperview];
//            NYAlertView *alertView = [[NYAlertView alloc] initWithTitle:NSLocalizedString(@"忘记密码", nil) message:NSLocalizedString(@"立刻返回安全中心,重置登录密码->",nil)];
//            [alertView addBtnTitle:@"算了,不改了" action:^{
//                
//                _otherAccountBtn.enabled = YES;
//            }];[alertView addBtnTitle:@"立刻返回修改" action:^{
//                
//                [weakSelf.navigationController popViewControllerAnimated:YES];
//                _otherAccountBtn.enabled = YES;
//            }];
//            [alertView showAlertWithSender:self];
            
//            _otherAccountBtn.enabled = YES;
            ResetPasswordController *resetCtr = [[ResetPasswordController alloc] init];
            [weakSelf.navigationController pushViewController:resetCtr animated:YES];
            
        }];
        
        [self.view addSubview:self.vertifyView];
        
    }
    _vertifyView.backgroundColor = [UIColor whiteColor];
    return _vertifyView;
}

- (void)showVerifyView:(UIButton *)sender {
    DDWS(weakSelf);
    [self.animate popSpringSlide:weakSelf.vertifyView
                          ToRect:CGRectMake(SCREEN_WIDTH/2 - kSudokuSideLength/2, SCREEN_HEIGHT / 2 - 120, kSudokuSideLength, 320)
                    ComleteBlock:^(id res) {
                    }];
}
- (void)noRemindAction
{
    NYAlertView *nyAlert = [[NYAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"如需开启手势密码,可前往系统设置->手势密码设置打开", nil)];
    [nyAlert addBtnTitle:NSLocalizedString(@"知道了", nil) action:^{

        [self hide];
    }];
    [nyAlert showAlertWithSender:self];
}




- (void)turnBackToMainViewConttoller
{
    switch (self.type)
    {
        case NYLockTypeCreate:
        {
//            [AkrUSERDEFAULT setObject:@"kNYLockRemindNextTimenextTime" forKey:kNYLockRemindNextTime];
//            [AkrUSERDEFAULT synchronize];
            [self hide];
            
        }
            break;
        default:
            break;
    }

}

- (void)hahaha
{
    AkrLog(@"啥也不干  哈哈哈");
}


#pragma mark - NYLockSudokuDelegate

- (void)Sudoku:(NYLockSudoku *)Sudoku passcodeDidCreate:(NSString *)passcode
{
    if ([passcode length] < kConnectionMinNum)
    {
        [self.noticeLabel setText:NY_LOCK_NOT_ENOUGH];
        [self.noticeLabel setTextColor:NY_LOCK_COLOR_ERROR];
        [self shakeAnimationForView:self.noticeLabel];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateUiForStep:self.step];
        });
        
        return;
    }
    
    switch (self.step)
    {
        case NYLockStepCreateNew:
        case NYLockStepCreateReNew:
        {
            self.passcodeTemp = passcode;
            [self updateUiForStep:NYLockStepCreateAgain];
            [[GlobalUtil ShareInstance] recordBigData:[BigDataRecordDic ShareInstance].setGesturePsdOnePageDic To:[BigDataRecordDic ShareInstance].setGesturePsdOnePageDic By:[[BigDataRecordDic ShareInstance] setGesturePsdOnePageBeginClickDicWithValue:passcode]];
        }
            break;
        case NYLockStepCreateAgain:
        {
            if ([passcode isEqualToString:self.passcodeTemp])
            {
                [[GlobalUtil ShareInstance] recordBigData:[BigDataRecordDic ShareInstance].setGesturePsdSurePageDic To:[BigDataRecordDic ShareInstance].setGesturePsdSurePageDic By:[[BigDataRecordDic ShareInstance] setGesturePsdSurePageBeginClickDicWithValue:passcode]];
                
                [NYLockTool setGestureUnlockEnabled:YES];
                [NYLockTool setGesturePasscode:passcode];
                
                if ([self.delegate respondsToSelector:@selector(passcodeDidCreate:)])
                {
                    [self.delegate passcodeDidCreate:passcode];
                    
                }
                [self hide];
            }
            else
            {
                [self updateUiForStep:NYLockStepCreateNotMatch];
                [self.Sudoku showErrorPasscode:passcode];
                [self shakeAnimationForView:self.noticeLabel];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self updateUiForStep:NYLockStepCreateReNew];
                });
            }
        }
            break;
        case NYLockStepModifyOld:
        case NYLockStepModifyReOld:
        {
            if ([passcode isEqualToString:[NYLockTool currentGesturePasscode]])
            {
                [self updateUiForStep:NYLockStepModifyNew];
                
                [AkrUSERDEFAULT removeObjectForKey:kNYLockPasscodeWrongTime];//错误密码次数
            }
            else
            {
                [self updateUiForStep:NYLockStepModifyOldError];
                [self.Sudoku showErrorPasscode:passcode];
                [self shakeAnimationForView:self.noticeLabel];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self updateUiForStep:NYLockStepModifyReOld];
                });
                
                [self ifWrongDosthShowSth];
            }
        }
            break;
        case NYLockStepModifyNew:
        case NYLockStepModifyReNew:
        {
            self.passcodeTemp = passcode;
            [self updateUiForStep:NYLockStepModifyAgain];
        }
            break;
        case NYLockStepModifyAgain:
        {
            if ([passcode isEqualToString:self.passcodeTemp])
            {
                [NYLockTool setGestureUnlockEnabled:YES];
                [NYLockTool setGesturePasscode:passcode];
                
                if ([self.delegate respondsToSelector:@selector(passcodeDidModify:)])
                {
                    [self.delegate passcodeDidModify:passcode];
                }
                
                [self hide];
            }
            else
            {
                [self updateUiForStep:NYLockStepModifyNotMatch];
                [self.Sudoku showErrorPasscode:passcode];
                [self shakeAnimationForView:self.noticeLabel];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self updateUiForStep:NYLockStepModifyReNew];
                });
            }
        }
            break;
        case NYLockStepVerifyOld:
        case NYLockStepVerifyReOld:
        {
            if ([passcode isEqualToString:[NYLockTool currentGesturePasscode]])
            {
                [AkrUSERDEFAULT removeObjectForKey:kNYLockPasscodeWrongTime];//错误密码次数
                
                if ([self.delegate respondsToSelector:@selector(passcodeDidVerify:)])
                {
                    [self.delegate passcodeDidVerify:passcode];
                }
                
                [self hide];
                
            }
            else
            {
                [self updateUiForStep:NYLockStepVerifyOldError];
                [self.Sudoku showErrorPasscode:passcode];
                [self shakeAnimationForView:self.noticeLabel];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self updateUiForStep:NYLockStepVerifyReOld];
                });
                
                
                [self ifWrongDosthShowSth];

                
            }
        }
            break;
        case NYLockStepRemoveOld:
        case NYLockStepRemoveReOld:
        {
            if ([passcode isEqualToString:[NYLockTool currentGesturePasscode]])
            {
                
                [AkrUSERDEFAULT removeObjectForKey:kNYLockPasscodeWrongTime];//错误密码次数
                [NYLockTool setGestureUnlockEnabled:NO];
                
                if ([self.delegate respondsToSelector:@selector(passcodeDidRemove)])
                {
                    [self.delegate passcodeDidRemove];
                }
                
                [self hide];
            }
            else
            {
                [self updateUiForStep:NYLockStepRemoveOldError];
                [self.Sudoku showErrorPasscode:passcode];
                [self shakeAnimationForView:self.noticeLabel];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self updateUiForStep:NYLockStepRemoveReOld];
                });
                
                [self ifWrongDosthShowSth];
                
            }
        }
            break;
        default:
            break;
    }
    
    [self.indicator showPasscode:passcode];
}

- (void)ifWrongDosthShowSth
{
    _wrongTime += 1;
    self.noticeLabel.text = [NSString stringWithFormat:@"密码错误，还可以再输入%ld次",5 - _wrongTime];
    [AkrUSERDEFAULT setObject:[NSString stringWithFormat:@"%ld",_wrongTime] forKey:kNYLockPasscodeWrongTime];
    if (_wrongTime > 4) {
        [self quitAndLogin];
    }
}

- (void)quitAndLogin
{
    [[GlobalUtil ShareInstance]removeAllUserDefault];
    [NYLockTool setGestureUnlockEnabled:NO];
    [NYLockTool setTouchIdUnlockEnabled:NO];
    [NYLockTool setTouchIdPaymentIsOpen:NO];
    [NYLockTool setTouchIdPayPassword:nil];
    [AkrUSERDEFAULT removeObjectForKey:kNYLockPasscode];
    [AkrUSERDEFAULT removeObjectForKey:kNYLockPasscodeWrongTime];//错误密码次数
    [AkrUSERDEFAULT removeObjectForKey:riskSelectedKey];
    [AkrUSERDEFAULT removeObjectForKey:kHomeProfitListDateKey];
    [AkrUSERDEFAULT removeObjectForKey:kNYLockTouchIdPayPassword];
    [AkrUSERDEFAULT removeObjectForKey:kRDVTabPreviousKey];
    [AkrUSERDEFAULT removeObjectForKey:kCurrentComimitTime];
    [DataCenter destroyDataCenter];// 销毁dataCenter

    
    DDWS(weakSelf);
    LoginAndRegistViewController *rlv = [[LoginAndRegistViewController alloc]init];
    [rlv setWrongTimelimitNoLoginBlock:^{
        
        if (self.appearMode == NYLockAppearModePush){
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }else if (self.appearMode == NYLockAppearModePresent){
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }else if (self.appearMode == NYLockAppearModeRootView){//程序启动  解锁
            if ([weakSelf.delegate respondsToSelector:@selector(passcodeDidVerify:)])
            {
                [weakSelf.delegate passcodeDidVerify:@"wrongTime"];
            }
        }
    }];
    [self presentViewController:rlv animated:YES completion:^{
    }];
//    [self.navigationController pushViewController:rlv animated:YES];
//    [UIApplication sharedApplication].windows[0].rootViewController = rlv;

}

//- (BOOL)tabBarController:(UITabBarController* )tabBarController shouldSelectViewController:(UIViewController* )viewController
//{
//    if ([viewController isKindOfClass:[UINavigationController class]]) {
//        
//        UINavigationController* nav = (UINavigationController*)viewController;
//        
//        // 这里是关键，只在栈中存大于一个viewController并且是当前选中的，就不做反应
//        if ([nav.viewControllers count] > 1 && tabBarController.selectedViewController==viewController) {
//            return NO;
//        }
//    }
//    return YES;
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [AkrHandel hideKeyBoard];
}

@end
