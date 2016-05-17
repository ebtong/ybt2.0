//
//  FirstViewController.m
//  0元夺宝
//
//  Created by hezhou on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "FirstViewController.h"
#import "FirstHeadView.h"
#import "KGModal.h"
#import "LogInViewController.h"
#import "AllGoodsViewController.h"

@interface FirstViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    FirstHeadView * _headView;
    UITableView *_tableView;
    NSArray *_areaArr;
    NSMutableArray *_history;
    UITextField *_searchText;
}

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setRightNavItem];
    _areaArr = @[@"鹿城区",@"龙湾区",@"瓯海区",@"乐清",@"瑞安",@"永嘉",@"洞头"];
    _navView.layer.cornerRadius = 16;
    _navView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    self.view.backgroundColor = TABLE_BG_COLOR;
    [self _createCollectionView];
    _titleText.delegate = self;
    [_titleText setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self _createTableView];
    _history = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"historySearch"]];
    
}

-(void)viewWillAppear:(BOOL)animated
{

    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];

    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init] ];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_nor"] forBarMetrics:UIBarMetricsDefault];
    [_titleText resignFirstResponder];
    [_headView loadMessgeData];
    [_headView loadGoodsData];
    [_headView loadBannerData];
    [_collectionView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [_headView.timer invalidate];
    _headView.timer = nil;
    [_headView.timer setFireDate:[NSDate distantFuture]];
    self.navigationController.navigationBar.alpha = 1;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat y = scrollView.contentOffset.y;
    if (y > 0) {
        CGFloat alp  = y > 80 ? 1 : y / 80.0;
        self.navigationController.navigationBar.alpha = alp;
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }else {
        self.navigationController.navigationBar.alpha = 1;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_nor"] forBarMetrics:UIBarMetricsDefault];
    }
}


-(void)_createCollectionView
{
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [flowLayout setHeaderReferenceSize:CGSizeMake(kScreenWidth, 599 + 400.0/750.0 * kScreenWidth)];
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, -44, kScreenWidth, kScreenHeight + 44 ) collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"firstCollectionViewCell"];
    [self.collectionView registerClass:[FirstHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"firstHeadView"];
    
    [self.view addSubview:self.collectionView];
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
    [[KGModal sharedInstance] hide];
    
    [[NSUserDefaults standardUserDefaults] setObject:_history forKey:@"historySearch"];
    AllGoodsViewController *vc = [[UIStoryboard storyboardWithName:@"AllGoods" bundle:nil] instantiateViewControllerWithIdentifier:@"AllGoodsViewControllerID"];
    vc.isSecondView = YES;
    vc.keywords = _searchText.text;
    [self.navigationController pushViewController:vc animated:YES];

}

-(void)cancelAction
{
    [[KGModal sharedInstance]hide];
}

#pragma mark -- UICollectionViewDataSource

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"firstCollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:((10 * indexPath.row) / 255.0) green:((20 * indexPath.row)/255.0) blue:((30 * indexPath.row)/255.0) alpha:1.0f];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    label.textColor = [UIColor redColor];
    label.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [cell.contentView addSubview:label];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kScreenWidth  / 2 - 10, kScreenWidth  / 2 -10);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //选中时调用相应页面
}



//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        
        _headView = (FirstHeadView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"firstHeadView" forIndexPath:indexPath];
        reusableview = _headView;
    }
    
    return reusableview;
}

//点击return 按钮 去掉
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _searchText) {
        [self searchButton];
    }else if(textField == _titleText){
        [textField resignFirstResponder];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == _titleText){
        [textField resignFirstResponder];
        [self _createSearchView];
    }
}
//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_titleText resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) _createTableView
{
    CGFloat width = _areaArr.count * 30;
    if (width > 300) {
        width = 300;
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, width) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.hidden = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tag = 78;
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 79) {
        return _history.count + 1;
    }
    return _areaArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (id subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    cell.textLabel.font = HGfont(14);
    if (tableView.tag == 78)
    {
         cell.textLabel.text = _areaArr[indexPath.row];
    }
    else
    {
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
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 79) {
        if (indexPath.row == 0) {
            return 30;
        }
        return 44;
    }
    return 30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
        return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 78) {
        
        [_leftButton setTitle:_areaArr[indexPath.row]];
        _tableView.hidden = YES;
    }
    else
    {
        _searchText.text = _history[_history.count - indexPath.row];
        [self searchButton];
    }
}


-(CGPoint)collectionView:(UICollectionView *)collectionView targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    return proposedContentOffset;
}

- (IBAction)leftButton:(UIBarButtonItem *)sender {
    _tableView.hidden = !_tableView.hidden;
}



@end
