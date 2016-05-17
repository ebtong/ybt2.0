//
//  TaskCenterTableViewController.m
//  ybt
//
//  Created by mac on 16/5/5.
//  Copyright © 2016年 少蛟 周. All rights reserved.
//

#import "TaskCenterTableViewController.h"
#import "ThemeButton.h"
#import "InviteFriendsViewController.h"

@interface TaskCenterTableViewController (){
    NSDictionary *_userInfo;
}

@end

@implementation TaskCenterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self setNavItem];
    [self setRightNavItem];
    self.navigationController.navigationBar.hidden = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

-(void)setRightNavItem
{
    //    //1.返回按钮
    //    ThemeButton *messageButton = [[ThemeButton alloc] initWithFrame:CGRectMake(0, 0, 26, 22)];
    //    messageButton.normalImageName = @"goods_xiaoxi";
    //    [messageButton addTarget:self action:@selector(messageAction) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *messageItem = [[UIBarButtonItem alloc] initWithCustomView:messageButton];
    //    [self.navigationItem setRightBarButtonItem:messageItem];
    
}

-(void)viewWillAppear:(BOOL)animated{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"]) {
        _userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    }
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:7];
    btn.backgroundColor = TABLE_BG_COLOR;
    if (btn) {
        btn.layer.cornerRadius = 11;
        btn.clipsToBounds = YES;
    }
    if (indexPath.row == 1) {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:6];
        if (_userInfo) {
            NSInteger num = [_userInfo[@"sign_in_time"] integerValue] % 7;
            label.text = [NSString stringWithFormat:@"每日签到（%ld/7）",(long)num];
            btn.backgroundColor = TABLE_BG_COLOR;
        }else{
            btn.backgroundColor = ORANGE_LABEL_COLOR;
            label.text = [NSString stringWithFormat:@"每日签到（0/7）"];
        }
        
    }else if (indexPath.row == 2) {
        btn.hidden = YES;
    }else if (indexPath.row == 3) {
        btn.hidden = YES;
    }else if (indexPath.row == 4) {
        btn.hidden = NO;
        btn.backgroundColor = ORANGE_LABEL_COLOR;
        [btn addTarget:self action:@selector(inviteAction) forControlEvents:UIControlEventTouchUpInside];
    }else if (indexPath.row == 5) {
        btn.hidden = YES;
    }
    
    return cell;
}

-(void)inviteAction{
    InviteFriendsViewController *vc = [[InviteFriendsViewController alloc] init];
    vc.title = @"邀请有奖";
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
