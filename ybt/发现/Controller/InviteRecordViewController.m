//
//  InviteRecordViewController.m
//  一币通购
//
//  Created by mac on 16/4/14.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "InviteRecordViewController.h"
#import "InviteRecordTableViewCell.h"
#import "LogInViewController.h"
#import "MJRefresh.h"
#import "UIImageView+AFNetworking.h"

@interface InviteRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (assign,nonatomic) NSInteger pageIndex;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSDictionary *userInfo;
@property (strong,nonatomic) NSMutableArray *listArray;
@property (strong,nonatomic) NSDictionary *dataList;

@end

@implementation InviteRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavItem];
    [self setRightNavItem];
    [self _createView];
}

-(void)_createView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    self.listArray = [NSMutableArray array];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    
    __weak typeof(self) weakSelf = self;
    // 添加传统的下拉刷新
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        weakSelf.pageIndex = 1;
        [weakSelf fetchData:weakSelf.pageIndex];
        [weakSelf.tableView.header endRefreshing];
    }];
    [self.tableView.legendHeader beginRefreshing];
    
    // 添加传统的上拉刷新
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        weakSelf.pageIndex ++;
        [weakSelf fetchData:weakSelf.pageIndex];
        [weakSelf.tableView.footer endRefreshing];
    }];
}

- (void)fetchData:(NSInteger)page
{
    self.userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    if (!self.userInfo) {
        LogInViewController *vc = [[LogInViewController alloc] init];
        vc.title = @"登陆";
        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:nvc animated:YES completion:nil];
        return;
    }
    
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":self.userInfo[@"uid"],
                            @"SessionId":self.userInfo[@"SessionId"],
                            @"page":[NSString stringWithFormat:@"%zi",page]};
    [service POST:user_yaoQingList parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.dataList = responseObject;
        NSArray *list = responseObject[@"data"];
        if (page == 1) {
            [self.listArray removeAllObjects];
            [self.tableView.footer resetNoMoreData];
        }
        
        //        有无更多数据
        if (responseObject == [NSNull null] ||[responseObject count] == 0) {
            [self.tableView.footer noticeNoMoreData];
        } else {
            [self.listArray addObjectsFromArray:list];
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return  self.listArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"topInviteRecordCell"];
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 170)];
        bgImgView.image = [UIImage imageNamed:@"yaoqingjilv_beijin"];
        [cell.contentView addSubview:bgImgView];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 170, kScreenWidth, 60)];
        view.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:view];
        
        UIImageView *headBgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 24, bgImgView.bottom - 50 - 48, 48, 48)];
        headBgView.layer.cornerRadius = 24;
        headBgView.backgroundColor = [UIColor whiteColor];
        headBgView.alpha = 0.3;
        [cell.contentView addSubview:headBgView];
        
        UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(headBgView.left + 2, headBgView.top + 2, 44, 44)];
        NSURL *headStr = [CommonUtil getImageNsUrl:_userInfo[@"img"]];
        if ([_userInfo[@"img"] isEqualToString:@"photo/member.jpg"]) {
            if ([_userInfo[@"headimg"] length] > 0) {
                headStr = [NSURL URLWithString:_userInfo[@"headimg"]];
            }else{
                headStr = nil;
            }
        }
        
        [headView setImageWithURL:headStr placeholderImage:[UIImage imageNamed:@"touxiang"]];
        headView.layer.cornerRadius = 22;
        headView.clipsToBounds = YES;
        [cell.contentView addSubview:headView];
        
        UILabel *friendlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, kScreenWidth / 2, 16)];
        friendlabel.font = HGfont(16);
        friendlabel.textColor = GREEN_LABEL_COLOR;
        friendlabel.textAlignment = NSTextAlignmentCenter;
        friendlabel.text = [NSString stringWithFormat:@"%@",self.dataList[@"count"]];
        [view addSubview:friendlabel];
        
        UILabel *beanLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth / 2, 16, kScreenWidth / 2, 16)];
        beanLabel.font = HGfont(16);
        beanLabel.textColor = GREEN_LABEL_COLOR;
        beanLabel.textAlignment = NSTextAlignmentCenter;
        beanLabel.text = [NSString stringWithFormat:@"%@",self.dataList[@"total"]];;
        [view addSubview:beanLabel];
        
        UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, friendlabel.bottom + 6, kScreenWidth / 2, 12)];
        inviteLabel.font = HGfont(12);
        inviteLabel.textAlignment = NSTextAlignmentCenter;
        inviteLabel.text = @"邀请好友";
        [view addSubview:inviteLabel];
        
        UILabel *bLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth / 2, friendlabel.bottom + 6, kScreenWidth / 2, 12)];
        bLabel.font = HGfont(12);
        bLabel.textAlignment = NSTextAlignmentCenter;
        bLabel.text = @"累计奖励";
        [view addSubview:bLabel];
        
        return cell;
    }
    else{
        InviteRecordTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"InviteRecordTableViewCell" owner:self options:nil]firstObject];
        if (!cell) {
            cell = [[InviteRecordTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InviteRecordTableViewCell"];
        }
        
        
        if (indexPath.row == 0) {
            //        cell.imageView.image = [UIImage imageNamed:nil];
            cell.friendHeadView.hidden = YES;
            cell.telNumLabel.text = @"用户名";
            cell.stateLabel.text = @"参与状态";
            cell.beanNumberLabel.text = @"奖励";
        }
        else {
            NSDictionary *dict = self.listArray[indexPath.row - 1];
            
            NSURL *headStr = [CommonUtil getImageNsUrl:dict[@"img"]];
            if ([dict[@"img"] isEqualToString:@"photo/member.jpg"]) {
                if ([dict[@"headimg"] length] > 0) {
                    headStr = [NSURL URLWithString:dict[@"headimg"]];
                }else{
                    headStr = nil;
                }
            }
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
            view.backgroundColor = CELL_BG_COLOR;
            [cell.contentView addSubview:view];
            
            [cell.friendHeadView setImageWithURL:headStr placeholderImage:[UIImage imageNamed:@"touxiang"]];
            cell.friendHeadView.layer.cornerRadius = cell.friendHeadView.height / 2.0;
            cell.friendHeadView.clipsToBounds = YES;
            
            cell.telNumLabel.text =dict[@"name"];
            cell.stateLabel.text = @"已参与";
            cell.beanNumberLabel.text = [NSString stringWithFormat:@"+%@",dict[@"score"]];
        }
        return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 230;
    }
    if (indexPath.row == 0 && indexPath.section == 1) {
        return 25;
    }
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 5;
    }
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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
