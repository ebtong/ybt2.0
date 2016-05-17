//
//  PrizeRecordViewController.m
//  一币通购
//
//  Created by mac on 16/4/14.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "PrizeRecordViewController.h"
#import "PrizeRecordTableViewCell.h"
#import "MJRefresh.h"
#import "LogInViewController.h"

@interface PrizeRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIView *_redView;//被选中按钮下方的红色线条
    NSArray *_prizes;
}
@property (assign,nonatomic) NSInteger pageIndex;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSDictionary *userInfo;
@property (strong,nonatomic) NSMutableArray *listArray;
@property (assign,nonatomic) NSInteger state;
@end

@implementation PrizeRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavItem];
    [self setRightNavItem];
    [self _createView];
    
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
    NSDictionary *param = @{@"page":[NSString stringWithFormat:@"%zi",page],
                            @"uid":self.userInfo[@"uid"],
                            @"status":[NSString stringWithFormat:@"%li",(long)self.state]};
    [service POST:lottery_activityLottery parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *list = responseObject;
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

-(void)_createView
{
    NSArray *names = @[@"全部",@"未领取",@"已领取"];
    CGFloat buttonWidth = kScreenWidth / 3;
    for (int i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i * buttonWidth, 64, buttonWidth, 39);
        [button setTitle:names[i] forState:UIControlStateNormal];
        if (i == 0) {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        button.backgroundColor = [UIColor whiteColor];
        button.tag = 120 + i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    _redView = [[UIView alloc]initWithFrame:CGRectMake(0, 37 + 64, buttonWidth, 2)];
    _redView.backgroundColor = navColor;
    [self.view addSubview:_redView];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 39 + 64, kScreenWidth, kScreenHeight - 64 - 39) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.listArray[indexPath.section];
    PrizeRecordTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PrizeRecordTableViewCell" owner:self options:nil]firstObject];
    if (!cell) {
        cell = [[PrizeRecordTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PrizeRecordTableViewCell"];
    }
    if ([dict[@"prize"] integerValue] <= 2) {
        cell.goodImageView.image = [UIImage imageNamed:@"myjiangpin_tongdou"];
    }else if ([dict[@"prize"] integerValue] <= 4){
        cell.goodImageView.image = [UIImage imageNamed:@"myjiangpin_tongbi.jpg"];
    }else{
        cell.goodImageView.image = [UIImage imageNamed:@"shangpin_2.jpg"];
    }
    cell.prizeLabel.text = [NSString stringWithFormat:@"奖       品：%@",dict[@"desc"]];
    cell.timeLabel.text =[NSString stringWithFormat:@"抽奖时间：%@",dict[@"time"]];
    if ([dict[@"status"] integerValue] == 0) {
        cell.stateLabel.text = [NSString stringWithFormat:@"奖品状态：未领取"];
        cell.contactLabel.text = [NSString stringWithFormat:@"联系客服领取奖品"];
    }
    if ([dict[@"status"] integerValue] == 1) {
        cell.stateLabel.text = [NSString stringWithFormat:@"奖品状态：已领取"];
        cell.contactLabel.text = @"";
    }
//    cell.contactLabel.text = [NSString stringWithFormat:@"联系客服领取奖品"];
    cell.imageView.image = [UIImage imageNamed:@""];
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.listArray[indexPath.section];
    if ([dict[@"status"] integerValue] == 0) {
        return 120;
    }
    return 120 - 34;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 5;
}

#pragma mark - 按钮调用的方法
-(void)buttonAction:(UIButton *)btn
{
    NSInteger index = btn.tag - 120;
    self.state = index;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _redView.frame = CGRectMake(index * (kScreenWidth / 3), 64 + 37, kScreenWidth / 3, 2);
    if (index == 0) {
        //全部商品
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:71];
        [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:72];
        [btn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
    }
    else if (index == 1) {
        //待领取
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:70];
        [btn1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:72];
        [btn2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    else
    {
        //已领取
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:70];
        [btn1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:71];
        [btn2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    _pageIndex = 1;
    [self fetchData:_pageIndex];
    [self.tableView.header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
