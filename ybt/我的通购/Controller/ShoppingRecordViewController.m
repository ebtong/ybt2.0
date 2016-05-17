//
//  ShoppingRecordViewController.m
//  一币通购
//
//  Created by mac on 16/4/5.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "ShoppingRecordViewController.h"
#import "MJRefresh.h"
#import "HttpService.h"
#import "LogInViewController.h"
#import "WinnerTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "RecordDetailTableViewController.h"
#import "AllGoodsViewController.h"

@interface ShoppingRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UIView *_redView;//被选中按钮下方的红色线条
}
@property (strong,nonatomic) NSMutableArray *listArray;
@property (assign,nonatomic) NSInteger pageIndex;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSDictionary *userInfo;
@property (strong,nonatomic) NSNumber *state;

@end

@implementation ShoppingRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.state = @0;
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = NO;
    
    [self _createView];
    [self setNavItem];
}


-(void)_createView
{
    NSArray *names = @[@"全部",@"进行中",@"已揭晓"];
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
        button.tag = 80 + i;
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
    [button addTarget:self action:@selector(buyMustButton) forControlEvents:UIControlEventTouchUpInside];
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
    [service POST:user_involvedGoods parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *list = responseObject[@"listItems"];
        if (list.count == 0) {
            if (self.state  == 0) {
                
                [self _createOnceView];
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
            [self.listArray addObjectsFromArray:list];
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

#pragma mark - 按钮调用的方法
-(void)buttonAction:(UIButton *)btn
{
    NSInteger index = btn.tag - 80;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _redView.frame = CGRectMake(index * (kScreenWidth / 3), 64 + 37, kScreenWidth / 3, 2);
    if (index == 0) {
        //全部
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:81];
        [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:82];
        [btn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.state = @0;
    }
    else if (index == 1) {
        //进行中
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:80];
        [btn1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:82];
        [btn2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.state = @1;
    }
    else
    {
        //已揭晓
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:80];
        [btn1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:81];
        [btn2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.state = @2;
    }
    self.pageIndex = 1;
    [self fetchData:self.pageIndex];
    [self.tableView.header beginRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dict = self.listArray[section];
    if ([dict[@"q_end_time"] integerValue] > 0) {
        return 2;
    }
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.listArray[indexPath.section];
    
    if (indexPath.row == 1) {
        WinnerTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"WinnerTableViewCell" owner:self options:nil]firstObject];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        [cell.contentView addSubview:lineView];
        [lineView setBackgroundColor:TABLE_BG_COLOR];
        
        [cell.headerImg setImageWithURL:[CommonUtil getImageNsUrl:dict[@"q_user_image"]] placeholderImage:[UIImage imageNamed:@"angelababy"]];
        cell.winnerLabel.text = [NSString stringWithFormat:@"%@",dict[@"q_user"]];
        cell.codeLabel.text = [NSString stringWithFormat:@"%@",dict[@"q_user_code"]];
//        NSLog(@"dict:%@",dict);
        cell.numLabel.text = [NSString stringWithFormat:@"%@人次",dict[@"q_times"]];
        cell.timeLabel.text = [NSString stringWithFormat:@"%@",dict[@"q_end_time"]];
        cell.contentView.backgroundColor = CELL_BG_COLOR;
        return  cell;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shoppingCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"shoppingCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        for (id subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
        UIView *disView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 5)];
        disView.backgroundColor = HGColor(234 , 234, 234);
        [cell.contentView addSubview:disView];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 5, kScreenWidth, 34)];
        view.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:view];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        UIFont *fnt = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        timeLabel.text = [NSString stringWithFormat:@"[第%@期]",dict[@"qishu"]];
        timeLabel.font = fnt;
        timeLabel.textColor = [UIColor lightGrayColor];
        CGSize timeSize = [timeLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName, nil]];
        timeLabel.frame = CGRectMake(10, 10, timeSize.width, 14);
        [view addSubview:timeLabel];
        
        UILabel *dlabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabel.right, timeLabel.top, kScreenWidth - timeLabel.right -10, 14)];
        dlabel.text = @"参与详情 >>";
        dlabel.textAlignment = NSTextAlignmentRight;
        dlabel.textColor = [UIColor orangeColor];
        dlabel.font = HGfont(14);
        [view addSubview:dlabel];
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 35, kScreenWidth, 100)];
        view1.backgroundColor = CELL_BG_COLOR;
        [cell.contentView addSubview:view1];
        
        
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
        [imgView setImageWithURL:[CommonUtil getImageNsUrl:dict[@"thumb"]] placeholderImage:[UIImage imageNamed:@"shangpin_2.jpg"]];
        [view1 addSubview:imgView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right + 5, 10, kScreenWidth - 10 - imgView.width, 0)];
        CGSize size = CGSizeMake(kScreenWidth - 20 - imgView.width, 20000);
        titleLabel.text = [NSString stringWithFormat:@"%@",dict[@"shopname"]];
        CGSize labelsize = [titleLabel.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.frame = CGRectMake(imgView.right + 5, 10, kScreenWidth - 20 - imgView.width, labelsize.height);
        titleLabel.numberOfLines = 0;
        [view1 addSubview:titleLabel];
        
        if ([dict[@"q_end_time"] integerValue] > 0)
        {
            UIFont *fnt1 = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
            
            UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectZero];
            label4.text = @"总需:";
            label4.font = fnt1;
            label4.textColor = [UIColor lightGrayColor];
            CGSize labelSize4 = [label4.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt1,NSFontAttributeName, nil]];
            label4.frame = CGRectMake(imgView.right + 5, view1.height -14-13-10 - 13, labelSize4.width, 13);
            [view1 addSubview:label4];
            
            UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectZero];
            label5.text = [NSString stringWithFormat:@"%@",dict[@"zongrenshu"]];
            label5.font = fnt1;
            label5.textColor = GREEN_LABEL_COLOR;
            CGSize labelSize5 = [label5.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14],NSFontAttributeName, nil]];
            label5.frame = CGRectMake(label4.right + 5, view1.height -14-13-10 - 13, labelSize5.width, 14);
            [view1 addSubview:label5];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
            label1.text = @"本期参与:";
            label1.font = fnt1;
            label1.textColor = [UIColor lightGrayColor];
            CGSize labelSize1 = [label1.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt1,NSFontAttributeName, nil]];
            label1.frame = CGRectMake(imgView.right + 5, view1.height - 14 - 13 , labelSize1.width, 14);
            [view1 addSubview:label1];
            
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectZero];
            label2.font = fnt1;
            label2.text = [NSString stringWithFormat:@"%@",dict[@"gonumber"]];;
            label2.textColor = GREEN_LABEL_COLOR;
            CGSize labelSize2 = [label2.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt1,NSFontAttributeName, nil]];
            label2.frame = CGRectMake(label1.right + 5, label4.bottom + 10, labelSize2.width, 14);
            [view1 addSubview:label2];
            
            UILabel *contentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(label2.right + 5, label4.bottom + 10, 90,14)];
            contentLabel2.text = @"人次";
            contentLabel2.font = [UIFont systemFontOfSize:14];
            [view1 addSubview:contentLabel2];
        }
        else{
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
            UIFont *fnt1 = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
            label1.text = @"本期参与:";
            label1.font = fnt1;
            label1.textColor = [UIColor lightGrayColor];
            CGSize labelSize1 = [label1.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt1,NSFontAttributeName, nil]];
            label1.frame = CGRectMake(imgView.right + 5, view1.height - 10 - 8 - 5 -6 -10 -13, labelSize1.width, 14);
            [view1 addSubview:label1];
            
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectZero];
            label2.font = fnt1;
            label2.text = [NSString stringWithFormat:@"%@",dict[@"gonumber"]];;
            label2.textColor = GREEN_LABEL_COLOR;
            CGSize labelSize2 = [label2.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt1,NSFontAttributeName, nil]];
            label2.frame = CGRectMake(label1.right + 5, view1.height - 10 - 8 - 5 -6 -10 -13, labelSize2.width, 14);
            [view1 addSubview:label2];
            
            UILabel *contentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(label2.right + 5, view1.height - 10 - 8 - 5 -6 -10 -13, 90,14)];
            contentLabel2.text = @"人次";
            contentLabel2.font = [UIFont systemFontOfSize:13];
            [view1 addSubview:contentLabel2];
            
            UIImageView *bottomimageView = [[UIImageView alloc] initWithFrame:CGRectMake(imgView.right + 5,  view1.frame.size.height - 10 -8 -5 -6, kScreenWidth - 220, 6)];
            UIImage *allCountImg = [UIImage imageNamed:@"chengzhangzhi_nor"];
            [bottomimageView setImage:[allCountImg stretchableImageWithLeftCapWidth:7 topCapHeight:0]];
            bottomimageView.layer.cornerRadius = 3;
            bottomimageView.clipsToBounds = YES;
            [view1 addSubview:bottomimageView];
            
            CGFloat imageWidth;
            if ([dict[@"zongrenshu"] integerValue] != 0)
            {
                imageWidth =  bottomimageView.width *([dict[@"zongrenshu"] floatValue] - [dict[@"shenyurenshu"] floatValue]) / [dict[@"zongrenshu"] floatValue];
            }
            else
            {
                imageWidth = bottomimageView.width;
            }
            UIImageView *countImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, 6)];
            countImageView.layer.cornerRadius = 3;
            [countImageView setBackgroundColor:GREEN_LABEL_COLOR];
//            UIImage *countImg = [UIImage imageNamed:@"chengzhangzh_sel"];
//            [countImageView setImage:[countImg stretchableImageWithLeftCapWidth:7 topCapHeight:0]];
            [bottomimageView addSubview:countImageView];
            
            UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectZero];
            label3.text = [NSString stringWithFormat:@"总需%@",dict[@"zongrenshu"]];
            label3.font = [UIFont systemFontOfSize:8];
            label3.textColor = [UIColor lightGrayColor];
            CGSize labelSize3 = [label3.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:8],NSFontAttributeName, nil]];
            label3.frame = CGRectMake(imgView.right + 5, view1.height - 10 - 8, labelSize3.width, 8);
            [view1 addSubview:label3];
            
            UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectZero];
            label4.text = [NSString stringWithFormat:@"%@",dict[@"shenyurenshu"]];
            label4.font = [UIFont systemFontOfSize:8];
            label4.textColor = [UIColor lightGrayColor];
            CGSize labelSize4 = [label4.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:11],NSFontAttributeName, nil]];
            label4.frame = CGRectMake(bottomimageView.right - labelSize4.width,  view1.height - 10 -8, labelSize4.width, 8);
            [view1 addSubview:label4];
            
            UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectZero];
            label5.text = @"剩余";
            label5.font = [UIFont systemFontOfSize:8];
            label5.textColor = [UIColor lightGrayColor];
            CGSize labelSize5 = [label5.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:11],NSFontAttributeName, nil]];
            label5.frame = CGRectMake(label4.left - labelSize5.width - 2,  view1.height - 10 - 8, labelSize5.width, 8);
            [view1 addSubview:label5];
            
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(view1.right - 10 - 84, view1.frame.size.height - 10 - 26, 84, 26);
            [button setBackgroundColor:[UIColor colorWithRed:255/255.0 green:153/255.0 blue:44/255.0 alpha:1]];
            button.layer.cornerRadius = 13;
            button.titleLabel.font = HGfont(14);
            [button setTitle:@"继续买" forState:UIControlStateNormal];
            [view1 addSubview:button];
        }
        
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //向vc的Label赋值
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.listArray[indexPath.section];
    RecordDetailTableViewController *vc = [[UIStoryboard storyboardWithName:@"Mine" bundle:nil]instantiateViewControllerWithIdentifier:@"RecordDetailTableViewControllerID"];
    vc.dataInfo = dict;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        return 100;
    }
    return 135;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(void)buyMustButton
{
    AllGoodsViewController *vc = [[AllGoodsViewController alloc]init];
    vc.title = @"所有商品";
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
