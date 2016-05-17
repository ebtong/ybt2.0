//
//  AccountDetailViewController.m
//  一币通购
//
//  Created by mac on 16/4/18.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "AccountDetailViewController.h"
#import "LogInViewController.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "TaskCenterTableViewController.h"

@interface AccountDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (assign,nonatomic) NSInteger pageIndex;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSDictionary *userInfo;
@property (strong,nonatomic) NSMutableArray *listArray;
@property (strong,nonatomic) NSMutableArray *dataArr;
@property (assign,nonatomic) NSInteger status;

@end

@implementation AccountDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    self.navigationController.navigationBar.hidden = NO;
    [self setNavItem];
    [self setRightNavItem];
    [self _createView];
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 134, 30)];
    titleView.layer.cornerRadius = 15;
    titleView.clipsToBounds = YES;
    titleView.layer.borderWidth = 1;
    titleView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(0, 0, 67, 30);
    [btn1 setTitle:@"通币" forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor whiteColor]];
    btn1.selected = YES;
    btn1.tag = 36;
    [btn1 addTarget:self action:@selector(titleButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setTitleColor:HGColor(64, 198, 179) forState:UIControlStateNormal];
    [titleView addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(67, 0, 67, 30);
    [btn2 setTitle:@"通豆" forState:UIControlStateNormal];
    btn2.tag = 37;
    [btn2 addTarget:self action:@selector(titleButton:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:btn2];
    
    self.navigationItem.titleView = titleView;
}
-(void)titleButton:(UIButton *)btn
{
    btn.selected = YES;
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn setTitleColor:HGColor(64, 198, 179) forState:UIControlStateNormal];
    if (btn.tag == 36) {
        UIButton *button = (UIButton *)[self.navigationItem.titleView viewWithTag:37];
        button.selected = NO;
        [button setBackgroundColor:HGColor(64, 198, 179)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _status = 0;
    }
    else
    {
        UIButton *button = (UIButton *)[self.navigationItem.titleView viewWithTag:36];
        button.selected = NO;
        [button setBackgroundColor:HGColor(64, 198, 179)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _status = 1;
    }
    
    self.pageIndex = 1;
    [self fetchData:self.pageIndex];
    [self.tableView.header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)_createView
{
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
    self.listArray = [NSMutableArray array];
    self.tableView = table;
    self.tableView.tableFooterView  = [[UIView alloc]init];
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
                            @"status":[NSNumber numberWithInteger:_status],
                            @"page":[NSString stringWithFormat:@"%zi",page]};
    [service POST:user_recordList parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        [self changeData];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void) changeData{
    NSMutableDictionary *dataList = [NSMutableDictionary dictionary];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < [self.listArray count]; i++) {
        NSDictionary *dict = self.listArray[i];

        NSString *monthStr = dict[@"month"];
        if (![[dataList allKeys] containsObject:monthStr]) {
            arr = [NSMutableArray array];
        }
        [arr addObject:dict];
        dataList[monthStr] = arr;
    }
    self.dataArr = [NSMutableArray array];
    for (NSString *str in dataList) {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"month"] = str;
        data[@"data"] = dataList[str];
        [self.dataArr addObject: data];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    NSDictionary *dict = self.dataArr[section - 1];
    
    return [dict[@"data"] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArr.count + 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 39)];
    headView.backgroundColor = TABLE_BG_COLOR;
    
    if (section == 0) {
        return nil;
    }
    NSDictionary *dict = self.dataArr[section - 1];
    UILabel *monthLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 150, 20)];
    
    monthLabel.text = dict[@"month"];
    monthLabel.font = HGfont(14);
    monthLabel.textColor = NORMAL_LABEL_COLOR;
    [headView addSubview:monthLabel];
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"accountCell"];
    }
    for (id subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0)
        {
            [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"zhanghumingxi_bg"]]];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 48, kScreenWidth, 20)];
            label.textColor = GREEN_LABEL_COLOR;
            label.font = HGfont(20);
            label.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, label.bottom + 10, kScreenWidth, 16)];
            label1.textColor = GREEN_LABEL_COLOR;
            label1.font = HGfont(16);
            label1.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label1];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(kScreenWidth / 2 - 56, label1.bottom + 48, 112, 32);
            [button setTitleColor:GREEN_LABEL_COLOR forState:UIControlStateNormal];
            button.titleLabel.font = HGfont(15);
            [button setBackgroundColor:[UIColor whiteColor]];
            button.layer.cornerRadius = 16;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            UIButton *button1 = (UIButton *)[self.navigationItem.titleView viewWithTag:36];
            if (button1.selected)
            {
                label1.text = @"通币";
                [button setTitle:@"立即充值" forState:UIControlStateNormal];

                button.tag = 11;
                if (_userInfo[@"money"])
                {
                    label.text = _userInfo[@"money"];
                }
                else
                {
                    label.text = 0;
                }
            }
            else
            {
                label1.text = @"通豆";
                [button setTitle:@"免费赚取通豆" forState:UIControlStateNormal];
                button.tag = 22;
                
                if (_userInfo[@"score"])
                {
                    label.text = _userInfo[@"score"];
                }
                else
                {
                    label.text = 0;
                }
            }
            [cell.contentView addSubview: button];
        }
    }else{
        cell.backgroundColor = [UIColor whiteColor];
        NSDictionary *dicts = self.dataArr[indexPath.section - 1];
        NSArray *list = dicts[@"data"];
        NSDictionary *dict =list[indexPath.row];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, kScreenWidth - 20 - 70, 14)];
        titleLabel.text = dict[@"content"];
        titleLabel.font = HGfont(12);
        titleLabel.textColor = NORMAL_LABEL_COLOR;
        [cell.contentView addSubview:titleLabel];
        
        UILabel *dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, titleLabel.bottom + 5, kScreenWidth - 20 - 70, 14)];
        dayLabel.text = dict[@"day"];
        dayLabel.font = HGfont(12);
        dayLabel.textColor = GREY_LABEL_COLOR;
        [cell.contentView addSubview:dayLabel];
        
        UILabel *moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleLabel.right + 10, 10, 60, 49 - 20)];
        moneyLabel.text = dict[@"score"];
        moneyLabel.font = HGfont(12);
        moneyLabel.textAlignment = NSTextAlignmentCenter;
        
        if ([dict[@"type"] integerValue] > 0) {
            moneyLabel.textColor = ORANGE_LABEL_COLOR;
        }else{
            moneyLabel.textColor = GREY_LABEL_COLOR;
        }
        [cell.contentView addSubview:moneyLabel];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 48, kScreenWidth, 1)];
        lineView.backgroundColor = TABLE_BG_COLOR;
        [cell.contentView addSubview:lineView];
        
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 208;
        }
    }
    return 49;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01;
    }
    return 39;
}

-(void)buttonAction:(UIButton *)btn
{

    if (btn.tag == 22) {
        [self showTask];
        return;
    }
    [SVProgressHUD showErrorWithStatus:@"暂无此功能，待稍后开发"];
    
}

-(void)showTask{
    TaskCenterTableViewController *vc = [[UIStoryboard storyboardWithName:@"Mine" bundle:nil]instantiateViewControllerWithIdentifier:@"TaskCenterTableViewControllerID"];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
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
