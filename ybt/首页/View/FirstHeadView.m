//
//  FirstHeadView.m
//  0元夺宝
//
//  Created by mac on 16/3/30.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "FirstHeadView.h"
#import "BaseViewController.h"
#import "UIImageView+AFNetworking.h"
#import "GoodsDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "WebViewController.h"
#import "SVProgressHUD.h"
#import "AllGoodsViewController.h"
#import "FreshManViewController.h"

@implementation FirstHeadView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self =[super initWithFrame:frame]) {
        _buttonNames = @[@"0元夺宝",@"土豪专区",@"代金券",@"新手引导"];
        _buttonCid = @[@"147",@"137",@"144",@"2"];
        _buttonImgs = @[@"0yuandoubao",@"tuhao",@"daijinquan_1",@"xinshouyingdao"];
        
        _playImageNames = [NSMutableArray array];
        int count = (kScreenWidth - 20 - 20) / 46;
        for (int s = 0;  s < count; s++) {
            for (int i = 1; i <= 28; i++) {
                [_playImageNames addObject:[NSString stringWithFormat:@"brand_%d",i]];
            }
        }
        [self loadGoodsData];
        [self loadBannerData];
        [self loadMessgeData];
        [self _createCollectionView];
        [self _createScrollView];
        [self _createButton];
        [self _createMoreViews];
    }
    
    return self;
}

-(void)loadMessgeData
{
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = nil;

    [service POST:home_indexMsg parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _messageList = responseObject;
        [self _createView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)loadBannerData{
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = nil;

    [service POST:data_slides parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        _bannerList = responseObject[@"listItems"];
        [self _createBanner];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)_createBanner{
    _bannerScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 400.0 / 750.0 * kScreenWidth)];
    _bannerScrollView.contentSize = CGSizeMake(kScreenWidth * _bannerList.count, 400.0 / 750.0 * kScreenWidth);
    [self addSubview:_bannerScrollView];
    _bannerScrollView.showsHorizontalScrollIndicator = NO;
    _bannerScrollView.showsVerticalScrollIndicator = NO;
    _bannerScrollView.pagingEnabled = YES;
    _bannerScrollView.bounces = NO;
    _bannerScrollView.delegate = self;
    
    _pageControl = [[UIPageControl alloc]init];
    _pageControl.center = CGPointMake(kScreenWidth / 2.0, 400.0 / 750.0 * kScreenWidth - 20);
    _pageControl.numberOfPages = _bannerList.count;
    _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:_pageControl];
    
    for (int i = 0; i < _bannerList.count; i++) {
        NSDictionary *ad = _bannerList[i];
        CGFloat x = i * kScreenWidth;
        UIImageView *firstView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, kScreenWidth, 400.0 / 750.0 * kScreenWidth)];
        firstView.contentMode = UIViewContentModeScaleAspectFill;
        firstView.clipsToBounds = YES;
        [firstView setImageWithURL:[CommonUtil getImageNsUrl:ad[@"src"]] placeholderImage:[UIImage imageNamed:@"banner.jpg"]];
        [_bannerScrollView addSubview:firstView];
        UIButton *imageBtn = [[UIButton alloc]initWithFrame:firstView.frame];
        imageBtn.tag = i;
        [imageBtn addTarget:self action:@selector(imageBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        [_bannerScrollView addSubview:imageBtn];
    }
}

-(void)imageBtnPress:(UIButton *)sender{
    NSInteger i = sender.tag;
    NSDictionary *dict = _bannerList[i];
    if ([dict[@"shopid"] integerValue] == 0 ) {
        return;
    }
    
    for (UIView* next = [self superview]; next; next =
         next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                          class]])
        {
            BaseViewController *baseC =  (BaseViewController *)nextResponder;
            
            GoodsDetailViewController *vc = [[UIStoryboard storyboardWithName:@"AllGoods" bundle:nil] instantiateViewControllerWithIdentifier:@"GoodsDetailViewControllerID"];
            vc.goods_id = dict[@"shopid"];
            [baseC.navigationController pushViewController:vc animated:YES];
        }
        
    }
}

-(void)_createView
{
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 400.0 / 750.0 * kScreenWidth, 23, 25)];
    view1.backgroundColor = [UIColor whiteColor];
    [self addSubview:view1];
    
    //喇叭
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 25.0 / 2.0 - 5.5, 13, 11)];
    imageView.image = [UIImage imageNamed:@"laba"];
    [view1 addSubview:imageView];
    
    _messageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(23, 400.0 / 750.0 * kScreenWidth, kScreenWidth, 25)];
    _messageScrollView.showsHorizontalScrollIndicator = NO;
    _messageScrollView.showsVerticalScrollIndicator = NO;
    _messageScrollView.pagingEnabled = YES;
    _messageScrollView.delegate = self;
    _messageScrollView.bounces = NO;
    [self addSubview:_messageScrollView];
    if (_messageList.count <= 0) {
        _messageScrollView.contentSize = _messageScrollView.size;
        for (int i = 0; i < _messageList.count; i++) {
            UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, _bannerScrollView.bottom, kScreenWidth, 25)];
            messageView.backgroundColor = [UIColor whiteColor];
            [_messageScrollView addSubview:messageView];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,0, kScreenWidth - 33, 25)];
            NSDictionary *dic = _messageList[_count];
            label.text = dic[@"title"];
            label.font = [UIFont systemFontOfSize:12];
            label.text = @"暂无数据";
            [messageView addSubview:label];
        }
    }else{
        _messageScrollView.contentSize = CGSizeMake(_messageScrollView.width * _messageList.count, 25 * _messageList.count);
        for (int i = 0; i < _messageList.count; i++) {
            CGFloat y = i * 25;
            UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, 25)];
            messageView.backgroundColor = [UIColor whiteColor];
            [_messageScrollView addSubview:messageView];

            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,0, kScreenWidth - 33 , 25)];
            NSDictionary *dic = _messageList[i];
            label.text = dic[@"title"];
            label.font = [UIFont systemFontOfSize:12];
            [messageView addSubview:label];
        }
    }
}

-(void)_createButton
{
    CGFloat buttonWidth = kScreenWidth / 4;
    for (int i = 0; i<_buttonNames.count; i++)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * buttonWidth, 400.0 / 750.0 * kScreenWidth + 25 + 5, buttonWidth, 76)];
        view.backgroundColor = [UIColor whiteColor];
        [self addSubview:view];
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(view.bounds.size.width / 2 - 20, 10, 40, 40);
        [button setImage:[UIImage imageNamed:_buttonImgs[i]] forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 21 , view.frame.size.width, 12)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        label.text = _buttonNames[i];
        label.font = [UIFont systemFontOfSize:12];
        [view addSubview:label];
    }
}

-(void)_createCollectionView
{
    
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 400.0 / 750.0 * kScreenWidth + 25 + 5 + 76 + 5, kScreenWidth, 210 ) collectionViewLayout:flowLayout];
    _collectionView.dataSource=self;
    _collectionView.delegate=self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    
    //注册Cell，必须要有
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"firstCell"];
    
    [self addSubview:_collectionView];
}

-(void)_createScrollView
{
    //轮播试图
    UIView *playView = [[UIView alloc] initWithFrame:CGRectMake(0, _collectionView.bottom + 5, kScreenWidth, 80)];
    [playView setBackgroundColor:[UIColor colorWithRed:185 / 255.0 green:221 / 255.0 blue:217 / 255.0 alpha:1]];
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, kScreenWidth, 13)];
    lable.text = @"携手百家知名品牌 实体取货 保证售后";
    lable.font = [UIFont systemFontOfSize:13];
    lable.textAlignment = NSTextAlignmentCenter;
    [playView addSubview:lable];
#pragma mark - 创建scrollview
    _scrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 30, kScreenWidth, 46)];
    
//    [_scrollerView setBackgroundColor:[UIColor colorWithRed:185 green:221 blue:217 alpha:1]];
    
    //设置代理
    _scrollerView.delegate = self;
    
    _scrollerView.pagingEnabled = YES;
    _scrollerView.showsHorizontalScrollIndicator = NO;
    
    int count = (kScreenWidth - 20 - 20) / 46;
    
    NSInteger lineCount = ceil(_playImageNames.count * 1.00 / count );
    _scrollerView.contentSize = CGSizeMake(kScreenWidth, 46 * lineCount);
    
    for (int i = 0; i < _playImageNames.count; i++)
    {
        int j = i / count ;
        
        if (i % count == 0)
        {
            UIImageView *first = [[UIImageView alloc] initWithFrame:CGRectMake( 10 , j * 46, 45, 45)];
            first.image = [UIImage imageNamed:_playImageNames[i]];
            [_scrollerView addSubview:first];
        }

        else
        {
            CGFloat width = (kScreenWidth - 20 - 46 * count) / (count - 1);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10  + (46 + width) * (i % count), j * 46, 45, 45)];
            imageView.image = [UIImage imageNamed:_playImageNames[i]];
            [_scrollerView addSubview:imageView];
        }
    }
    
    [playView addSubview:_scrollerView];
    [self addSubview:playView];
}

-(void)_createMoreViews
{
    NSArray *imageNames = @[@"che_1",@"jiadian",@"angelababy",@"shouji",@"diannao",@"ka"];
    NSArray *titleImages = @[@"benchi_1",@"suning",@"zhoudasheng_1",@"dixintong_1",@"guoteng",@"xijinquan"];
    NSArray *labelContent = @[@"汽车1元",@"家电1元",@"珠宝1元",@"手机1元",@"数码1元",@"购物卡 充值卡"];
    for (int i = 0; i < imageNames.count; i++) {
        if (i < 2) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * (kScreenWidth -1) / 2 + i, _collectionView.bottom + 5 + 80 + 5, (kScreenWidth -1) / 2 , 94)];
            view.backgroundColor = [UIColor whiteColor];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width - 6 - 113, view.frame.size.height - 6 - 80, 113, 80)];
            imageView.image = [UIImage imageNamed:imageNames[i]];
            [view addSubview:imageView];
            
            UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 72, 20)];
            imageView1.image = [UIImage imageNamed:titleImages[i]];
            [view addSubview:imageView1];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, 28, 100, 10)];
            label.text = labelContent[i];
            label.textColor = [UIColor lightGrayColor];
            label.font = [UIFont systemFontOfSize:10];
            [view addSubview:label];
            [self addSubview:view];
            UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cidPress:)];
            view.tag = i;
            [view addGestureRecognizer:tapPress];
            
        }
        
        else
        {
            CGFloat width = (kScreenWidth - 3) / 4;
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake((i - 2) * (width + 1), _collectionView.bottom + 5 + 80 + 5 + 95, width, 94)];
            
            view.backgroundColor = [UIColor whiteColor];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width  - 66 -6, view.frame.size.height - 66, 66, 66)];
            imageView.image = [UIImage imageNamed:imageNames[i]];
            [view addSubview:imageView];
            
            UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 72, 20)];
            imageView1.image = [UIImage imageNamed:titleImages[i]];
            [view addSubview:imageView1];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, 26, 100, 10)];
            label.text = labelContent[i];
            label.textColor = [UIColor lightGrayColor];
            label.font = [UIFont systemFontOfSize:10];
            [view addSubview:label];
            
            [self addSubview:view];
            UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cidPress:)];
            view.tag = i;
            [view addGestureRecognizer:tapPress];
        }
    }
}

#pragma mark -按钮方法
-(void)cidPress:(id)sender
{
    
    NSArray *labelContent = @[@"汽车1元",@"家电1元",@"珠宝1元",@"手机1元",@"数码1元",@"购物卡 充值卡"];
    NSArray *cidArr = @[@137,@146,@138,@148,@141,@144];
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    NSInteger num = [tap view].tag;
    
    for (UIView* next = [self superview]; next; next =
         next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                          class]])
        {
            BaseViewController *baseC =  (BaseViewController *)nextResponder;
            
            AllGoodsViewController *vc = [[AllGoodsViewController alloc]init];
            vc.cid = cidArr[num];
            vc.title = labelContent[num];
            vc.isSecondView = YES;
            baseC.hidesBottomBarWhenPushed = YES;
            [baseC.navigationController pushViewController:vc animated:YES];
            baseC.hidesBottomBarWhenPushed = NO;
        }
    }
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

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = _array[indexPath.item];

    static NSString * CellIdentifier = @"firstCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.clipsToBounds = YES;
    //商品图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 146, 146)];
    NSString *urlStr = [NSString stringWithFormat:@"%@statics/uploads/%@",HOST_PATH,dic[@"thumb"]];
    NSURL *url = [NSURL URLWithString:urlStr];
    [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"morentu"]];
    
    //商品类型
    //应判断商品标签
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 30, 39)];
    if ([dic[@"cateid"] integerValue] == 147) {
        imageView1.image = [UIImage imageNamed:@"biaoqian"];
    }
    else
    {
        imageView1.image = [UIImage imageNamed:@"renqi"];
    }
    
    UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 147, 146, 63)];
    labelView.backgroundColor = HGColor(249, 249, 249);
    
    //题目
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(5, 4, 146, 13)];
    titleLable.text = dic[@"title"];
    titleLable.font = [UIFont systemFontOfSize:13];
    [labelView addSubview:titleLable];
    
    UILabel *mLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 23, labelView.width, 8)];
    mLabel.text = dic[@"title2"];
    mLabel.font = [UIFont systemFontOfSize:8];
    mLabel.textColor = [UIColor lightGrayColor];
    [labelView addSubview:mLabel];
    
    //数量比例图片
    UIImageView *allCountImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 38, 104, 6)];
    allCountImageView.backgroundColor = GREEN_BG_COLOR;
    allCountImageView.layer.cornerRadius = 3;
    [labelView addSubview:allCountImageView];
    
    CGFloat width = [dic[@"canyurenshu"] floatValue] / [dic[@"zongrenshu"]floatValue] * allCountImageView.width;
    UIImageView *countImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 38, width, 6)];
    countImageView.backgroundColor = GREEN_LABEL_COLOR;
    countImageView.layer.cornerRadius = 3;
    [labelView addSubview:countImageView];
    
    //总数
    UILabel *allCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 49, 52, 8)];
    allCountLabel.font = [UIFont systemFontOfSize:8];
    allCountLabel.text =[NSString stringWithFormat:@"总需:%@",dic[@"zongrenshu"]] ;
    allCountLabel.textColor = [UIColor lightGrayColor];
    [labelView addSubview:allCountLabel];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(109 - 52, 49, 52, 8)];
    countLabel.font = [UIFont systemFontOfSize:8];
    countLabel.text = [NSString stringWithFormat:@"剩余:%@",dic[@"shenyurenshu"]];
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.textColor = [UIColor lightGrayColor];
    [labelView addSubview:countLabel];
    
    //购物车图片
    UIButton *carButton = [UIButton buttonWithType:UIButtonTypeCustom];
    carButton.frame = CGRectMake(labelView.width - 5 - 26, labelView.height - 5 -26, 26, 26);
    [carButton setImage:[UIImage imageNamed:@"jiarugouwuche_sel"] forState:UIControlStateNormal];
    [carButton setImage:[UIImage imageNamed:@"jiarugouwuche_sel"] forState:UIControlStateHighlighted];
    [carButton addTarget:self action:@selector(addGoodBtn:) forControlEvents:UIControlEventTouchUpInside];
    carButton.tag = 140 + indexPath.item;

    [labelView addSubview:carButton];
    
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:imageView1];
    [cell.contentView addSubview:labelView];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(146, 210);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark --UICollectionViewDelegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //选中时调用相应页面
    NSDictionary *dict = _array[indexPath.item];
    
    
    for (UIView* next = [self superview]; next; next =
         next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                          class]])
        {
            BaseViewController *baseC =  (BaseViewController *)nextResponder;
            
            GoodsDetailViewController *vc = [[UIStoryboard storyboardWithName:@"AllGoods" bundle:nil] instantiateViewControllerWithIdentifier:@"GoodsDetailViewControllerID"];
            vc.goodsInfo = dict;
            vc.goods_id = dict[@"id"];
            baseC.hidesBottomBarWhenPushed = YES;
            [baseC.navigationController pushViewController:vc animated:YES];
            baseC.hidesBottomBarWhenPushed = NO;
        }
        
    }
    
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark -按钮方法
-(void)buttonAction:(UIButton *)btn
{
    for (UIView* next = [self superview]; next; next =
         next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                          class]])
        {
            BaseViewController *baseC =  (BaseViewController *)nextResponder;
            if (btn.tag == 3) {
                FreshManViewController *vc = [[FreshManViewController alloc] init];
                vc.title = @"新手宝典";
                [baseC.navigationController pushViewController:vc animated:YES];
                return;
            }
            AllGoodsViewController *vc = [[AllGoodsViewController alloc]init];
            vc.cid = _buttonCid[btn.tag];
            vc.title = _buttonNames[btn.tag];
            vc.isSecondView = YES;
            baseC.hidesBottomBarWhenPushed = YES;
            [baseC.navigationController pushViewController:vc animated:YES];
            baseC.hidesBottomBarWhenPushed = NO;
        }
    }
}

-(void)timerAction:(NSTimer *)timer
{
    CGFloat app_width = [CommonUtil getVersionWidth];
    CGFloat imageWidth = kScreenWidth + app_width;
    
    if (_messageList.count > 0) {
        NSInteger m = _messageScrollView.tag;
        if (_timeNum % 3 == 0) {
            m++;
        }
         m = m % _messageList.count;
        _messageScrollView.tag = m;
        [_messageScrollView setContentOffset:CGPointMake(0, m * 25) animated:YES];
    }
    
    if (_bannerList.count > 0) {
        NSInteger b = _bannerScrollView.tag;
        if (_timeNum % 2 == 0) {
            b++;
        }
        b = b % _bannerList.count;
        _bannerScrollView.tag = b;
        [_bannerScrollView setContentOffset:CGPointMake(b * imageWidth, 0) animated:YES];
    }
    
    if (_playImageNames.count > 0) {
        int count = (kScreenWidth - 20 - 20) / 46;
        NSInteger lineCount = ceil(_playImageNames.count * 1.00 / count);
        
        NSInteger s = _scrollerView.tag;
        if (_timeNum % 2 == 0) {
            s++;
        }

        s = s % lineCount;
        _scrollerView.tag = s;
        [_scrollerView setContentOffset:CGPointMake(0, s * 46) animated:YES];
    }
    _timeNum ++;

}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _bannerScrollView) {
        CGFloat app_width = [CommonUtil getVersionWidth];
        CGFloat imageWidth = SCREEN_WIDTH + app_width;
        NSInteger currentPage = (int)_bannerScrollView.contentOffset.x / imageWidth;
        _pageControl.currentPage = currentPage;
    }
}

// scrollview滚动的时候调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    计算页码
    //    页码 = (contentoffset.x + scrollView一半宽度)/scrollView宽度
    
    if (scrollView == _bannerScrollView) {
        CGFloat scrollviewW =  _bannerScrollView.frame.size.width;
        CGFloat x = _bannerScrollView.contentOffset.x;
        NSInteger page = (x + scrollviewW / 2) /  scrollviewW;
        _pageControl.currentPage = page;
        _bannerScrollView.tag = page;
    }else if (scrollView == _messageScrollView) {
        CGFloat scrollviewW =  _messageScrollView.frame.size.height;
        CGFloat y = _messageScrollView.contentOffset.y;
        NSInteger page = (y + scrollviewW / 2) /  scrollviewW;
        _messageScrollView.tag = page;
    } if (scrollView == _scrollerView) {
        CGFloat scrollviewW =  _scrollerView.frame.size.height;
        CGFloat y = _scrollerView.contentOffset.y;
        NSInteger page = (y + scrollviewW / 2) /  scrollviewW;
        _scrollerView.tag = page;
    }
}

-(void)loadGoodsData
{
    _timeNum = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"index":@1,@"pageSize":@6};
    [service POST:goods_glist parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _array = responseObject;
        [_collectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)addGoodBtn:(UIButton *)btn
{
    NSInteger count = btn.tag - 140;
    NSDictionary *dic = _array[count];
    if (!dic) {
        [SVProgressHUD showErrorWithStatus:@"请等待数据加载后，再试！"];
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"goodsInfo"] = dic;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addCartNotification" object:nil userInfo:userInfo];
}
@end
