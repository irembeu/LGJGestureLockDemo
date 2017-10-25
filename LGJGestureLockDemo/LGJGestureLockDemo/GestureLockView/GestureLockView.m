//
//  GestureLockView.m
//  PalmCollege
//
//  Created by lgj on 2017/10/23.
//  Copyright © 2017年 cyx. All rights reserved.
//

#import "GestureLockView.h"

#define SCREEN_WIDTH self.bounds.size.width
#define SCREEN_HEIGHT self.bounds.size.height

@interface GestureLockView ()

@property (strong, nonatomic) NSMutableArray *selectBtns;//选中的按钮数组
@property (nonatomic, strong) NSMutableArray *errorBtns;//错误的按钮数组
@property(nonatomic, assign)BOOL finished;//是否完成
@property (nonatomic, assign) CGPoint currentPoint;//当前触摸点
@property (nonatomic, assign) ResultKindType resultType;//学生端结果
@property (nonatomic, assign) TeacKindType teacResultType;//教师端结果

@end

@implementation GestureLockView

- (NSMutableArray *)selectBtns {
    if (!_selectBtns) {
        _selectBtns = [NSMutableArray array];
    }
    return _selectBtns;
}

- (NSMutableArray *)errorBtns {
    if (!_errorBtns) {
        _errorBtns = [NSMutableArray array];
    }
    return _errorBtns;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        
    }
    return self;
}

//子视图初始化
- (void)initSubviews {
    self.backgroundColor = [UIColor clearColor];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    //创建9个按钮
    for (NSInteger i = 0; i < 9; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.userInteractionEnabled = NO;
        [btn setImage:[UIImage imageNamed:@"sign_img_circle_n"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"sign_img_circle_s"] forState:UIControlStateSelected];
        btn.tag = i+1;
        [self addSubview:btn];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSUInteger count = self.subviews.count;
    int cols = 3;//总列数
    CGFloat x = 0,y = 0,w = 0,h = 0;
    if (SCREEN_WIDTH == 320) {
        w = 50;
        h = 50;
    } else {
        w = 60;
        h = 60;
    }
    CGFloat minWidth = MIN(self.bounds.size.height, self.bounds.size.width);
    CGFloat boundsWidth = self.bounds.size.width;
    CGFloat margin = (minWidth - cols * w) / (cols + 1);//间距
    CGFloat xMargin = (boundsWidth-2*margin-3*w)/2;
    
    CGFloat col = 0;
    CGFloat row = 0;
    for (int i = 0; i < count; i++) {
        col = i % cols;
        row = i / cols;
        if (i == 0 || i == 3 || i == 6) {
            x = xMargin;
        } else if (i == 1 || i == 4 || i == 7) {
            x = xMargin + w + margin;
        } else {
            x = xMargin + 2 * (margin+w);
        }
        y = (w+margin)*row;
        UIButton *btn = self.subviews[i];
        btn.frame = CGRectMake(x, y, w, h);
    }
}

//调用这个方法就会把之前绘制的东西清空 重新绘制
- (void)drawRect:(CGRect)rect {
    if (_selectBtns.count == 0) return;
    // 把所有选中按钮中心点连线
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < self.selectBtns.count; i ++) {
        UIButton *btn = self.selectBtns[i];
        if (i == 0) {
            [path moveToPoint:btn.center]; // 设置起点
        } else {
            [path addLineToPoint:btn.center];
        }
    }
    
    //判断是否松开手指
    if (self.finished) {
        //松开手
        NSMutableString *pwd = [self transferGestureResult];//传递创建的密码
        [[UIColor colorWithRed:94/255.0 green:195/255.0 blue:49/255.0 alpha:0.8] set];
        if ([self.delegate respondsToSelector:@selector(gestureLockView:drawRectFinished:)]) {
            [self.delegate gestureLockView:self drawRectFinished:pwd];
        }
        
        if (self.isTeac) {
            //教师端
            switch (self.teacResultType) {
                case TeacKindTypeNoEnough:
                {
                    [[UIColor clearColor] set];
                }
                    break;
                case TeacKindTypeTrue:
                {
                    [[UIColor colorWithRed:94/255.0 green:195/255.0 blue:49/255.0 alpha:0.8] set];
                }
                    break;
                default:
                    break;
            }
        } else {
            switch (self.resultType) {
                case ResultKindTypeTrue:
                {
                    //正确
                    [[UIColor clearColor] set];
                }
                    break;
                case ResultKindTypeFalse:
                {
                    //错误
                    [[UIColor redColor] set];
                    for (int i = 0; i < self.errorBtns.count; i++) {
                        UIButton *btn =  [self.errorBtns objectAtIndex:i];
                        [btn setImage:[UIImage imageNamed:@"sign_img_circle_p"] forState:UIControlStateNormal];
                    }
                    break;
                case ResultKindTypeNoEnough:
                    {
                        [[UIColor clearColor] set];
                    }
                    break;
                case ResultKindTypeClear:
                    {
                        
                    }
                    break;
                default:
                    break;
                }
            }        
        }
    } else {
        [path addLineToPoint:self.currentPoint];
        [[UIColor colorWithRed:94/255.0 green:195/255.0 blue:49/255.0 alpha:0.8] set];
    }
    path.lineWidth = 1;
    path.lineJoinStyle = kCGLineCapRound;
    path.lineCapStyle = kCGLineCapRound;
    [path stroke];
}
#pragma mark 手势
- (void)pan:(UIPanGestureRecognizer *)pan {
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        for (UIButton *btn in _errorBtns) {
            [btn setImage:[UIImage imageNamed:@"sign_img_circle_n"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"sign_img_circle_s"] forState:UIControlStateSelected];
        }
        [self.errorBtns removeAllObjects];
    }
    _currentPoint = [pan locationInView:self];
    
    for (UIButton *button in self.subviews) {
        if (CGRectContainsPoint(button.frame, _currentPoint)) {
            if (button.selected == NO) {
                //点在按钮上
                button.selected = YES;//设置为选中
                [self.selectBtns addObject:button];
            } else {
                
            }
        }
    }
    
    //重绘
    [self setNeedsDisplay];
    //监听手指松开
    if (pan.state == UIGestureRecognizerStateEnded) {
        self.finished = YES;
    }
}

//传递设置的手势密码
- (NSMutableString *)transferGestureResult {
    //创建可变字符串
    NSMutableString *result = [NSMutableString string];
    for (UIButton *btn in self.selectBtns) {
        [result appendFormat:@"%ld", btn.tag - 1];
    }
    return result;
}

//清除
- (void)clearLockView {
    self.finished = NO;
    //遍历所有选中的按钮
    for (UIButton *btn in self.selectBtns) {
        //取消选中状态
        btn.selected = NO;
    }
    [self.selectBtns removeAllObjects];
    //
    [self setNeedsDisplay];
}
//检验密码正误
- (void)checkPwdResult:(ResultKindType)resultType {
    self.resultType = resultType;
    switch (resultType) {
        case ResultKindTypeFalse:
            _errorBtns = [NSMutableArray arrayWithArray:self.selectBtns];
            break;
            case ResultKindTypeTrue:
            break;
            case ResultKindTypeNoEnough:
            break;
            case ResultKindTypeClear:
        {
            [[UIColor clearColor] set];
            for (int i = 0; i < self.errorBtns.count; i++) {
                UIButton *btn =  [self.errorBtns objectAtIndex:i];
                [btn setImage:[UIImage imageNamed:@"sign_img_circle_n"] forState:UIControlStateNormal];
            }
            [self.errorBtns removeAllObjects];
        }
            break;
        default:
            break;
    }
    [self clearLockView];
}

- (void)checkTeacResult:(TeacKindType)resultType {
    self.teacResultType = resultType;
    switch (resultType) {
        case TeacKindTypeTrue:
            break;
        case TeacKindTypeNoEnough:{
            [self clearLockView];
        }
            break;
        default:
            break;
    }
}

@end
