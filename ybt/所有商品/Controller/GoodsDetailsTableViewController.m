//
//  GoodsDetailsTableViewController.m
//  一币通购
//
//  Created by 少蛟 周 on 16/4/12.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "GoodsDetailsTableViewController.h"
#import "HttpService.h"
#import "UIImageView+AFNetworking.h"
#import "KGModal.h"
#import "SVProgressHUD.h"
#import "ThemeButton.h"
#import "InvolvedListViewController.h"
#import "HtmlViewController.h"
#import "WXApi.h"
#import "KL_ImageZoomView.h"
#import "InviteFriendsViewController.h"
#import "MJRefresh.h"
#import "SdListDelegate.h"

@interface GoodsDetailsTableViewController ()<UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UILabel *allCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *surplusLabel;
@property (weak, nonatomic) IBOutlet UILabel *statementLabel;
@property (strong,nonatomic) UIScrollView *imageScrollView;
@property (strong,nonatomic) UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *surplusMsgLabel;
@property (assign,nonatomic)  NSInteger timesCount;
@property (nonatomic) enum WXScene currentScene;

@property (strong,nonatomic) NSMutableArray *listArray;
@property (assign,nonatomic) NSInteger pageIndex;

@property (strong, nonatomic) SdListDelegate *sdListDelegate;

@end

@implementation GoodsDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.goodsInfo){
        [self loadTable];
    }
    self.sdListDelegate = [[SdListDelegate alloc]initWithViewController:self];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"appSetting"]) {
        NSDictionary *appSetting = [[NSUserDefaults standardUserDefaults] objectForKey:@"appSetting"];
        if ([appSetting[@"thirdHide"] integerValue] == 1 || ![WXApi isWXAppInstalled]) {
            _shareBtn.hidden = YES;
        }else{
            _shareBtn.hidden = NO;
        }
    }
    
    [self loadData];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init] ];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    
    
    self.listArray = [NSMutableArray array];
    //    self.listArray1 = [NSMutableArray array];
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    __weak typeof(self) weakSelf = self;
    
    // 添加传统的下拉刷新
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf loadData];
        weakSelf.pageIndex = 1;
        [weakSelf fetchSdData:weakSelf.pageIndex];
        [weakSelf.tableView.header endRefreshing];
    }];
    [self.tableView.legendHeader beginRefreshing];
    
    // 添加传统的上拉刷新
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        weakSelf.pageIndex ++;
        [weakSelf fetchSdData:weakSelf.pageIndex];
        [weakSelf.tableView.footer endRefreshing];
    }];
}

-(void)joinBtn{
    [self loadData:[NSString stringWithFormat:@"%ld",(long)self.timesCount]];
}

//列表
- (void)fetchSdData:(NSInteger)page{
    HttpService *service = [HttpService getInstance];
    NSString *sid = self.goodsInfo ? self.goodsInfo[@"sid"] : @"0";
    NSDictionary *param = @{@"page":[NSString stringWithFormat:@"%zi",page],
                            @"sid":sid};
//    NSLog(@"param:%@",param);
    [service POST:goods_sdListBySid parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *list = responseObject[@"listItems"];
//        NSLog(@"list:%@",list);
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
        self.sdListDelegate.listArray = self.listArray;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)addCart{
    if (!self.goodsInfo) {
        [SVProgressHUD showErrorWithStatus:@"请等待数据加载后，再试！"];
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"goodsInfo"] = self.goodsInfo;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addCartNotification" object:nil userInfo:userInfo];
}

-(void)loadData{
    [SVProgressHUD showWithStatus:@"正在加载" maskType:SVProgressHUDMaskTypeBlack];
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"goods_id":self.goods_id};
    [service POST:goods_goodsDetail parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.goodsInfo = responseObject;
        [self loadTable];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)loadTable{
    self.titleLabel.text = self.goodsInfo[@"title"];
    self.infoLabel.text = self.goodsInfo[@"title2"];
    if (!self.timesCount) {
        self.timesCount = [self.goodsInfo[@"now_qishu"] integerValue];
    }
    if([self.goodsInfo[@"qishu"] integerValue] == self.timesCount){
        self.vc.is_new = YES;
    }else{
        self.vc.is_new = NO;
    }
    [self.vc createBottomView];
    [SVProgressHUD dismiss];
    [self.tableView reloadData];
}

-(void)loadData:(NSString *)qishu{
    [SVProgressHUD showWithStatus:@"正在加载" maskType:SVProgressHUDMaskTypeBlack];
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"sid":self.goodsInfo[@"sid"],
                            @"qishu":qishu};
    [service POST:goods_goodsDetailByQishu parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.goodsInfo = responseObject;
        [self loadTable];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.goodsInfo) {
        return 0;
    }
    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.goodsInfo) {
        return 0;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            _imageScrollView = [[UIScrollView alloc]initWithFrame:cell.contentView.bounds];
            [cell.contentView addSubview:_imageScrollView];
            NSInteger imageCount = [self.goodsInfo[@"picArr"] count];
            _imageScrollView.contentSize = CGSizeMake(kScreenWidth * imageCount, cell.height);
            self.imageScrollView.showsHorizontalScrollIndicator = NO;
            self.imageScrollView.showsVerticalScrollIndicator = NO;
            _imageScrollView.pagingEnabled = YES;
            _imageScrollView.bounces = NO;
            for (int i = 0; i<imageCount; i++) {
                NSURL *url =[CommonUtil getImageNsUrl:self.goodsInfo[@"picArr"][i]];
                CGFloat x = _imageScrollView.width * i;
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, 0, _imageScrollView.width, _imageScrollView.height)];
                [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"not_find"]];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = YES;
                [_imageScrollView addSubview:imageView];
            }
            _pageControl = [[UIPageControl alloc]init];
            _pageControl.center = CGPointMake(kScreenWidth / 2, cell.height - 30);
            _pageControl.bounds = CGRectMake(0, 0, 100, 30);
            self.pageControl.numberOfPages = imageCount;
            self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
            self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
            [cell.contentView addSubview:_pageControl];
        }
        else if(indexPath.row == 1)
        {
            
            UIScrollView *timesScrollView = [[UIScrollView alloc]initWithFrame:cell.contentView.bounds];
            [cell.contentView addSubview:timesScrollView];
            timesScrollView.showsHorizontalScrollIndicator = NO;
            timesScrollView.showsVerticalScrollIndicator = NO;

            NSInteger timesCount = self.timesCount;
            timesScrollView.contentSize = CGSizeMake(102 * timesCount, cell.height);
            timesScrollView.bounces = NO;
            for (NSInteger i = timesCount ; i > 0; i--) {
                CGFloat btn_x = 102 * (timesCount - i);
                UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(btn_x, 0, 101,cell.height)];
                [btn setTitle:[NSString stringWithFormat:@"第%ld期",(long)i] forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:12];
                
                [btn addTarget:self action:@selector(timesBtnPress:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = i;
                
                if ([self.goodsInfo[@"qishu"] integerValue] == i)
                {
                    btn.backgroundColor = [UIColor whiteColor];
                    [btn setTitleColor:GREEN_LABEL_COLOR forState:UIControlStateNormal];
                    if (btn_x > kScreenWidth - 101)
                    {
                        [timesScrollView setContentOffset:CGPointMake(btn_x, 0) animated:YES];
                    }
                }
                else
                {
                    btn.backgroundColor = CELL_BG_COLOR;
                    [btn setTitleColor:NORMAL_LABEL_COLOR forState:UIControlStateNormal];
                }
                [timesScrollView addSubview:btn];
                UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(btn.right, 0, 1, btn.height)];
                timesScrollView.backgroundColor = TABLE_BG_COLOR;
                [timesScrollView addSubview:lineView];
            }
        }
        else if(indexPath.row == 2)
        {
            UIView *infoView = [cell.contentView viewWithTag:99];
            [infoView removeFromSuperview];
            if ([self.goodsInfo[@"q_uid"] integerValue] > 0)
            {
//                [self.allCountLabel removeFromSuperview];
//                [self.surplusLabel removeFromSuperview];
//                [self.surplusMsgLabel removeFromSuperview];
                self.allCountLabel.hidden = YES;
                self.surplusLabel.hidden = YES;
                self.surplusMsgLabel.hidden = YES;
                
                UIView *infoView = [[UIView alloc]initWithFrame:CGRectMake(self.progressView.left, self.progressView.top, self.progressView.width, 117)];
                infoView.backgroundColor = HGColor(248, 235, 218);
                infoView.tag = 99;
                [cell.contentView addSubview:infoView];
                
                UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(3, 3, infoView.width - 6, infoView.height -6)];
                contentView.layer.cornerRadius = 6;
                contentView.backgroundColor = [UIColor whiteColor];
                contentView.clipsToBounds = YES;
                [infoView addSubview:contentView];
                
                UIImageView *headerBgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, contentView.height - 30, contentView.height - 30)];
                
                UIImageView *headerImage = [[UIImageView alloc]init ];
                headerImage.bounds = CGRectMake(0, 0, 40, 40);
                headerImage.center = headerBgView.center;
                [headerImage setImageWithURL:[CommonUtil getImageNsUrl:@""] placeholderImage:[UIImage imageNamed:@"touxiang_88"]];
                [contentView addSubview:headerImage];
                
                [headerBgView setImage:[UIImage imageNamed:@"zhongjiang_1"]];
                [contentView addSubview:headerBgView];
                
                UIButton *codeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, headerBgView.bottom, infoView.width * 2.0 / 3, 30)];
                codeBtn.backgroundColor = ORANGE_LABEL_COLOR;
                [codeBtn setTitle:[NSString stringWithFormat:@"幸运号码：%@",self.goodsInfo[@"q_user_code"]] forState:UIControlStateNormal];
                [codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                codeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                [contentView addSubview:codeBtn];
                
                UIButton *msgBtn = [[UIButton alloc]initWithFrame:CGRectMake(codeBtn.width, headerBgView.bottom, infoView.width * 1 / 3, 30)];
                msgBtn.backgroundColor = GREEN_LABEL_COLOR;
                msgBtn.titleLabel.font = [UIFont systemFontOfSize:14];
                [msgBtn setTitle:@"计算详情>" forState:UIControlStateNormal];
                [msgBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [contentView addSubview:msgBtn];
                
                UILabel *userMsgLabel = [[UILabel alloc]initWithFrame:CGRectMake(headerBgView.right + 10, 5, 60, 14)];
                userMsgLabel.font = [UIFont systemFontOfSize:12];
                userMsgLabel.text = @"获奖用户:";
                userMsgLabel.textColor = GREY_LABEL_COLOR;
                [contentView addSubview:userMsgLabel];
                
                CGFloat labelWidth = contentView.width - userMsgLabel.width - 5;
                
                UILabel *userLabel = [[UILabel alloc]initWithFrame:CGRectMake(userMsgLabel.right + 5, 5, labelWidth, 14)];
                userLabel.font = [UIFont systemFontOfSize:12];
                userLabel.text = self.goodsInfo[@"quer"][@"username"];
                userLabel.textColor = GREY_LABEL_COLOR;
                [contentView addSubview:userLabel];
                
                UILabel *ipMsgLabel = [[UILabel alloc]initWithFrame:CGRectMake(headerBgView.right + 10, userMsgLabel.bottom + 5, 60, 14)];
                ipMsgLabel.font = [UIFont systemFontOfSize:12];
                ipMsgLabel.text = @"用户 I P :";
                ipMsgLabel.textColor = GREY_LABEL_COLOR;
                [contentView addSubview:ipMsgLabel];
                
                UILabel *ipLabel = [[UILabel alloc]initWithFrame:CGRectMake(userMsgLabel.right + 5, userMsgLabel.bottom + 5, labelWidth, 14)];
                ipLabel.font = [UIFont systemFontOfSize:12];
                ipLabel.text = self.goodsInfo[@"quer"][@"user_ip"];
                ipLabel.textColor = GREY_LABEL_COLOR;
                [contentView addSubview:ipLabel];
                
                UILabel *countMsgLabel = [[UILabel alloc]initWithFrame:CGRectMake(headerBgView.right + 10, ipLabel.bottom + 5, 60, 14)];
                countMsgLabel.font = [UIFont systemFontOfSize:12];
                countMsgLabel.text = @"本次参与:";
                countMsgLabel.textColor = GREY_LABEL_COLOR;
                [contentView addSubview:countMsgLabel];
                
                UILabel *countLabel = [[UILabel alloc]initWithFrame:CGRectMake(userMsgLabel.right + 5, ipLabel.bottom + 5, labelWidth, 14)];
                countLabel.font = [UIFont systemFontOfSize:12];
                countLabel.text = [NSString stringWithFormat:@"%@人次",self.goodsInfo[@"quer"][@"u_times"]];
                countLabel.textColor = GREY_LABEL_COLOR;
                [contentView addSubview:countLabel];
                
                UILabel *timeMsgLabel = [[UILabel alloc]initWithFrame:CGRectMake(headerBgView.right + 10, countLabel.bottom + 5, 60, 14)];
                timeMsgLabel.font = [UIFont systemFontOfSize:12];
                timeMsgLabel.text = @"揭晓时间:";
                timeMsgLabel.textColor = GREY_LABEL_COLOR;
                [contentView addSubview:timeMsgLabel];
                
                UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(userMsgLabel.right + 5, countLabel.bottom + 5, labelWidth, 14)];
                timeLabel.font = [UIFont systemFontOfSize:12];
                timeLabel.text = [NSString stringWithFormat:@"%@",self.goodsInfo[@"q_end_time"]];
                timeLabel.textColor = GREY_LABEL_COLOR;
                [contentView addSubview:timeLabel];
                
            }
            else
            {
                self.allCountLabel.hidden = NO;
                self.surplusLabel.hidden = NO;
                self.surplusMsgLabel.hidden = NO;
                
                self.allCountLabel.text = [NSString stringWithFormat:@"总需%@",self.goodsInfo[@"zongrenshu"]];
                self.surplusLabel.text = [NSString stringWithFormat:@"%@",self.goodsInfo[@"shenyurenshu"]];
                CGFloat progressWidth = [self.goodsInfo[@"canyurenshu"] floatValue]/[self.goodsInfo[@"zongrenshu"] floatValue] * self.progressView.width;
                UIView *proView = [[UIView alloc]initWithFrame:CGRectMake(0,0, progressWidth, self.progressView.height)];
                proView.layer.cornerRadius = 3.0;
                proView.clipsToBounds = YES;
                proView.backgroundColor = GREEN_LABEL_COLOR;
                
                [self.progressView addSubview:proView];
                self.progressView.layer.cornerRadius = 3.0;
                self.progressView.clipsToBounds = YES;
                
            }
        }
    }
    else if(indexPath.section == 4)
    {
        if (indexPath.row == 1)
        {
            for (id view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            CGFloat width = kScreenWidth / 3.0;
            NSDictionary *userList = self.goodsInfo[@"userList"];
            NSString *imageUrl = @"";
            NSString *nameStr = @"";
            NSString *infoStr = @"";
            if (userList)
            {
                NSDictionary *firstUser = userList[@"first"];
                if ([firstUser[@"state"] integerValue] > 0) {
                    imageUrl = firstUser[@"uphoto"];
                    nameStr = firstUser[@"username"];
                    infoStr = [NSString stringWithFormat:@"参与%@人次",firstUser[@"nums"]];
                }
                else
                {
                    nameStr = @"虚位以待";
                    infoStr = @"参与最多";
                }
                
                UIImageView *FNimageView = [[UIImageView alloc ]initWithFrame:CGRectMake(width/2 - 22, 15, 44, 44)];
                [FNimageView setImageWithURL:[CommonUtil getImageNsUrl:imageUrl] placeholderImage:[UIImage imageNamed:@"touxiang_nor"]];
                [cell.contentView addSubview:FNimageView];
                FNimageView.clipsToBounds = YES;
                FNimageView.layer.cornerRadius = 22.0;
                UILabel *FNLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, FNimageView.bottom + 5, width, 14)];
                FNLabel.text = nameStr;
                FNLabel.textAlignment = NSTextAlignmentCenter;
                FNLabel.font = [UIFont systemFontOfSize:12];
                FNLabel.textColor = NORMAL_LABEL_COLOR;
                [cell.contentView addSubview:FNLabel];
                
                UILabel *FTLabel = [[UILabel alloc]initWithFrame:CGRectMake(FNimageView.center.x - 25, FNLabel.bottom + 5, 50, 14)];
                FTLabel.font = [UIFont systemFontOfSize:11];
                FTLabel.textColor = ORANGE_LABEL_COLOR;
                FTLabel.backgroundColor = ORANGE_BG_COLOR;
                FTLabel.text = @"土豪";
                FTLabel.layer.cornerRadius = 7;
                FTLabel.clipsToBounds = YES;
                FTLabel.textAlignment = NSTextAlignmentCenter;
                [cell.contentView addSubview:FTLabel];
                UILabel *FBabel = [[UILabel alloc]initWithFrame:CGRectMake(0, FTLabel.bottom + 5, width, 14)];
                
                FBabel.text = infoStr ;
                FBabel.font = [UIFont systemFontOfSize:12];
                FBabel.textColor = GREY_LABEL_COLOR;
                FBabel.textAlignment = NSTextAlignmentCenter;
                [cell.contentView addSubview:FBabel];
                
                
                NSDictionary *secondUser = userList[@"second"];
                if ([secondUser[@"state"] integerValue] > 0)
                {
                    imageUrl = secondUser[@"uphoto"];
                    nameStr = secondUser[@"username"];
                }
                else
                {
                    nameStr = @"虚位以待";
                }
                
                UIImageView *SNimageView = [[UIImageView alloc ]initWithFrame:CGRectMake(width +width/2 - 22, 15, 44, 44)];
                [SNimageView setImageWithURL:[CommonUtil getImageNsUrl:imageUrl] placeholderImage:[UIImage imageNamed:@"touxiang_nor"]];
                [cell.contentView addSubview:SNimageView];
                SNimageView.clipsToBounds = YES;
                SNimageView.layer.cornerRadius = 22.0;
                UILabel *SNLabel = [[UILabel alloc]initWithFrame:CGRectMake(width, SNimageView.bottom + 5, width, 14)];
                SNLabel.text = nameStr;
                SNLabel.textAlignment = NSTextAlignmentCenter;
                SNLabel.font = [UIFont systemFontOfSize:12];
                SNLabel.textColor = NORMAL_LABEL_COLOR;
                [cell.contentView addSubview:SNLabel];
                
                UILabel *STLabel = [[UILabel alloc]initWithFrame:CGRectMake(SNLabel.center.x - 25, SNLabel.bottom + 5, 50, 14)];
                STLabel.font = [UIFont systemFontOfSize:11];
                STLabel.textColor = ORANGE_LABEL_COLOR;
                STLabel.backgroundColor = ORANGE_BG_COLOR;
                STLabel.layer.cornerRadius = 7;
                STLabel.clipsToBounds = YES;
                STLabel.text = @"沙发";
                STLabel.textAlignment = NSTextAlignmentCenter;
                [cell.contentView addSubview:STLabel];
                UILabel *SBabel = [[UILabel alloc]initWithFrame:CGRectMake(width, STLabel.bottom + 5, width, 14)];
                SBabel.textAlignment = NSTextAlignmentCenter;
                SBabel.text = @"第一个参与";
                SBabel.textAlignment = NSTextAlignmentCenter;
                SBabel.font = [UIFont systemFontOfSize:12];
                SBabel.textColor = GREY_LABEL_COLOR;
                [cell.contentView addSubview:SBabel];
                
                NSDictionary *thirdUser = userList[@"third"];
                if (thirdUser)
                {
                    imageUrl = thirdUser[@"uphoto"];
                }
                UIImageView *TNimageView = [[UIImageView alloc ]initWithFrame:CGRectMake(2 * width +width/2 - 22, 15, 44, 44)];
                [TNimageView setImageWithURL:[CommonUtil getImageNsUrl:imageUrl] placeholderImage:[UIImage imageNamed:@"touxiang_nor"]];
                [cell.contentView addSubview:TNimageView];
                TNimageView.clipsToBounds = YES;
                TNimageView.layer.cornerRadius = 22.0;
                UILabel *TNLabel = [[UILabel alloc]initWithFrame:CGRectMake(2 * width, TNimageView.bottom + 5, width, 14)];
                TNLabel.text = @"邀请有奖";
                TNLabel.textAlignment = NSTextAlignmentCenter;
                TNLabel.font = [UIFont systemFontOfSize:12];
                TNLabel.textColor = GREY_LABEL_COLOR;
                [cell.contentView addSubview:TNLabel];
                
                UILabel *TTLabel = [[UILabel alloc]initWithFrame:CGRectMake(TNLabel.center.x - 25, TNLabel.bottom + 5, 54, 14)];
                TTLabel.font = [UIFont systemFontOfSize:11];
                TTLabel.textColor = [UIColor whiteColor];
                TTLabel.backgroundColor = ORANGE_LABEL_COLOR;
                TTLabel.text = @"邀请好友";
                TTLabel.layer.cornerRadius = 7;
                TTLabel.clipsToBounds = YES;
                TTLabel.textAlignment = NSTextAlignmentCenter;
                [cell.contentView addSubview:TTLabel];
                UILabel *TBabel = [[UILabel alloc]initWithFrame:CGRectMake(2 * width, TTLabel.bottom + 5, width, 14)];
                TBabel.textAlignment = NSTextAlignmentCenter;
                TBabel.text = @"你还没有好友参加";
                TBabel.textAlignment = NSTextAlignmentCenter;
                TBabel.font = [UIFont systemFontOfSize:12];
                TBabel.textColor = GREY_LABEL_COLOR;
                [cell.contentView addSubview:TBabel];
                
                UIButton *TTBtn = [[UIButton alloc]initWithFrame:CGRectMake(TBabel.left, TNimageView.top, width, TBabel.bottom)];
                [TTBtn addTarget:self action:@selector(TTBtnPress:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:TTBtn];
            }
        }
    }
    else if (indexPath.section == 5 && indexPath.row == 1)
    {
        CGFloat width = (kScreenWidth - 65 - 20) / 3;
//        NSLog(@"%ld",self.listArray.count);
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, (165 + width) * self.listArray.count)];
        tableView.delegate = self.sdListDelegate;
        tableView.dataSource = self.sdListDelegate;
        tableView.scrollEnabled = NO;
        tableView.tag = 77;
        tableView.tableFooterView = [[UIView alloc]init];
        [cell.contentView addSubview:tableView];
    }
    return cell;
}

-(void)TTBtnPress:(UIButton *)sender{
    [self.vc deleteBottomView];
    InviteFriendsViewController *vc = [[InviteFriendsViewController alloc] init];
    vc.title = @"邀请有奖";
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)timesBtnPress:(UIButton *)sender{
    NSInteger times = sender.tag;
    [self loadData:[NSString stringWithFormat:@"%ld",(long)times]];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 2 && indexPath.section == 0 && [self.goodsInfo[@"q_uid"] integerValue] > 0){
        return 196;
    }
    if (indexPath.section == 5 && indexPath.row == 1) {
        if (self.listArray.count != 0) {
            
            CGFloat width = (kScreenWidth - 65 - 20) / 3;
            return (165 + width) * self.listArray.count;
        }
        return 30;
    }
    if (tableView.tag == 77) {
        CGFloat width = (kScreenWidth - 65 - 20) / 3;
        return (165 + width);

    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        InvolvedListViewController *vc = [[UIStoryboard storyboardWithName:@"AllGoods" bundle:nil] instantiateViewControllerWithIdentifier:@"InvolvedListViewControllerID"];
        vc.goods_id = self.goodsInfo[@"id"];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.section == 2){
        HtmlViewController *vc = [[UIStoryboard storyboardWithName:@"AllGoods" bundle:nil] instantiateViewControllerWithIdentifier:@"HtmlViewControllerID"];
        vc.htmlStr = self.goodsInfo[@"content"];
        vc.name = self.goodsInfo[@"title"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.section == 3)
    {
        [SVProgressHUD showErrorWithStatus:@"暂无此功能，待后续开发"];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (IBAction)shareAction:(UIButton *)sender {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *view = (UIView *)[window viewWithTag:88];
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 108, kScreenWidth, 108)];
        view.tag = 88;
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [window addSubview:view];
        NSArray *names = @[@"share_wechat_bg",@"share_friend_bg",@"share_copy_bg",@"share_sina_bg"];
        NSArray *lables = @[@"微信好友",@"朋友圈",@"复制链接",@"新浪微博"];
        CGFloat width = (kScreenWidth - 48 * 4 - 40) / 3;
        for (int i = 0; i < 4; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(20 + (48 + width) * i, 18, 48, 48);
            [button setBackgroundImage:[UIImage imageNamed:names[i]] forState:UIControlStateNormal];
            button.tag = 60 + i;
            [button addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
            
            UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth / 4 * i , 85, kScreenWidth / 4, 14)];
            lable.text = lables[i];
            lable.font = [UIFont systemFontOfSize:14];
            lable.textAlignment = NSTextAlignmentCenter;
            lable.textColor = [UIColor grayColor];
            [view addSubview:lable];
        }
    }
    else
    {
        view.hidden = NO;
    }
}

-(void)shareButtonAction:(UIButton *)btn
{
    NSInteger count = btn.tag - 60;
    if (count == 0) {
        _currentScene = WXSceneSession;
        [self sendTextContent];
    }else if (count == 1) {
        _currentScene = WXSceneTimeline;
        [self sendTextContent];
    }else if (count == 2) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [NSString stringWithFormat:@"%@?/mobile/mobile/item/%@",HOST_PATH,self.goods_id];
        if (pasteboard == nil) {
            [SVProgressHUD showErrorWithStatus:@"复制失败"];
        }else {
            [SVProgressHUD showSuccessWithStatus:@"复制成功"];
        }
    }else{
        [SVProgressHUD showErrorWithStatus:@"暂无此功能，待后续开发"];
    }
}

- (void) sendTextContent
{
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    if (!userInfo) {
        [SVProgressHUD showErrorWithStatus:@"请登录"];
        return;
    }
    KL_ImageZoomView *imageView = [[KL_ImageZoomView alloc] initWithFrame:CGRectZero];
    NSString *imageUrl = [NSString stringWithFormat:@"%@statics/uploads/%@",HOST_PATH,self.goodsInfo[@"thumb"]];
    [imageView uddateImageWithUrl:imageUrl];
    
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:imageView.image];
    message.title = self.goodsInfo[@"title"];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [NSString stringWithFormat:@"%@?/mobile/mobile/item/%@",HOST_PATH,self.goods_id];
    
    message.mediaObject = ext;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _currentScene;
    [WXApi sendReq:req];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *view = (UIView *)[window viewWithTag:88];
    view.hidden = YES;
}


@end
