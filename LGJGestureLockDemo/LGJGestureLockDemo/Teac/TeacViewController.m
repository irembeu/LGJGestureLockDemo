//
//  TeacViewController.m
//  LGJGestureLockDemo
//
//  Created by lgj on 2017/10/24.
//  Copyright © 2017年 lgj. All rights reserved.
//

#import "TeacViewController.h"
#import "GestureLockView.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height
#define GESPWD @"GesturePassword"

@interface TeacViewController ()<GestureLockDelegate>

@property (nonatomic, strong) GestureLockView *gestureLockView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIView *teacBottomView;
@property (nonatomic, copy) NSString *lastGesturePsw;


@end

@implementation TeacViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"教师端";
    [self configUI];
    // Do any additional setup after loading the view.
}

- (void)configUI {
    [self configStatusLabel];
    [self configGestureLockView];
    [self configTeacBottomView];
}

#pragma mark 配置状态label
- (void)configStatusLabel {
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, Screen_Width, 40)];
    statusLabel.backgroundColor = [UIColor lightGrayColor];
    statusLabel.textColor = [UIColor redColor];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.numberOfLines = 0;
    //    [statusLabel sizeToFit];
    [self.view addSubview:statusLabel];
    self.statusLabel = statusLabel;
}

- (void)configGestureLockView {
    GestureLockView *gestureLockView = [[GestureLockView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.width)];
    gestureLockView.isTeac = YES;
    [self.view addSubview:gestureLockView];
    gestureLockView.delegate = self;
    self.gestureLockView = gestureLockView;
}

- (void)configTeacBottomView {
    UIView *teacBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.gestureLockView.frame) + 20, Screen_Width, 100)];
    teacBottomView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:teacBottomView];
    self.teacBottomView = teacBottomView;
    
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resetBtn.frame = CGRectMake(40, 20, Screen_Width/2 - 60, 40);
    resetBtn.backgroundColor = [UIColor redColor];
    [resetBtn setTitle:@"重置" forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.teacBottomView addSubview:resetBtn];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(Screen_Width/2+20, 20, Screen_Width/2 - 60, 40);
    sureBtn.backgroundColor = [UIColor greenColor];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.teacBottomView addSubview:sureBtn];
}

#pragma mark gestureLockView代理事件
- (void)gestureLockView:(GestureLockView *)lockView drawRectFinished:(NSMutableString *)gesturePassword {
    [self createGesturesPassword:gesturePassword];
}

//创建手势密码
- (void)createGesturesPassword:(NSMutableString *)gesturePassword {
    if (self.lastGesturePsw.length == 0) {
        if (gesturePassword.length < 4) {
            self.lastGesturePsw = nil;
            [self.gestureLockView checkTeacResult:TeacKindTypeNoEnough];
            self.statusLabel.text = @"至少连接4个点,重新输入";
            [self shakeAnimationForView:self.statusLabel];
            return;
        }
        self.lastGesturePsw = gesturePassword;
        [self.gestureLockView checkTeacResult:TeacKindTypeTrue];
        NSLog(@"---%@", self.lastGesturePsw);
        self.statusLabel.text = [NSString stringWithFormat:@"密码是%@", gesturePassword];
    }
}

#pragma mark 按钮点击事件
//重置按钮
- (void)resetBtnClick:(UIButton *)btn {
    self.lastGesturePsw = nil;
    [TeacViewController addGesturePassword:@""];
    [self.gestureLockView checkTeacResult:TeacKindTypeNoEnough];
    self.statusLabel.text = @"请绘制手势密码";
    NSLog(@"resetPwd == %@, resetUserDefaultsPwd == %@", self.lastGesturePsw, [TeacViewController gesturePassword]);
}
//确定按钮
- (void)sureBtnClick:(UIButton *)btn {
    if (!self.lastGesturePsw) {
        self.statusLabel.text = @"请绘制手势密码";
        return;
    }
    [TeacViewController addGesturePassword:self.lastGesturePsw];
    [self.gestureLockView checkTeacResult:TeacKindTypeTrue];
    self.statusLabel.text = @"密码设置成功";
    NSLog(@"resetPwd == %@, resetUserDefaultsPwd == %@", self.lastGesturePsw, [TeacViewController gesturePassword]);
//    [self.navigationController popViewControllerAnimated:YES];
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
