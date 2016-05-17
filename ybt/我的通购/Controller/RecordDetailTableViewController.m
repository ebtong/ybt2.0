//
//  RecordDetailTableViewController.m
//  一币通购
//
//  Created by 少蛟 周 on 16/4/8.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "RecordDetailTableViewController.h"
#import "GoodsDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface RecordDetailTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timesLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *allCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UIImageView *leftImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellView;
@property (assign, nonatomic) CGFloat cellHeight;

@end

@implementation RecordDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tableView.backgroundColor= [UIColor whiteColor];
//    self.view.backgroundColor = [UIColor whiteColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.cellHeight = 300 +kScreenHeight - 568;
    self.timesLabel.text = [NSString stringWithFormat:@"%@期",self.dataInfo[@"shopqishu"]];
    self.titleLabel.text = self.dataInfo[@"shopname"];
    self.allCountLabel.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"zongrenshu"]];
    self.countLabel.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"gonumber"]];
    self.timeLabel.text = [NSString stringWithFormat:@"%@",self.dataInfo[@"q_time"]];
    [self.leftImageVIew setImageWithURL:[CommonUtil getImageNsUrl:self.dataInfo[@"thumb"]] placeholderImage:[UIImage imageNamed:@"shangpin_2.jpg"]];
    NSArray *codeArr = self.dataInfo[@"codeArr"];
    CGFloat labelWidth = (kScreenWidth - 20.0 - 80 ) /3.0;
    CGFloat x = 0;
    CGFloat y = 0;
    for (NSInteger i = 0; i<codeArr.count; i++) {
        x = 80 + (i % 3) * labelWidth;
        y = 30 + 10 + (i / 3) * (16 + 10);
        UILabel *codeNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, labelWidth, 16)];
        codeNumLabel.font = [UIFont systemFontOfSize:14];
        codeNumLabel.textColor = GREY_LABEL_COLOR;
        codeNumLabel.text = [NSString stringWithFormat:@"%@",codeArr[i]];;
        [self.cellView.contentView addSubview:codeNumLabel];
        self.cellHeight = codeNumLabel.bottom + 30;
    }
    
    [self.tableView reloadData];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GoodsDetailViewController *vc = [[UIStoryboard storyboardWithName:@"AllGoods" bundle:nil] instantiateViewControllerWithIdentifier:@"GoodsDetailViewControllerID"];
    vc.goods_id = self.dataInfo[@"shopid"];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
    [lineView setBackgroundColor:TABLE_BG_COLOR];
    [cell.contentView addSubview:lineView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if(self.cellHeight > 300){
            return self.cellHeight;
        }else{
            return 300;
        }
        
    }
    
   return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}

-(void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
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
