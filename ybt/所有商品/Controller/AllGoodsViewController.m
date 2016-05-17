//
//  AllGoodsViewController.m
//  0元夺宝
//
//  Created by hezhou on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "AllGoodsViewController.h"
#import "WebViewController.h"
#import "GoodCell.h"
#import "MJRefresh.h"
#import "GoodsDetailViewController.h"
#import "TreasureTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "KGModal.h"
#import "UIView+Badge.h"

@interface AllGoodsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSMutableArray *_array;
    UIView *_redView;//被选中按钮下方的红色线条
    NSArray *_cateArr;
    UIView *bgView;//被选中按钮下方的红色线条
    UIButton *selectedCBtn;
    UITextField *_searchText;
    NSMutableArray *_history;
}

@property (assign,nonatomic) NSInteger pageIndex;
@property (strong,nonatomic) UIImageView *cartImage;

@end

@implementation AllGoodsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    _cid = [_cid integerValue] > 0 ? _cid : @"";
    _keywords = @"";
    _orderBy = [_orderBy integerValue] > 0 ? _orderBy : @"";
    _array = [NSMutableArray array];
    self.navigationItem.hidesBackButton = YES;
    _findView.layer.cornerRadius = 16;
    _findTextField.text = self.keywords;
    _findTextField.delegate = self;
    [_findTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    _history = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"historySearch"]];
    [self setRightNavItem];
    [self loadCategoryList];
    
    // Do any additional setup after loading the view.
    [self _createCollectionView];
    [self _createTableView];
    
    __weak typeof(self) weakSelf = self;
    
    // 添加传统的下拉刷新
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    [self.collectionView addLegendHeaderWithRefreshingBlock:^{
        weakSelf.pageIndex = 1;
        [weakSelf fetchData:weakSelf.pageIndex];
        [weakSelf.collectionView.header endRefreshing];
    }];
    [self.collectionView.legendHeader beginRefreshing];
    
    // 添加传统的上拉刷新
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    [self.collectionView addLegendFooterWithRefreshingBlock:^{
        weakSelf.pageIndex ++;
        [weakSelf fetchData:weakSelf.pageIndex];
        [weakSelf.collectionView.footer endRefreshing];
    }];

    if (_isSecondView) {
        [self setNavItem];
        [self showCartBtn];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCart) name:@"reloadCartNotification" object:nil];
    }
    
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

-(void)reloadCart{
    NSDictionary *cartList = [[NSUserDefaults standardUserDefaults]objectForKey:@"cartList"];
    NSString *numStr = [NSString stringWithFormat:@"%ld",(unsigned long)cartList.count];
    [_cartImage showBadgeValue:numStr PlaceForNumber:3];
}

-(void)showCartBtn{
    UIView *cartView = [[UIView alloc]initWithFrame:CGRectMake(10, kScreenHeight - 64, 56, 56)];
    cartView.backgroundColor = HGolorAlpha(0, 0, 0, 0.5);
    cartView.layer.cornerRadius = 28;
    cartView.clipsToBounds = YES;
    cartView.layer.borderColor = [[UIColor whiteColor]CGColor];
    cartView.layer.borderWidth = 1.0;
    [self.view addSubview:cartView];
    _cartImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 27, 25.5)];
    _cartImage.center = CGPointMake(cartView.width / 2.0 - 1, cartView.height / 2.0 + 2);
    
    _cartImage.image = [UIImage imageNamed:@"ShoppingCart"];
    [cartView addSubview:_cartImage];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [cartView addGestureRecognizer:tap];
    [self reloadCart];
    
}

-(void)tapAction
{
    self.navigationController.tabBarController.selectedIndex = 3;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _searchText) {
        [self searchButton];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _findTextField) {
        [self _createSearchView];
        [textField resignFirstResponder];
        [_searchText becomeFirstResponder];
    }
}

-(void)loadCategoryList{
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"model":@1};
    [service POST:goods_categoryList parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _cateArr = responseObject;
        [self loadCategory];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)loadCategory{
    if (bgView == nil)
    {
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + 39, kScreenWidth, 144)];
        bgView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
        [self.view addSubview:bgView];
        CGFloat width = kScreenWidth / 4;
        
        for (int s = 0; s <= _cateArr.count; s++)
        {
            if (s == 0) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(width * (s %4), 27 + (s / 4)*34, width, 30);
                [button setTitle:@"全部" forState:UIControlStateNormal];
                button.tag = 0;
                button.titleLabel.font = HGfont(14);
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [bgView addSubview:button];
                if ([_cid integerValue] == 0) {
                    selectedCBtn = button;
                    button.layer.borderColor = [ORANGE_LABEL_COLOR CGColor];
                    button.layer.borderWidth = 1.0;
                }
            }else{
                int i = s - 1;
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(width * (s %4), 27 + (s / 4)*34, width, 30);
                [button setTitle:_cateArr[i][@"name"] forState:UIControlStateNormal];
                button.tag = [_cateArr[i][@"cateid"] integerValue];
                button.titleLabel.font = HGfont(14);
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [bgView addSubview:button];
                if ([_cid integerValue] == [_cateArr[i][@"cateid"] integerValue]) {
                    button.layer.borderColor = [ORANGE_LABEL_COLOR CGColor];
                    button.layer.borderWidth = 1.0;
                    selectedCBtn = button;
                    self.title = _cateArr[i][@"name"];
                }
            }
        }
    }
    bgView.hidden = YES;
}


-(void)_createSearchView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    view.backgroundColor = [UIColor whiteColor];
    UIView * view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    view1.backgroundColor = navColor;
    [view addSubview:view1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(10, 26, kScreenWidth - 20 - 60, 32)];
    view2.backgroundColor = HGColor(13, 150, 129);
    view2.layer.cornerRadius = 16;
    [view1 addSubview:view2];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(12, 8, 19, 17);
    [button setImage:[UIImage imageNamed:@"sousuo_fangdajing"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(searchButton) forControlEvents:UIControlEventTouchUpInside];
    [view2 addSubview:button];
    
    _searchText = [[UITextField alloc] initWithFrame:CGRectMake(button.right + 10, 1, view2.width - 20 - button.width, 30)];
    _searchText.borderStyle = UITextBorderStyleNone;
    _searchText.textColor = [UIColor whiteColor];
    _searchText.text = self.keywords;
    _searchText.returnKeyType = UIReturnKeySearch;
    _searchText.delegate = self;
    [view2 addSubview:_searchText];
    
    //1.按钮
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 30, 26, 30, 30)];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    backButton.titleLabel.font = HGfont(14);
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:backButton];
    
    UITableView *table = (UITableView *)[self.view viewWithTag:79];
    if (!table) {
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64) style:UITableViewStyleGrouped];
        table.delegate = self;
        table.dataSource = self;
        table.tag = 79;
        [view addSubview:table];
    }
    
    [[KGModal sharedInstance]showWithContentView:view andAnimated:NO];
}
-(void)searchButton
{
    BOOL has = NO;
    for (int i = 0; i < _history.count; i++) {
        if ([_history[i] isEqualToString:_searchText.text]) {
            has = YES;
        }
    }
    if (!has && [_searchText.text length] > 0) {
        [_history addObject:_searchText.text];
    }
    [[NSUserDefaults standardUserDefaults] setObject:_history forKey:@"historySearch"];
    [[KGModal sharedInstance] hide];
    _findTextField.text = _searchText.text;
    self.keywords = _searchText.text;
    self.pageIndex = 1;
    [self fetchData:self.pageIndex];
    [_tableView.header beginRefreshing];
    [_collectionView.header beginRefreshing];
    
}

-(void)cancelAction
{
    [[KGModal sharedInstance]hide];
}


-(void)_createCollectionView
{
    NSArray *names = @[@"即将揭晓",@"人气",@"最新",@"价格",@"全部"];
    NSArray *orderArr = @[@"10",@"30",@"40",@"50"];
    CGFloat buttonWidth = kScreenWidth / 5;
    NSInteger selectLine = 1;
    if ([_orderBy integerValue] > 0) {
        for (int i = 0; i < orderArr.count; i++) {
            if ([orderArr[i] integerValue] == [_orderBy integerValue]) {
                selectLine = i;
            }
        }
    }
    for (int i = 0; i < 5; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i * buttonWidth, 64, buttonWidth, 39);
        [button setTitle:names[i] forState:UIControlStateNormal];
        button.titleLabel.font = HGfont(13);
        if (i == selectLine) {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        if (i == 3) {
            [button setImage:[UIImage imageNamed:@"paixu"] forState:UIControlStateNormal];
        }
        if (i == 4) {
            [button setImage:[UIImage imageNamed:@"xialapaixu"] forState:UIControlStateNormal];
        }
        
        button.backgroundColor = [UIColor whiteColor];
        button.tag = 130 + i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    _redView = [[UIView alloc]initWithFrame:CGRectMake(buttonWidth * selectLine, 37 + 64, buttonWidth, 2)];
    _redView.backgroundColor = navColor;
    [self.view addSubview:_redView];
    
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    if (_isSecondView) {
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 64+39, kScreenWidth, kScreenHeight - 64 - 39) collectionViewLayout:flowLayout];
    }
    else
    {
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 64+39, kScreenWidth, kScreenHeight - 64 - 49 -39) collectionViewLayout:flowLayout];
    }
    _collectionView.dataSource=self;
    _collectionView.delegate=self;
    _collectionView.showsVerticalScrollIndicator = NO;
    [_collectionView setBackgroundColor:TABLE_BG_COLOR];
    
    //注册Cell，必须要有
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"goodCell"];
    
    [self.view addSubview:_collectionView];
}

-(void)_createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+39, kScreenWidth, kScreenHeight - 64 - 39) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.hidden = YES;
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    [self.view addSubview: _tableView];
    
}

#pragma mark -- UICollectionViewDataSource

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _array.count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0f;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView registerNib:[UINib nibWithNibName:@"GoodCell"  bundle:nil] forCellWithReuseIdentifier:@"goodCell"];
    GoodCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"goodCell" forIndexPath:indexPath];

    cell.dic = _array[indexPath.item];
    [cell awakeFromNib];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((kScreenWidth - 5) / 2, (kScreenWidth - 5) / 2 + 70);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 0, 5, 0);
}

#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = _array[indexPath.item];
    //选中时调用相应页面
    GoodsDetailViewController *vc =  [[UIStoryboard storyboardWithName:@"AllGoods" bundle:nil] instantiateViewControllerWithIdentifier:@"GoodsDetailViewControllerID"];
    vc.goodsInfo = dic;
    vc.goods_id = dic[@"id"];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    if (!self.isSecondView) {
        self.hidesBottomBarWhenPushed = NO;
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//列表
- (void)fetchData:(NSInteger)page{
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"page":[NSString stringWithFormat:@"%zi",page],
                            @"index":@0,
                            @"orderBy":_orderBy,
                            @"cid":_cid,
                            @"keywords":_keywords};

    if ([_cid integerValue]== 147) {
        _tableView.hidden = NO;
    }else{
        _tableView.hidden = YES;
    }
    [service POST:goods_glist parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *list = responseObject;
        if (page == 1) {
            [_array removeAllObjects];
            if (_tableView.hidden) {
                [_collectionView.footer resetNoMoreData];
            }else{
                [_tableView.footer resetNoMoreData];
            }
        }
        
        //        有无更多数据
        if (responseObject == [NSNull null] ||[responseObject count] == 0) {
            if (_tableView.hidden) {
                [_collectionView.footer noticeNoMoreData];
            }else{
                [_tableView.footer noticeNoMoreData];
            }
        } else {
            [_array addObjectsFromArray:list];
        }
        if (_tableView.hidden) {
            [_collectionView reloadData];
        }else{
            [_tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
#pragma mark -tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 79) {
        return _history.count + 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 79)
    {
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.textLabel.font = HGfont(14);
        if (indexPath.row == 0)
        {
            cell.backgroundColor = HGColor(249, 249, 249);
            cell.textLabel.text = @"历史搜索";
            cell.textLabel.font = HGfont(13);
            cell.textLabel.textColor = GREY_LABEL_COLOR;
            return cell;
        }else{
            cell.textLabel.text = _history[_history.count - indexPath.row];
        }
        return cell;
    }
    
    
    TreasureTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"TreasureTableViewCell" owner:self options:nil]firstObject];;
    if (!cell) {
        cell = [[TreasureTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TreasureTableViewCell"];
    }
    NSDictionary *dict = _array[indexPath.section];
    cell.goodsId = dict[@"id"];
    [cell.goodImageView setImageWithURL:[CommonUtil getImageNsUrl:dict[@"thumb"]] placeholderImage:[UIImage imageNamed:@"Default diagram_Small"]];
    cell.titleLabel.text = dict[@"title"];
    cell.contentLabel.text = dict[@"title2"];
    
    NSInteger kucun = [dict[@"maxqishu"] integerValue] - [dict[@"qishu"]integerValue];
    cell.kucunLabel.text =[NSString stringWithFormat:@"库存：%ld",(long)kucun] ;
    if(dict[@"jfenInfo"]){
        cell.moneyLabel.text =[NSString stringWithFormat:@"%.f",[dict[@"jfenInfo"][@"limit_num"] floatValue]];
    }
    
    cell.allNumberLabel.text =[NSString stringWithFormat:@"%@",dict[@"zongrenshu"]] ;
    cell.numberLabel.text =[NSString stringWithFormat:@"%@",dict[@"shenyurenshu"]] ;
    
    CGFloat lineWidth = cell.allCountImageView.width * [dict[@"canyurenshu"] integerValue] / [dict[@"zongrenshu"] integerValue];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, lineWidth, cell.allCountImageView.height)];
    lineView.backgroundColor = GREEN_LABEL_COLOR;
    lineView.layer.cornerRadius = cell.allCountImageView.height / 2.0;
    lineView.clipsToBounds = YES;
    [cell.allCountImageView addSubview:lineView];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == 79) {
        _searchText.text = _history[_history.count - indexPath.row];
        [self searchButton];
        return;
    }
    NSDictionary *dic = _array[indexPath.section];
    //选中时调用相应页面
    GoodsDetailViewController *vc =  [[UIStoryboard storyboardWithName:@"AllGoods" bundle:nil] instantiateViewControllerWithIdentifier:@"GoodsDetailViewControllerID"];
    vc.goodsInfo = dic;
    vc.goods_id = dic[@"id"];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    if (!self.isSecondView) {
        self.hidesBottomBarWhenPushed = NO;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 79) {
        if (indexPath.row == 0) {
            return 30;
        }
        return 44;
    }
    return 126.0 * 2 / 750.0 * kScreenWidth;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == 79) {
        return 1;
    }
    return _array.count;
}

#pragma mark - 按钮调用的方法
-(void)buttonAction:(UIButton *)btn
{
    NSInteger index = btn.tag - 130;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _redView.frame = CGRectMake(index * (kScreenWidth / 5), 37 + 64, kScreenWidth / 5, 2);
    if (index == 0) {
        //即将揭晓
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:131];
        [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:132];
        [btn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn3 = (UIButton *)[self.view viewWithTag:133];
        [btn3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn4 = (UIButton *)[self.view viewWithTag:134];
        [btn4 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _orderBy = @"10";
        bgView.hidden = YES;
        btn4.selected = NO;
    }
    else if (index == 1) {
        //人气
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:130];
        [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:132];
        [btn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn3 = (UIButton *)[self.view viewWithTag:133];
        [btn3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn4 = (UIButton *)[self.view viewWithTag:134];
        [btn4 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _orderBy = @"30";
        bgView.hidden = YES;
        btn4.selected = NO;
    }
    
    else if (index == 2) {
        //最新
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:130];
        [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:131];
        [btn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn3 = (UIButton *)[self.view viewWithTag:133];
        [btn3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn4 = (UIButton *)[self.view viewWithTag:134];
        [btn4 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _orderBy = @"40";
        bgView.hidden = YES;
        btn4.selected = NO;
    }
    else if (index == 3) {
        //价格
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:130];
        [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:131];
        [btn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn3 = (UIButton *)[self.view viewWithTag:132];
        [btn3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn4 = (UIButton *)[self.view viewWithTag:134];
        [btn4 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _orderBy = [_orderBy integerValue] == 50 ? @"60" :@"50";
        bgView.hidden = YES;
        btn4.selected = NO;
    }
    else
    {
        //全部
        UIButton *btn1 = (UIButton *)[self.view viewWithTag:131];
        [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn2 = (UIButton *)[self.view viewWithTag:132];
        [btn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn3 = (UIButton *)[self.view viewWithTag:133];
        [btn3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        UIButton *btn4 = (UIButton *)[self.view viewWithTag:130];
        [btn4 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        _orderBy = @"50";
        if ([_cateArr count] <= 0) {
            [self loadCategoryList];
        }
        
        bgView.hidden = btn.selected;
        btn.selected = !btn.selected;
        return;
    }
    self.pageIndex = 1;
    [self fetchData:self.pageIndex];
    [_collectionView.header beginRefreshing];
    
}
-(void)selectButtonAction:(UIButton *)btn
{
    selectedCBtn.layer.borderColor = [[UIColor clearColor] CGColor];
    btn.layer.borderColor = [ORANGE_LABEL_COLOR CGColor];
    btn.layer.borderWidth = 1.0;
    selectedCBtn = btn;
    _cid = [NSString stringWithFormat:@"%li",(long)btn.tag];
    
    self.pageIndex = 1;
    [self fetchData:self.pageIndex];
    [_tableView.header beginRefreshing];
    [_collectionView.header beginRefreshing];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIButton *btn4 = (UIButton *)[self.view viewWithTag:134];
    btn4.selected = NO;
    bgView.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    bgView.hidden = YES;
    UIButton *btn4 = (UIButton *)[self.view viewWithTag:134];
    btn4.selected = NO;
}

- (IBAction)findButtonAction:(UIButton *)sender {
}
@end
