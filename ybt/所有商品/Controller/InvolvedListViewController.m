//
//  InvolvedListViewController.m
//  一币通购
//
//  Created by 少蛟 周 on 16/4/14.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "InvolvedListViewController.h"
#import "MJRefresh.h"
#import "HttpService.h"
#import "InvolvedListTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+Badge.h"

@interface InvolvedListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *listArray;
@property (assign,nonatomic) NSInteger pageIndex;

@end

@implementation InvolvedListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"通沟记录";
    self.listArray = [NSMutableArray array];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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
    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated{
    [self setNavItem];
    [self setRightNavItem];
}

//列表
- (void)fetchData:(NSInteger)page{
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"page":[NSString stringWithFormat:@"%zi",page],
                            @"goodsId":self.goods_id};
    [service POST:goods_involvedList parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = self.listArray[indexPath.row];
    InvolvedListTableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"InvolvedListTableViewCell" owner:self options:nil] firstObject];
    [cell.headImageView setImageWithURL:[CommonUtil getImageNsUrl:dict[@"uphoto"]] placeholderImage:[UIImage imageNamed:@"touxiang"]];
    cell.nameLabel.text = dict[@"username"];
    cell.IPLabel.text = dict[@"ip"];
    cell.headImageView.layer.cornerRadius = cell.headImageView.height / 2.0;
    cell.headImageView.clipsToBounds = YES;
    cell.countLabel.text = [NSString stringWithFormat:@"参与了%@人次",dict[@"gonumber"]];
    cell.timeLabel.text = dict[@"q_time"];
    return  cell;
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
