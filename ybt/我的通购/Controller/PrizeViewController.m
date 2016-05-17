//
//  PrizeViewController.m
//  0元夺宝
//
//  Created by mac on 16/4/2.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "PrizeViewController.h"
#import "PrizeDetailViewController.h"
#import "MJRefresh.h"
#import "HttpService.h"
#import "LogInViewController.h"
#import "UIImageView+AFNetworking.h"

@interface PrizeViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIView *_redView;//被选中按钮下方的红色线条
    
}

@property (strong,nonatomic) NSMutableArray *listArray;
@property (assign,nonatomic) NSInteger pageIndex;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSDictionary *userInfo;
@property (strong,nonatomic) NSNumber *state;

@end

@implementation PrizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.state = @0;
    [self _creatView];
    [self setNavItem];
    [self setRightNavItem];
    self.navigationController.navigationBar.hidden = NO;
}

-(void)_creatView
{
    NSArray *names = @[@"全部",@"待领取",@"已领取"];
    CGFloat buttonWidth = kScreenWidth / 3;
    for (int i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i * buttonWidth, 64, buttonWidth, 39);
        [button setTitle:names[i] forState:UIControlStateNormal];
        button.titleLabel.font = HGfont(14);
        if (i == 0) {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        button.backgroundColor = [UIColor whiteColor];
        button.tag = 70 + i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    _redView = [[UIView alloc]initWithFrame:CGRectMake(0, 37 + 64, buttonWidth, 2)];
    _redView.backgroundColor = navColor;
    [self.view addSubview:_redView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 39 + 64, kScreenWidth, kScreenHeight - 64 - 39) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = TABLE_BG_COLOR;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableView];
    
    self.listArray = [NSMutableArray array];
    self.tableView = tableView;
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

-(void)_createOnceView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + 38, kScreenWidth, kScreenHeight - 64 - 38 -49)];
    view.backgroundColor = TABLE_BG_COLOR;
    [self.view addSubview:view];
    
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 50, 55, 100, 100)];
    imgView.image = [UIImage imageNamed:@"tonggou_morentu"];
    [view addSubview:imgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom + 10, kScreenWidth, 12)];
    label.text = @"亲，您没有通购纪录哦";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = HGColor(153, 153, 153);
    label.font = HGfont(12);
    [view addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(kScreenWidth / 2 - 76, label.bottom + 28, 152, 34);
    button.layer.cornerRadius = 17;
    [button setBackgroundColor:HGColor(255, 153, 43)];
    [button setTitle:@"立即购买" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(buyMustButton) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}

//列表
- (void)fetchData:(NSInteger)page{
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
                            @"state":self.state};
    [service POST:user_prizesList parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *list = responseObject[@"listItems"];
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
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.listArray[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"prizeCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"prizeCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    UIView *disView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 5)];
    disView.backgroundColor = TABLE_BG_COLOR;
    [cell.contentView addSubview:disView];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 5, kScreenWidth, 30)];
    view.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:view];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UIFont *fnt = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    timeLabel.text = [NSString stringWithFormat:@"[第%@期]",dict[@"qishu"]];
//    timeLabel.font = [UIFont systemFontOfSize:14];
    timeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    timeLabel.textColor = [UIColor lightGrayColor];
    CGSize timeSize = [timeLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName, nil]];
    timeLabel.frame = CGRectMake(10, 8, timeSize.width, 14);
    [view addSubview:timeLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeSize.width + 20, 8, kScreenWidth - 20 - timeSize.width, 14)];
    titleLabel.text = [NSString stringWithFormat:@"%@",dict[@"title"]];
    titleLabel.font = [UIFont systemFontOfSize:14];
    [view addSubview:titleLabel];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 36, kScreenWidth, 100)];
    view1.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    [cell.contentView addSubview:view1];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    [imgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@statics/uploads/%@",HOST_PATH,dict[@"thumb"]]] placeholderImage:[UIImage imageNamed:@"shangpin_2.jpg"]];
    [view1 addSubview:imgView];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    UIFont *fnt1 = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    label1.text = @"获奖帐号:";
    label1.font = fnt1;
    label1.textColor = [UIColor lightGrayColor];
    CGSize labelSize1 = [label1.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt1,NSFontAttributeName, nil]];
    label1.frame = CGRectMake(100, 20, labelSize1.width, 20);
    [view1 addSubview:label1];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(100 + labelSize1.width + 10, 20, kScreenWidth - 110 - labelSize1.width, 20)];
    contentLabel.text = [NSString stringWithFormat:@"%@",dict[@"q_user"]];
    contentLabel.font = [UIFont systemFontOfSize:12];
    [view1 addSubview:contentLabel];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 40, contentLabel.frame.size.width, 20)];
    label2.text = @"本期参与:";
    label2.font = [UIFont systemFontOfSize:12];
    label2.textColor = [UIColor lightGrayColor];
    [view1 addSubview:label2];
    
    UILabel *contentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(100 + labelSize1.width + 10, 40, kScreenWidth - 110 - labelSize1.width, 20)];
    contentLabel2.text = [NSString stringWithFormat:@"%@人次",dict[@"canyurenshu"]];
    contentLabel2.font = [UIFont systemFontOfSize:12];
    [view1 addSubview:contentLabel2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(100, 60, contentLabel.frame.size.width, 20)];
    label3.text = @"幸运号码:";
    label3.font = [UIFont systemFontOfSize:12];
    label3.textColor = [UIColor lightGrayColor];
    [view1 addSubview:label3];
    
    UILabel *contentLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(100 + labelSize1.width + 10, 60, kScreenWidth - 110 - labelSize1.width, 20)];
    contentLabel3.text = [NSString stringWithFormat:@"%@",dict[@"q_user_code"]];;
    contentLabel3.font = [UIFont systemFontOfSize:12];
    contentLabel3.textColor = GREEN_LABEL_COLOR;
    [view1 addSubview:contentLabel3];
    
    UIImageView *prizeView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 63, view1.frame.size.height / 2 - 18, 63, 36)];
    prizeView.image = [UIImage imageNamed:@"zhongjiangla"];
    [view1 addSubview:prizeView];
    
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 137, kScreenWidth, 40)];
    view3.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:view3];
    
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 20)];
    stateLabel.text = @"奖品状态:";
    stateLabel.font = [UIFont systemFontOfSize:12];
    stateLabel.textColor = [UIColor lightGrayColor];
    [view3 addSubview:stateLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(stateLabel.width + 20, 10, kScreenWidth - stateLabel.width + - 20, 20);
    [button setTitle:[NSString stringWithFormat: @"%@",dict[@"stateInfo"]] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    [view3 addSubview:button];
    
    if ([dict[@"is_receive"] integerValue]> 0) {
        UIImageView *receiveImageView = [[UIImageView alloc] init];
        receiveImageView.bounds = CGRectMake(0, 0, 94.5, 54);
        receiveImageView.center = cell.contentView.center;
        [receiveImageView setImage:[UIImage imageNamed:@"yilingquzhang"]];
        [cell.contentView addSubview:receiveImageView];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 175;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.listArray[indexPath.row];
    PrizeDetailViewController * vc = [[PrizeDetailViewController alloc] init];
    vc.title = @"奖品详情";
    vc.dataInfo = dict;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 按钮调用的方法
-(void)buttonAction:(UIButton *)btn
{
    NSInteger index = btn.tag - 70;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _redView.frame = CGRectMake(index * (kScreenWidth / 3), 64 + 37, kScreenWidth / 3, 2);
    if (index == 0) {
        //全部商品
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:71];
        [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:72];
        [btn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.state = @0;

    }
    else if (index == 1) {
        //待领取
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:70];
        [btn1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:72];
        [btn2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.state = @1;
    }
    else
    {
        //已领取
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:70];
        [btn1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:71];
        [btn2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.state = @2;
    }
    
    self.pageIndex = 1;
    [self fetchData:self.pageIndex];
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
