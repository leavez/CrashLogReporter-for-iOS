//
//  RMAlertView.h
//  MyPaper
//
//  Created by leave on 14-7-15.
//  Copyright (c) 2014年 leave. All rights reserved.
//
// 
//  UIAlertView with Blocks
//
#import <UIKit/UIKit.h>

@interface RMAlertView : UIAlertView

-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle acitonBlock:(void (^)(int index))ActionBlock;

-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle thirdButtonTitle:(NSString *)thirdButtonTitle acitonBlock:(void (^)(int index))ActionBlock;

@end
