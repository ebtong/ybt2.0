//
//  GoodsDetailViewController.m
//  一币通购
//
//  Created by 少蛟 周 on 16/4/13.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "GoodsDetailViewController.h"
#import "GoodsDetailsTableViewController.h"
#import "ThemeButton.h"
#import "UIView+Badge.h"
#import "BuyGoodsView.h"
#import "KGModal.h"
#import "SVProgressHUD.h"

@interface GoodsDetailViewController ()
@property (strong,nonatomic) UIView *bottomView;
@property (strong,nonatomic) UIImageView *cartImage;
@property (strong,nonatomic) GoodsDetailsTableViewController *child;


@end

@implementation GoodsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.is_new = YES;
    self.hidesBottomBarWhenPushed = YES;
    _child = [[UIStoryboard storyboardWithName:@"AllGoods" bundle:nil] instantiateViewControllerWithIdentifier:@"GoodsDetailsTableViewControllerID"];
    _child.goodsInfo = self.goodsInfo;
    _child.goods_id = self.goods_id;
    _child.vc = self;
    [self addChildViewController:_child];
    [self.view addSubview:[_child view]];
    CGRect frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 49);
    [[_child view] setFrame:frame];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCart) name:@"reloadCartNotification" object:nil];
}

-(void)reloadCart{
    NSDictionary *cartList = [[NSUserDefaults standardUserDefaults]objectForKey:@"cartList"];
    NSString *numStr = [NSString stringWithFormat:@"%ld",(unsigned long)cartList.count];
    [_cartImage showBadgeValue:numStr PlaceForNumber:3];
}


-(void)viewWillAppear:(BOOL)animated{
//    self.navigationController.navigationBarHidden = YES;
    UIImage *image = [[UIImage alloc]init];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self setNavItem];
    [self setRightNavItem];
    [self createBottomView];
}

-(void)viewDidAppear:(BOOL)animated{
    UIImage *image = [[UIImage alloc]init];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

-(void)deleteBottomView{
    [_bottomView removeFromSuperview];
    _bottomView = nil;
}

-(void)createBottomView{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [self deleteBottomView];
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight - 49, kScreenWidth, 49)];
    _bottomView.layer.borderWidth = 1.0;
    _bottomView.tag = 9999;
    _bottomView.backgroundColor = [UIColor whiteColor];
    _bottomView.layer.borderColor = [TABLE_BG_COLOR CGColor];
    
    [window addSubview:_bottomView];
    if (!self.is_new) {
        CGFloat btnWidth = kScreenWidth * 3 / 5;
        UILabel *msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, btnWidth, 49)];
        msgLabel.backgroundColor = [UIColor blackColor];
        msgLabel.textColor = [UIColor whiteColor];
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.text = @"新一期正在火热进行中...";
        msgLabel.font = HGfont(14);
        msgLabel.alpha = 0.7;
        [_bottomView addSubview:msgLabel];
        
        UIButton *joinBtn = [[UIButton alloc]initWithFrame:CGRectMake(msgLabel.right, 0, _bottomView.width - btnWidth, 49)];
        
        [joinBtn setTitle:@"立即参与" forState:UIControlStateNormal];
        joinBtn.backgroundColor = RED_BTN_COLOR;
        [joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        joinBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [joinBtn addTarget:self action:@selector(joinBtnPress) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:joinBtn];
        return;
    }
    
    
    
    UIButton *cartBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 91, 49)];
    [_bottomView addSubview:cartBtn];
    
    _cartImage = [[UIImageView alloc]initWithFrame:CGRectMake(cartBtn.width/2.0 - 10, 10, 20, 20)];
    [_cartImage setImage:[UIImage imageNamed:@"cart_nor"]];
    _cartImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_cartImage addGestureRecognizer:tap];
    [_bottomView addSubview:_cartImage];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCartNotification" object:nil];
    
    UILabel *cartLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _cartImage.bottom + 2, 91, 12)];
    cartLabel.textAlignment = NSTextAlignmentCenter;
    cartLabel.text = @"我的购物车";
    cartLabel.textColor = NORMAL_LABEL_COLOR;
    cartLabel.font = [UIFont systemFontOfSize:10];
    [_bottomView addSubview:cartLabel];
    
    
    CGFloat btnWidth = (kScreenWidth - cartBtn.width)/2.0;
    UIButton *addCartBtn = [[UIButton alloc]initWithFrame:CGRectMake(cartBtn.right, 0, btnWidth, 49)];
    [addCartBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
    addCartBtn.backgroundColor = ORANGE_LABEL_COLOR;
    [addCartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addCartBtn.titleLabel.font = [UIFont systemFontOfSize:16];
//    [addCartBtn removeTarget:self action:@selector(addBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [addCartBtn addTarget:self action:@selector(addBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:addCartBtn];
    
    UIButton *buyBtn = [[UIButton alloc]initWithFrame:CGRectMake(addCartBtn.right, 0, btnWidth, 49)];
    [buyBtn setTitle:@"立即购买" forState:UIControlStateNormal];
    buyBtn.backgroundColor = RED_BTN_COLOR;
    [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buyBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [buyBtn addTarget:self action:@selector(buyBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:buyBtn];
}

-(void)buyBtnPress:(UIButton *)sender{
    BuyGoodsView *buyView = [[BuyGoodsView alloc]initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 254)];
    buyView.Bvc = (BaseViewController *)self;
    [buyView loadDataById:self.goods_id];
    [[[UIApplication sharedApplication] keyWindow] addSubview:buyView];
    [UIView animateWithDuration:0.3 animations:^{
        buyView.frame = CGRectMake(0, kScreenHeight - 254, kScreenWidth, 254);
    }];
}

-(void)joinBtnPress{
    [_child joinBtn];
}

-(void)addBtnPress:(UIButton *)sender{
    [_child addCart];
}

-(void)viewWillDisappear:(BOOL)animated{
//    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

-(void)setNavItem
{
    //1.返回按钮
    ThemeButton *backButton = [[ThemeButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    backButton.normalImageName = @"goods_fanhui";
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bakeItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:bakeItem];
    
}

-(void)backAction
{
    [self deleteBottomView];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setRightNavItem
{
//    //1.返回按钮
//    ThemeButton *messageButton = [[ThemeButton alloc] initWithFrame:CGRectMake(0, 0, 26, 22)];
//    messageButton.normalImageName = @"goods_xiaoxi";
//    [messageButton addTarget:self action:@selector(messageAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *messageItem = [[UIBarButtonItem alloc] initWithCustomView:messageButton];
//    [self.navigationItem setRightBarButtonItem:messageItem];
    
}

-(void)messageAction{
    [SVProgressHUD showErrorWithStatus:@"暂无此功能，待后续开发"];
}

-(void)tapAction
{
    [_bottomView removeFromSuperview];
    _bottomView = nil;
    self.navigationController.tabBarController.selectedIndex = 3;
    [self.navigationController popToRootViewControllerAnimated:YES];
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
