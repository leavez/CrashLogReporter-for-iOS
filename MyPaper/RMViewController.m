//
//  RMViewController.m
//  MyPaper
//
//  Created by leave on 14-7-1.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#import "RMViewController.h"

@interface RMViewController ()
@property (nonatomic,strong) UIButton *button;
@end

@implementation RMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    self.button.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:self.button];
    [self.button addTarget:self action:@selector(crash) forControlEvents:UIControlEventTouchUpInside];
}

- (void)crash
{
    id a = @[@1][2];
    a = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
