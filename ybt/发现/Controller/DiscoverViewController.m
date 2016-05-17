//
//  DiscoverViewController.m
//  0元夺宝
//
//  Created by hezhou on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "DiscoverViewController.h"
#import "WebViewController.h"
#import "TurntableViewController.h"
#import "SVProgressHUD.h"
#import "AllGoodsViewController.h"
#import "InviteFriendsViewController.h"

@interface DiscoverViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _createView];
    [self setRightNavItem];
}

-(void)_createView
{
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = HGColor(235, 235, 235);
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *imageNames = @[@"xiaozhuangpan",@"shaidan_2",@"0_yuan_Indiana",@"yaoqing_2",@"shangjia"];
    NSArray *titles = @[@"幸运大转盘",@"晒单分享",@"0元夺宝",@"邀请有奖",@"商家入口"];
    NSArray *contents = @[@"免费抽大奖",@"我要沾沾好运气",@"新品上线 手快有 手慢无",@"邀请好友奖励100通豆",@"只限特约商家登录"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dicCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"disCell"];
    }
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 5)];
    view.backgroundColor = HGColor(235, 235, 235);
    [cell.contentView addSubview:view];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, view.bottom + 12, 49, 49)];
    imageView.image = [UIImage imageNamed:imageNames[indexPath.row]];
    [cell.contentView addSubview:imageView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 10, imageView.top + 8, 200, 14)];
    title.text = titles[indexPath.row];
    title.font = HGfont(14);
    [cell.contentView addSubview:title];
    
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 10, title.bottom + 5, 250, 12)];
    content.text = contents[indexPath.row];
    content.textColor = HGColor(153, 153, 153);
    content.font = HGfont(12);
    [cell.contentView addSubview:content];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 79;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        TurntableViewController *vc = [[TurntableViewController alloc] init];
        vc.title = @"幸运大转盘";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 2) {
        AllGoodsViewController *vc = [[AllGoodsViewController alloc]init];
        vc.cid = @"147";
        vc.title = @"0元夺宝";
        vc.isSecondView = YES;
    
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }else
    if (indexPath.row == 3) {
        InviteFriendsViewController *vc = [[InviteFriendsViewController alloc] init];
        vc.title = @"邀请有奖";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"暂无此功能，待后续开发"];
    }
}

-(void)viewDidAppear:(BOOL)animated
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
//    self.tabBarController.tabBar.hidden = NO;
}

@end
