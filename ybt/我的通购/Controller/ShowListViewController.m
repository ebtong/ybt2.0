//
//  ShowListViewController.m
//  一币通购
//
//  Created by mac on 16/4/9.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "ShowListViewController.h"
#import "MJRefresh.h"
#import "LogInViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ShaiDanTableViewController.h"

@interface ShowListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIView *_redView;//被选中按钮下方的红色线条
    BOOL isShow;
}

@property (strong,nonatomic) NSMutableArray *listArray;
@property (assign,nonatomic) NSInteger pageIndex;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSDictionary *userInfo;
@property (strong,nonatomic) NSNumber *state;
//@property (strong,nonatomic) NSMutableArray *listArray1;

@end

@implementation ShowListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.state = @2;
    [self setNavItem];
    [self setRightNavItem];
    self.navigationController.navigationBar.hidden = NO;
    [self _createView];
    self.tableView.backgroundColor = TABLE_BG_COLOR;
}

-(void)_createView
{
    NSArray *names = @[@"已晒单",@"未晒单"];
    CGFloat buttonWidth = kScreenWidth / 2;
    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i * buttonWidth, 64, buttonWidth, 39);
        [button setTitle:names[i] forState:UIControlStateNormal];
        button.titleLabel.font = HGfont(15);
        if (i == 0) {
            button.selected = YES;
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        else
        {
            button.selected = NO;
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        button.backgroundColor = [UIColor whiteColor];
        button.tag = 160 + i;
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
    self.tableView = tableView;
    self.listArray = [NSMutableArray array];
//    self.listArray1 = [NSMutableArray array];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    __weak typeof(self) weakSelf = self;
    
    // 添加传统的下拉刷新
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        weakSelf.pageIndex = 1;
//        [weakSelf fetchData:weakSelf.pageIndex];
        [weakSelf chooseData:weakSelf.pageIndex];
        [weakSelf.tableView.header endRefreshing];
    }];
    [self.tableView.legendHeader beginRefreshing];
    
    // 添加传统的上拉刷新
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        weakSelf.pageIndex ++;
//        [weakSelf fetchData:weakSelf.pageIndex];
        [weakSelf chooseData:weakSelf.pageIndex];
        [weakSelf.tableView.footer endRefreshing];
    }];
    
}
-(void)_createOnceView
{
    UIView *view = (UIView *)[self.view viewWithTag:48];
    if (view) {
        view.hidden = NO;
        return;
    }
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + 38, kScreenWidth, kScreenHeight - 64 - 38 -49)];
    view.backgroundColor = TABLE_BG_COLOR;
    view.tag = 48;
    [self.view addSubview:view];
    
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 50, 55, 100, 100)];
    imgView.image = [UIImage imageNamed:@"tonggou_morentu"];
    [view addSubview:imgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom + 10, kScreenWidth, 12)];
    label.text = @"亲，您没有晒单哦";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = HGColor(153, 153, 153);
    label.font = HGfont(12);
    [view addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(kScreenWidth / 2 - 76, label.bottom + 28, 152, 34);
    button.layer.cornerRadius = 17;
    [button setBackgroundColor:HGColor(255, 153, 43)];
    [button setTitle:@"我要晒单" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showListButton) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
}

- (void)fetchData:(NSInteger)page{
    self.userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    if (!self.userInfo) {
        LogInViewController *vc = [[LogInViewController alloc] init];
        vc.title = @"登陆";
        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:nvc animated:YES completion:nil];
        return;
    }
//    #define user_shaidanList @"user/shaidanList" //晒单记录。@{@"uid":用户ID，“page”:页码}
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"page":[NSString stringWithFormat:@"%zi",page],
                            @"uid":self.userInfo[@"uid"],
                            };
    [service POST:user_shaidanList parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *list = responseObject[@"listItems"];
        if (page == 1) {
            [self.listArray removeAllObjects];
            [self.tableView.footer resetNoMoreData];
        }
        
//                有无更多数据
        if (responseObject == [NSNull null] ||[responseObject count] == 0) {
            [self.tableView.footer noticeNoMoreData];
        } else {
            [self.listArray addObjectsFromArray:list];
        }

        if (self.listArray.count  == 0) {
            
            [self _createOnceView];
        }
        else
        {
            UIView *view = (UIView *)[self.view viewWithTag:48];
            view.hidden = YES;
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

//列表
- (void)fetchData1:(NSInteger)page{
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
                            @"isShare":@0,
                            @"state":self.state};
    [service POST:user_prizesList parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *list = responseObject[@"listItems"];
        NSMutableArray *listArr = [NSMutableArray array];
        for (int i = 0; i<list.count; i++) {
            NSDictionary *dic = list[i];
            if ([dic[@"is_share"] integerValue] == 0) {
                [listArr addObject:dic];
            }
        }
        if (page == 1) {
            [self.listArray removeAllObjects];
            [self.tableView.footer resetNoMoreData];
        }
        
        //        有无更多数据
        if (responseObject == [NSNull null] ||[responseObject count] == 0) {
            [self.tableView.footer noticeNoMoreData];
        } else {
            [self.listArray addObjectsFromArray:listArr];
        }
        
        UIView *view = (UIView *)[self.view viewWithTag:48];
        view.hidden = YES;
        
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)chooseData:(NSInteger)page
{
    UIButton *btn1 = (UIButton *)[self.view viewWithTag:161];
    if (btn1.selected) {
        [self fetchData1:page];
    }
    else
    {
        [self fetchData:page];
    }
}

#pragma mark - 按钮调用的方法
-(void)buttonAction:(UIButton *)btn
{
    btn.selected = YES;
    NSInteger index = btn.tag - 160;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _redView.frame = CGRectMake(index * (kScreenWidth / 2), 64 + 37, kScreenWidth / 2, 2);
    self.pageIndex = 1;
    if (index == 0) {
        //已晒单
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:161];
        [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        btn1.selected = NO;
//        [self fetchData:self.pageIndex];
    }
    else
    {
        //未晒单
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:160];
        [btn1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        btn1.selected = NO;
//        [self fetchData1:self.pageIndex];
    }
    [self chooseData:self.pageIndex];
    [self.tableView.header beginRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"showCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        for (id subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
    UIButton *btn1 = (UIButton *)[self.view viewWithTag:160];
    UIButton *btn2 = (UIButton *)[self.view viewWithTag:161];
    if (btn2.selected) {
        NSDictionary *dict = self.listArray[indexPath.section];
        UIView *disView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 5)];
        disView.backgroundColor = TABLE_BG_COLOR;
        [cell.contentView addSubview:disView];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 5, kScreenWidth, 30)];
        view.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:view];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        UIFont *fnt = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        timeLabel.text =[NSString stringWithFormat:@"[第%@期]",dict[@"qishu"]];
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
        [imgView setImageWithURL:[CommonUtil getImageNsUrl:dict[@"thumb"]] placeholderImage:[UIImage imageNamed:@"Default diagram_Small"]];;
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
        
        UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
        stateLabel.text = [NSString stringWithFormat:@"晒单分享奖励%@通豆",dict[@"sdScore"]];
        stateLabel.font = [UIFont systemFontOfSize:12];
        stateLabel.textColor = [UIColor blackColor];
        [view3 addSubview:stateLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(kScreenWidth - 93, 8, 83, 24);
        [button setTitle:@"发布晒单" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.layer.cornerRadius = 12;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [ORANGE_LABEL_COLOR CGColor];
        button.tag = indexPath.section;
        [button addTarget:self action:@selector(isshowListButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentLeft;
        [view3 addSubview:button];
    }
    if (btn1.selected)
    {
        NSDictionary *dic = self.listArray[indexPath.section];
        UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 45, 45)];
        [headView setImageWithURL:[CommonUtil getImageNsUrl:dic[@"q_user_image"]] placeholderImage:[UIImage imageNamed:@"Default diagram_Small"]];
        headView.layer.cornerRadius = 22.5;
        headView.clipsToBounds = YES;
        [cell.contentView addSubview:headView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        UIFont *fnt1 = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        nameLabel.text = [NSString stringWithFormat:@"%@",dic[@"q_user"]];
        nameLabel.textColor = HGColor(100, 160, 255);
        nameLabel.font = fnt1;
        CGSize labelSize1 = [nameLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt1,NSFontAttributeName, nil]];
        nameLabel.frame = CGRectMake(65, 17, labelSize1.width, 15);
        [cell.contentView addSubview:nameLabel];
        
        UIImageView *rankView = [[UIImageView alloc] initWithFrame:CGRectMake(nameLabel.right + 11, 15, 19, 19)];
        rankView.image = [UIImage imageNamed:@"tongpai_1"];
        [cell.contentView addSubview:rankView];
        
        UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, nameLabel.bottom + 13, kScreenWidth - 65, 14)];
        dataLabel.font = HGfont(14);
        dataLabel.textColor = GREY_LABEL_COLOR;
        dataLabel.text = [NSString stringWithFormat:@"[%@期] %@",dic[@"qishu"],dic[@"title"]];
        [cell.contentView addSubview:dataLabel];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, dataLabel.bottom + 10, kScreenWidth - 65, 47)];
        contentLabel.font = HGfont(13);
        contentLabel.text = [NSString stringWithFormat:@"%@",dic[@"sd_content"]];
        contentLabel.numberOfLines = 3;
        [cell.contentView addSubview:contentLabel];
        
        CGFloat width = (kScreenWidth - 65 - 20) / 3;
        NSArray *arr = dic[@"imageArr"];
        for (int i = 0; i < arr.count; i++) {
            if ([arr[i] length] != 0) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(65 + i * (width + 5), contentLabel.bottom + 14, width, width)];
                [imageView setImageWithURL:[CommonUtil getImageNsUrl:arr[i]] placeholderImage:[UIImage imageNamed:@"Default diagram_Small"]];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.layer.borderColor = [CELL_BG_COLOR CGColor];
                imageView.layer.borderWidth = 1;
                imageView.clipsToBounds = YES;
                [cell.contentView addSubview:imageView];
            }
        }
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, contentLabel.bottom + width + 28, 100, 10)];
        timeLabel.textColor = TABLE_BG_COLOR;
        timeLabel.text = [NSString stringWithFormat:@"%@",dic[@"sd_time"]];
        timeLabel.font = HGfont(10);
        [cell.contentView addSubview:timeLabel];
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *btn2 = (UIButton *)[self.view viewWithTag:161];
    if (btn2.selected) {
        return 175;
    }
    CGFloat width = (kScreenWidth - 65 - 20) / 3;
    return 165 + width;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(void)showListButton
{
    UIView *view = (UIView *)[self.view viewWithTag:48];
    view.hidden = YES;
//    isShow = YES;
    _redView.frame = CGRectMake((kScreenWidth / 2), 64 + 37, kScreenWidth / 2, 2);
    self.pageIndex = 1;
        //已晒单
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:161];
        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn1.selected = YES;

        //未晒单
        UIButton *btn = (UIButton *)[self.view viewWithTag:160];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        btn.selected = NO;
        [self chooseData:self.pageIndex];

    [self.tableView.header beginRefreshing];
}

-(void)isshowListButton:(UIButton *)sender
{
    NSInteger sec = sender.tag;
    NSDictionary *dict = self.listArray[sec];
    ShaiDanTableViewController *vc = [[UIStoryboard storyboardWithName:@"Mine" bundle:nil]instantiateViewControllerWithIdentifier:@"ShaiDanTableViewControllerID"];
    vc.title = @"发布晒单";
    vc.orderId = dict[@"orderId"];
    [self.navigationController pushViewController:vc animated:YES];
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
