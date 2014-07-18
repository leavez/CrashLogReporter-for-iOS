//
//  RMAlertView.m
//  MyPaper
//
//  Created by leave on 14-7-15.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#import "RMAlertView.h"
@interface RMAlertView()<UIAlertViewDelegate>
@property (nonatomic,copy) void (^ActionBlock)(int index);
@end

@implementation RMAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle acitonBlock:(void (^)(int index))ActionBlock;
{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle,nil];
    if (self) {
        self.ActionBlock = ActionBlock;
    }
    return self;
}
-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle thirdButtonTitle:(NSString *)thirdButtonTitle acitonBlock:(void (^)(int index))ActionBlock;
{
    self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle,thirdButtonTitle,nil];
    if (self) {
        self.ActionBlock = ActionBlock;
    }
    return self;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.ActionBlock) {
        self.ActionBlock(buttonIndex);
    }
}

@end
