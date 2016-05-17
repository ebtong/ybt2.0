//
//  ShowStepViewController.m
//  一币通购
//
//  Created by mac on 16/4/21.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "ShowStepViewController.h"

@interface ShowStepViewController ()
{
    NSArray *_viewsArray;
}

@end

@implementation ShowStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _viewsArray = @[@"xinshou_tongdougonglue.jpg",@"xinshou_tongduofuli.jpg",@"0yuanduobao_app.jpg",@"xinshou_jiangpinlianqu.jpg",@"xinshou_shaidanfenxiang.jpg",@"xinshou_tongdoutongbi.jpg"];
    [self setNavItem];
    [self setRightNavItem];
    [self _createView];
}
-(void)_createView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    scrollView.contentSize = CGSizeMake(kScreenWidth, 368.0/750.0*kScreenWidth + _frame.size.height + 142);
    [self.view addSubview:scrollView];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_frame];
    imageView.image = [UIImage imageNamed:_viewsArray[_number]];
    [scrollView addSubview:imageView];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 388.0/750.0*kScreenWidth)];
    imageView1.image = [UIImage imageNamed:@"xinshoubaodian_1"];
    imageView1.contentMode = UIViewContentModeScaleAspectFill;
    [scrollView addSubview:imageView1];
    
    UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 368.0/750.0*kScreenWidth + _frame.size.height, kScreenWidth, 142)];
    bgImageView.backgroundColor = ORANGE_LABEL_COLOR;
    bgImageView.userInteractionEnabled = YES;
    [scrollView addSubview:bgImageView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, kScreenWidth - 60, 60)];
    label.text = @"\t我已经错过了拯救世界的机会，但绝不能再错过这次中奖！现在就开始点击“结算”0元夺宝吧！";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = HGfont(12);
    [bgImageView addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((kScreenWidth - 202) / 2, bgImageView.height - 60, 202, 30);
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitleColor:ORANGE_LABEL_COLOR forState:UIControlStateNormal];
    [button setTitle:@"立即夺宝" forState:UIControlStateNormal];
    button.layer.cornerRadius = 15;
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:button];
}

-(void)buttonAction
{
    self.navigationController.tabBarController.selectedIndex = 1;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
