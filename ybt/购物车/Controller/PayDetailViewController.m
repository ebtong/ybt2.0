//
//  PayDetailViewController.m
//  ybt
//
//  Created by mac on 16/5/1.
//  Copyright © 2016年 少蛟 周. All rights reserved.
//

#import "PayDetailViewController.h"
#import "PersonMaterialViewController.h"
#import "InviteFriendsViewController.h"
#import "ShoppingRecordViewController.h"
#import "BindMobileViewController.h"

@interface PayDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation PayDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = NO;
    [self setNavItem];
    [self _createaView];
}

-(void)backAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)_createaView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = TABLE_BG_COLOR;
    [self.view addSubview:tableView];
    tableView.tableFooterView = [[UIView alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"payDetailCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"payDetailCell"];
    }
    for (id subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 46, 30, 30)];
            imageView.image = [UIImage imageNamed:@"success_1"];
            [cell.contentView addSubview:imageView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 10, 42, kScreenWidth - imageView.width - 20, 19)];
            label.text = @"恭喜您，支付成功";
            label.font = HGfont(16);
            label.textColor = HGColor(144, 196, 31);
            [cell.contentView addSubview:label];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(label.left, label.bottom + 2, label.width, 17)];
            label1.text = @"请等待系统为您揭晓！";
            label1.font = HGfont(14);
            [cell.contentView addSubview:label1];
            
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(label1.left, label1.bottom + 20, label1.width, 17)];
            label2.font = HGfont(14);
            label2.text = @"每消费1通币，即可获赠1通豆";
            label2.textColor = HGColor(251, 92, 96);
            [cell.contentView addSubview:label2];
        }
        else
        {
        
            for (int i = 0; i < 2; i++) {
                UIButton *button = [UIButton  buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(i * kScreenWidth / 2.0, 0, kScreenWidth / 2.0, 44);
                if (i == 0) {
                    [button setTitle:@"查看通购记录" forState:UIControlStateNormal];
                    [button setBackgroundColor:ORANGE_LABEL_COLOR];
                    [button addTarget:self action:@selector(showBuyRecord) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    [button setTitle:@"继续购物" forState:UIControlStateNormal];
                    [button setBackgroundColor:HGColor(251, 92, 96)];
                    [button addTarget:self action:@selector(continueBuy) forControlEvents:UIControlEventTouchUpInside];
                }
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [cell.contentView addSubview:button];
            }
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.backgroundColor = CELL_BG_COLOR;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 14, 19, 19)];
            imageView.image = [UIImage imageNamed:@"Warning"];
            [cell.contentView addSubview:imageView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 5, 0, kScreenWidth - imageView.right - 10, 48)];
            label.text = @"中奖用户需绑定手机号，否则无法收到中奖信息";
            label.font = HGfont(14);
            [cell.contentView addSubview:label];
            
        }
        else
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
            label.textAlignment = NSTextAlignmentCenter ;
            NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
            if ([userInfo[@"mobile"] length] == 0) {
                label.text = @"我要绑定";
                label.textColor = HGColor(95, 163, 255);
            }else{
                label.text = @"已绑定手机";
                label.textColor = NORMAL_LABEL_COLOR;
            }
            
            [cell.contentView addSubview:label];
        }
    }
    if (indexPath.section == 2)
    {
        if (indexPath.row == 0) {
            
            UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 20, kScreenWidth - 25, 20)];
            titlelabel.text = @"怎么赚钱?";
            titlelabel.font = HGfont(14);
            [cell.contentView addSubview:titlelabel];
            
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            contentLabel.text = @"1、点击本页面右上角的三个点图标；\n2、选择［发送给朋友］或［分享到朋友圈］；\n3、分享有奖，每天分享奖励30通豆；\n4、经您邀请的好友成功参与夺宝或通购后，奖励100通豆；\n5、好友首次注册签到奖励50通豆\n6、完善资料，奖励50通豆。";
            contentLabel.numberOfLines = 0;
            UIFont *fnt = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
            contentLabel.font = fnt;
            CGSize size1 = CGSizeMake(kScreenWidth - 30,0);
            CGSize labelSize1 = [contentLabel.text boundingRectWithSize:size1 options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:contentLabel.font,NSFontAttributeName, nil] context:nil].size;
            contentLabel.frame = CGRectMake(25, titlelabel.bottom + 5, labelSize1.width, labelSize1.height);
            [cell.contentView addSubview:contentLabel];
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(25, contentLabel.bottom + 10, kScreenWidth - 30, 20)];
            label2.text = @"注：0元夺宝坚持赚通豆，每期参加中奖率100%";
            label2.textColor = GREY_LABEL_COLOR;
            label2.font = HGfont(13);
            [cell.contentView addSubview:label2];
            cell.backgroundColor = CELL_BG_COLOR;
        }
        else
        {
            cell.backgroundColor = [UIColor whiteColor];
            for (int i = 0; i < 2; i++) {
                UIButton *button = [UIButton  buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(i * kScreenWidth / 2.0, 0, kScreenWidth / 2.0, 44);
                if (i == 0) {
                    [button setTitle:@"完善资料" forState:UIControlStateNormal];
                    [button setTitleColor:ORANGE_LABEL_COLOR forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(materiaAction) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    [button setTitle:@"邀请有奖" forState:UIControlStateNormal];
                    [button setTitleColor:HGColor(251, 92, 96) forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(inviteAction) forControlEvents:UIControlEventTouchUpInside];
                }

                [cell.contentView addSubview:button];
            }
        }
        
    }
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return 48;
        }
        else
            return 44;
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            return 195;
        }
        else
            return 44;
    }
    else
    {
        if (indexPath.row == 0) {
            return 150;
        }
        return 44;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 1) {
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
        if ([userInfo[@"mobile"] length] == 0) {
            BindMobileViewController *vc = [[BindMobileViewController alloc] init];
            vc.title = @"绑定手机";
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01;
    }
    return 10;
}

//查看通购记录按钮
-(void)showBuyRecord
{
    ShoppingRecordViewController *vc = [[ShoppingRecordViewController alloc] init];
    vc.title = @"通购记录";
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
//继续购物按钮
-(void)continueBuy
{
    self.navigationController.tabBarController.selectedIndex = 1;
    [self.navigationController popToRootViewControllerAnimated:YES];
}
//完善资料按钮
-(void)materiaAction
{
    PersonMaterialViewController *vc = [[PersonMaterialViewController alloc] init];
    vc.title = @"个人资料";
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
//邀请有奖按钮
-(void)inviteAction
{
    InviteFriendsViewController *vc = [[InviteFriendsViewController alloc] init];
    vc.title = @"邀请有奖";
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
}
@end
