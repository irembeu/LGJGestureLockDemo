//
//  GestureLockView.h
//  PalmCollege
//
//  Created by lgj on 2017/10/23.
//  Copyright © 2017年 cyx. All rights reserved.
//

#import <UIKit/UIKit.h>

//检测手势密码答案情况 对/错/不够4个数字
typedef NS_ENUM(NSUInteger, ResultKindType) {
    ResultKindTypeTrue,
    ResultKindTypeFalse,
    ResultKindTypeNoEnough,
    ResultKindTypeClear
};

typedef NS_ENUM(NSUInteger, TeacKindType) {
    TeacKindTypeNoEnough,
    TeacKindTypeTrue
};

@class GestureLockView;

@protocol GestureLockDelegate <NSObject>

- (void)gestureLockView:(GestureLockView *)lockView drawRectFinished:(NSMutableString *)gesturePassword;

@end

@interface GestureLockView : UIView

@property (nonatomic, weak) id<GestureLockDelegate> delegate;

@property (nonatomic, assign) BOOL isTeac;//教师端

- (void)clearLockView;//清除布局 重新开始

- (void)checkPwdResult:(ResultKindType)resultType;

- (void)checkTeacResult:(TeacKindType)resultType;

@end
