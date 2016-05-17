//
//  IdeaViewController.m
//  一币通购
//
//  Created by mac on 16/4/13.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "IdeaViewController.h"
#import "SVProgressHUD.h"

@interface IdeaViewController ()<UITextViewDelegate>

@end

@implementation IdeaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _upButton.layer.cornerRadius = 15;
    _bgView.layer.cornerRadius = 5;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setNavItem];
    [self setRightNavItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_contentTextView resignFirstResponder];
}

- (IBAction)upButtonAction:(UIButton *)sender {
    [SVProgressHUD showErrorWithStatus:@"暂无此功能，请等待后续开发！"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
}
@end
