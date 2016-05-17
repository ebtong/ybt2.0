//
//  BaseViewController.m
//  0元夺宝
//
//  Created by 老钱 on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "BaseViewController.h"
#import "ThemeButton.h"
#import "SVProgressHUD.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)setNavItem
{
    //1.返回按钮
    ThemeButton *backButton = [[ThemeButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    backButton.normalImageName = @"fanhui";
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bakeItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:bakeItem];
    
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setRightNavItem
{
//    //1.返回按钮
//    ThemeButton *messageButton = [[ThemeButton alloc] initWithFrame:CGRectMake(0, 0, 26, 22)];
//    messageButton.normalImageName = @"xiaoxi_nor";
//    [messageButton addTarget:self action:@selector(messageAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *messageItem = [[UIBarButtonItem alloc] initWithCustomView:messageButton];
//    [self.navigationItem setRightBarButtonItem:messageItem];
    
}

-(void)messageAction
{
    [SVProgressHUD showErrorWithStatus:@"暂无此功能，待后续开发"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
