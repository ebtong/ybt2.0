//
//  FreshManViewController.m
//  一币通购
//
//  Created by mac on 16/4/21.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "FreshManViewController.h"
#import "ShowStepViewController.h"

@interface FreshManViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation FreshManViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavItem];
    [self setRightNavItem];
    [self _createView];
}
-(void)_createView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight + 49) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = TABLE_BG_COLOR;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = @[@"如何参与通购",@"通豆福利",@"如何0元夺宝",@"如何奖品领取",@"晒单分享",@"通豆和通币的分别"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"freshCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"freshCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (id subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 368.0/750.0*kScreenWidth)];
        imageView.image = [UIImage imageNamed:@"xinshoubaodian"];
        [cell.contentView addSubview:imageView];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, kScreenWidth - 20, 20)];
        label.font = HGfont(14);
        label.text = arr[indexPath.row - 1];
        [cell.contentView addSubview:label];
        if (indexPath.row == 1) {
            UIImageView *smallImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 10, 0, 20, 10)];
            smallImageView.image = [UIImage imageNamed:@"jiantou"];
            [cell.contentView addSubview:smallImageView];
        }
        else
        {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
            lineView.backgroundColor = TABLE_BG_COLOR;
            [cell.contentView addSubview:lineView];
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 368.0/750.0*kScreenWidth;
    }
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShowStepViewController *vc = [[ShowStepViewController alloc] init];
    vc.title = @"新手宝典";
    if (indexPath.row == 1) {
        vc.number = 0;
        vc.frame = CGRectMake(0, 368.0/750.0*kScreenWidth, kScreenWidth, 6338.0/750.0 *kScreenWidth);
    }
    if (indexPath.row == 2) {
        vc.number = 1;
        vc.frame = CGRectMake(0, 368.0/750.0*kScreenWidth, kScreenWidth, 5630.0/750.0 *kScreenWidth);
    }
    if (indexPath.row == 3) {
        vc.number = 2;
        vc.frame = CGRectMake(0, 368.0/750.0*kScreenWidth, kScreenWidth, 2308.0/750.0 *kScreenWidth);
    }
    if (indexPath.row == 4) {
        vc.number = 3;
        vc.frame = CGRectMake(0, 368.0/750.0*kScreenWidth, kScreenWidth, 2296.0/750 *kScreenWidth);
    }
    if (indexPath.row == 5) {
        vc.number = 4;
        vc.frame = CGRectMake(0, 368.0/750.0*kScreenWidth, kScreenWidth, 2208.0/750.0 *kScreenWidth);
    }
    if (indexPath.row == 6) {
        vc.number = 5;
        vc.frame = CGRectMake(0, 368.0/750.0*kScreenWidth, kScreenWidth, 1144.0/750.0 *kScreenWidth);
    }
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
