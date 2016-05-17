//
//  MineViewController.m
//  0元夺宝
//
//  Created by hezhou on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "MineViewController.h"
#import "HeadViewCollectionReusableView.h"
#import "BaseNavigationController.h"

@interface MineViewController ()<UIScrollViewDelegate>

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setHidden:YES];
    [self.view setBackgroundColor:TABLE_BG_COLOR];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.bounces = NO;
}


-(void)_createCollectionView
{
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    CGFloat height ;
    if (self.view.width >= 375) {
        height = 152.0 / 750.0 *kScreenWidth + 455.5 + 20 + 12 + 10 + 20 + 20;
    }
    else
    {
        height = 152.0 / 750.0 *kScreenWidth + 455.5 + 20 + 12 + 10 + 20;
    }
    [flowLayout setHeaderReferenceSize:CGSizeMake(kScreenWidth, height)];
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, -20, kScreenWidth, kScreenHeight ) collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView registerClass:[HeadViewCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeadView"];
    [self.view addSubview:self.collectionView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    static NSString * CellIdentifier = @"UICollectionViewCell";
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
         HeadViewCollectionReusableView * headView = (HeadViewCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeadView" forIndexPath:indexPath];
        [headView reloadCView];
        reusableview = headView;
    }
    
    return reusableview;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    [self.navigationController.navigationBar setHidden:YES];
    [self reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [self reloadView];
}

-(void)reloadView{
    for (id view in self.view.subviews) {
        [view removeFromSuperview];
    }
    [_collectionView removeFromSuperview];
    self.collectionView = nil;
    [self _createCollectionView];
    
}

-(void)reloadData{
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]) {
        return;
    }
    
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":userInfo[@"uid"],
                            @"SessionId":userInfo[@"SessionId"]};
    [service POST:user_detail parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"userInfo"];
        [self reloadView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end
