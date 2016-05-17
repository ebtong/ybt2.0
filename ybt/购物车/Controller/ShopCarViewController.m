//
//  ShopCarViewController.m
//  0元夺宝
//
//  Created by hezhou on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "ShopCarViewController.h"
#import "WebViewController.h"
#import "ShoppingCarCell.h"
#import "MJRefresh.h"
#import "UIImageView+AFNetworking.h"
#import "PayViewController.h"
#import "TYAttributedLabel.h"

@interface ShopCarViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    CGFloat _money;
    CGFloat _score;
    TYAttributedLabel *_moneyLabel;
    NSMutableDictionary *cartList;
    NSMutableArray *idsArr;
}

@end

@implementation ShopCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"cartList"];
    _buyGoddsArray = [NSMutableArray array];
    // Do any additional setup after loading the view.
    [self _createView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"getCartNotification" object:nil];
    [self setRightNavItem];
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadData];
    self.tabBarController.tabBar.hidden = NO;
    [self.tableView.legendHeader beginRefreshing];
}

-(void)_createView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = TABLE_BG_COLOR;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview: _tableView];
    
    __weak typeof(self) weakSelf = self;
    
    // 添加传统的下拉刷新
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf loadData];
        [weakSelf.tableView.header endRefreshing];
    }];
    [self.tableView.legendHeader beginRefreshing];
    
    // 添加传统的上拉刷新
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [weakSelf loadData];
        [weakSelf.tableView.footer endRefreshing];
    }];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 49 - 48, kScreenWidth, 48)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    _moneyLabel = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(10, 14, kScreenWidth - 100, 20)];
    [view addSubview:_moneyLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(kScreenWidth -90, 0, 90, 48);
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button setBackgroundColor:HGColor(254, 91, 95)];
    button.titleLabel.font = HGfont(16);
    [button addTarget:self action:@selector(buyAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview: button];
}

-(void)loadData{
    cartList = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"cartList"]];
//    NSLog(@"cartList:%@",cartList);
    _money = 0.0;
    _score = 0.0;
    idsArr = [NSMutableArray array];
    [_buyGoddsArray removeAllObjects];
    for (NSString *cidStr in cartList) {
        NSDictionary *dict = cartList[cidStr];
        if ([dict[@"selected"] integerValue] > 0) {
            if (dict[@"info"][@"jfen"] && [dict[@"info"][@"jfenInfo"][@"is_jifen"] integerValue] == 1) {
                _score += [dict[@"info"][@"jfenInfo"][@"limit_num"] integerValue] * [dict[@"num"] integerValue];
            }else{
                _money += [dict[@"info"][@"yunjiage"]floatValue] * [dict[@"num"] integerValue];
            }
            [_buyGoddsArray addObject:cartList[cidStr]];
        }
        NSInteger gid = [dict[@"info"][@"id"] integerValue];
        [idsArr addObject: [NSNumber numberWithInteger:gid]];
    }
    NSString *scoreStr = @"";
    if (_score > 0) {
        scoreStr =[NSString stringWithFormat:@"<c>%.f<c>通豆",_score];
    }
    NSString *moneyStr = @"";
    if (_money > 0) {
        moneyStr = [NSString stringWithFormat:@"<c>%.2f<c>通币",_money];
    }
    NSString *str = [NSString stringWithFormat:@"共%li件奖品,总计:%@ %@", (unsigned long)_buyGoddsArray.count,moneyStr,scoreStr];
    _moneyLabel = [CommonUtil getLabel:_moneyLabel str:str color:@[NORMAL_LABEL_COLOR,RED_BTN_COLOR] font:@[@14]];
    
    [self loadDataByIds];
}

-(void)reloadData{
    cartList = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"cartList"]];
    [_buyGoddsArray removeAllObjects];
    for (NSString *cidStr in cartList) {
        NSDictionary *dict = cartList[cidStr];
        if ([dict[@"selected"] integerValue] > 0) {
            if (dict[@"info"][@"jfen"] && [dict[@"info"][@"jfenInfo"][@"is_jifen"] integerValue] == 1) {
                _score += [dict[@"info"][@"jfenInfo"][@"limit_num"] integerValue] * [dict[@"num"] integerValue];
            }else{
                _money += [dict[@"info"][@"yunjiage"]floatValue] * [dict[@"num"] integerValue];
            }
            [_buyGoddsArray addObject:cartList[cidStr]];
        }
    }
    
    _goodsArray = [NSMutableArray array];
    for (int i = 0; i <idsArr.count; i++) {
        NSString *cidStr = [NSString stringWithFormat:@"cart_%@",idsArr[i]];
        [_goodsArray addObject:cartList[cidStr]];
    }
    
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadCartNotification" object:nil];
}



-(void)loadDataByIds{
    NSString *idsStr = [CommonUtil getJSONStr:idsArr];
    if (idsStr == nil ) {
        return;
    }
    
    cartList = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"cartList"]];
    
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"ids":idsStr};
    [service POST:goods_listByIds parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *goodsArr = responseObject;
        idsArr = [NSMutableArray array];
        if (goodsArr.count > 0) {
            for (int i = 0; i < [goodsArr count]; i++) {
                NSDictionary *dict = goodsArr[i];
                NSString *goodsId = dict[@"id"];
                [idsArr addObject: goodsId];
                NSString *cart_id = [NSString stringWithFormat:@"cart_%@",goodsId];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:cartList[cart_id]];
                dic[@"info"] = dict;
                cartList[cart_id] = dic;
            }
        }else{
            [cartList removeAllObjects];
        }
        
        [[NSUserDefaults standardUserDefaults]setObject:cartList forKey:@"cartList"];
        [self reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *dict = _goodsArray[indexPath.section];
    NSDictionary *goodsInfo = dict[@"info"];
    NSString *num = dict[@"num"];
    BOOL selected = [dict[@"selected"] integerValue] > 0 ? YES : NO;

    ShoppingCarCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"ShoppingCarCell" owner:self options:nil]firstObject];
    cell.cartInfo = dict;
    
    cell.dataNumLanle.text =[NSString stringWithFormat:@"商品期数：第%@期",goodsInfo[@"qishu"]] ;
    cell.selectButton.selected = selected;
    
    [cell.goodImageView setImageWithURL:[CommonUtil getImageNsUrl:goodsInfo[@"thumb"]] placeholderImage:[UIImage imageNamed:@"Default diagram_Small"]];
    if(goodsInfo[@"jfenInfo"]){
        UIImageView *kindImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"biaoqian"]];
        kindImageView.frame = CGRectMake(0, 0, 60.0 / 750.0 * kScreenWidth, 60.0 / 750.0 * kScreenWidth * 39.0 / 30.0);
        [cell.goodImageView addSubview:kindImageView];
    }
    
    cell.numberField.text = [NSString stringWithFormat:@"%@",num];
    cell.allNumberLable.text = [NSString stringWithFormat:@"总需%@",goodsInfo[@"zongrenshu"]] ;
    NSString *overStr = [NSString stringWithFormat:@"剩余<c>%@",goodsInfo[@"shenyurenshu"]];
    
    cell.overNumberLable = [CommonUtil getLabel:cell.overNumberLable str:overStr color:@[GREY_LABEL_COLOR,GREEN_LABEL_COLOR] font:@[@10]];
    
    cell.allCount = goodsInfo[@"shenyurenshu"];
    
    if ([num integerValue] == [goodsInfo[@"shenyurenshu"] integerValue]) {
        cell.getAllGoodsButton.backgroundColor = ORANGE_BG_COLOR;
        [cell.getAllGoodsButton setTitleColor:ORANGE_LABEL_COLOR forState:UIControlStateNormal];
    }
    cell.titleLabel.text = goodsInfo[@"title"];
    cell.showButtonLabel.text = [NSString stringWithFormat:@"本期近剩%@人次可参与，已自动为你调整",goodsInfo[@"shenyurenshu"]];
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _goodsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = _goodsArray[indexPath.section];
    NSString *num = dict[@"num"];
    NSDictionary *goodsInfo = dict[@"info"];
    if ([num integerValue] >= [goodsInfo[@"shenyurenshu"] integerValue]) {
        return 174;
    }
    
    return 150;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(void)buyAction
{
    NSMutableDictionary *goodsList = [NSMutableDictionary dictionary];
    NSMutableArray *goodsArr = [NSMutableArray array];
    for (int i = 0; i < _buyGoddsArray.count; i++) {
        NSDictionary *dict = _buyGoddsArray[i];
        goodsList[@"id"] = dict[@"info"][@"id"];
        goodsList[@"num"] = dict[@"num"];
        [goodsArr addObject:goodsList];
        NSString *cart_id = [NSString stringWithFormat:@"cart_%@",dict[@"info"][@"id"]];
        [cartList removeObjectForKey:cart_id];
    }
//    [[NSUserDefaults standardUserDefaults] setObject:cartList forKey: @"cartList"];
    PayViewController *vc = [[PayViewController alloc] init];
    vc.listArray = _buyGoddsArray;
    vc.title = @"选择支付方式";
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{

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
