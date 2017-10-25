//
//  StudViewController.m
//  LGJGestureLockDemo
//
//  Created by lgj on 2017/10/24.
//  Copyright © 2017年 lgj. All rights reserved.
//

#import "StudViewController.h"
#import "GestureLockView.h"

#define GESPWD @"GesturePassword"


#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

@interface StudViewController ()<GestureLockDelegate>

@property (nonatomic, copy) NSString *lastGesturePsw;
@property (nonatomic, strong) GestureLockView *gestureLockView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIView *stuBottomView;

@end

@implementation StudViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"学生端";
    [self configUI];
    // Do any additional setup after loading the view.
}

- (void)configUI {
    [self configStatusLabel];
    [self configGestureLockView];
    [self configStuBottomView];
}

#pragma mark 配置状态label
- (void)configStatusLabel {
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, Screen_Width, 40)];
    statusLabel.backgroundColor = [UIColor orangeColor];
    statusLabel.textColor = [UIColor blackColor];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.numberOfLines = 0;
    //    [statusLabel sizeToFit];
    [self.view addSubview:statusLabel];
    self.statusLabel = statusLabel;
}

- (void)configGestureLockView {
    GestureLockView *gestureLockView = [[GestureLockView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.width)];
    gestureLockView.isTeac = NO;
    [self.view addSubview:gestureLockView];
    gestureLockView.delegate = self;
    self.gestureLockView = gestureLockView;
}


- (void)configStuBottomView {
    //学生端底部
    UIView *stuBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.gestureLockView.frame) + 20, Screen_Width, 100)];
    stuBottomView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:stuBottomView];
    self.stuBottomView = stuBottomView;
    
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn.frame = CGRectMake(20, 20, Screen_Width-40, 40);
    clearBtn.backgroundColor = [UIColor blueColor];
    [clearBtn setTitle:@"清除" forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(clearBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.stuBottomView addSubview:clearBtn];
}

#pragma mark 手势密码界面代理
- (void)gestureLockView:(GestureLockView *)lockView drawRectFinished:(NSMutableString *)gesturePassword {
    [self validateGesturePassword:gesturePassword];
}

//校验手势密码
- (void)validateGesturePassword:(NSMutableString *)gesturePassword {
    
    if (gesturePassword.length < 4) {
        self.statusLabel.text = @"至少连接4个点,重新输入";
        [self.gestureLockView checkPwdResult:ResultKindTypeNoEnough];
        [self shakeAnimationForView:self.statusLabel];
        return;
    }
    self.lastGesturePsw = gesturePassword;
    
    
    /*滑完直接校验*/
    NSLog(@"validPwd == %@, validUserDefaultsPwd == %@", self.lastGesturePsw, [StudViewController gesturePassword]);
    static NSInteger errorCount = 5;
    
    if ([self.lastGesturePsw isEqualToString:[StudViewController gesturePassword]]) {
        [self.gestureLockView checkPwdResult:ResultKindTypeTrue];
        self.statusLabel.text = @"密码校验成功";
        [self shakeAnimationForView:self.statusLabel];
    } else {
        [self.gestureLockView checkPwdResult:ResultKindTypeFalse];
        errorCount = errorCount - 1;
        if (errorCount == 0) {
            //已经输错5次
            self.statusLabel.text = @"请重新输入密码";
            errorCount = 5;
            return;
        }
        self.statusLabel.text = [NSString stringWithFormat:@"密码错误, 还可以再输入%ld次", errorCount];
        [self shakeAnimationForView:self.statusLabel];
    }
}

#pragma mark 按钮点击事件
- (void)clearBtnClick:(UIButton *)btn {
    self.statusLabel.text = @"清除!!!";
    [self.gestureLockView checkPwdResult:ResultKindTypeClear];
    [self shakeAnimationForView:self.statusLabel];
}

#pragma mark 抖动动画
- (void)shakeAnimationForView:(UIView *)view {
    
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint left = CGPointMake(position.x - 10, position.y);
    CGPoint right = CGPointMake(position.x + 10, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:left]];
    [animation setToValue:[NSValue valueWithCGPoint:right]];
    [animation setAutoreverses:YES]; // 平滑结束
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    
    [viewLayer addAnimation:animation forKey:nil];
}

#pragma mark 本地存储模拟
+ (void)deleteGestuesPassword {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:GESPWD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)addGesturePassword:(NSString *)gesturePassword {
    [[NSUserDefaults standardUserDefaults] setObject:gesturePassword forKey:GESPWD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)gesturePassword {
    return [[NSUserDefaults standardUserDefaults] objectForKey:GESPWD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
