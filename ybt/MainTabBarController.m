//
//  MainTabBarController.m
//  0元夺宝
//
//  Created by 老钱 on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "MainTabBarController.h"
#import "BaseNavigationController.h"
#import "TabBarButton.h"
#import "UIView+Badge.h"
#import "SVProgressHUD.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController
{
    NSArray *_selectImages;
    NSArray *_normalImages;
    NSMutableArray *_btnArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建子控制器
    [self _createSubControllers];
    //创建标签栏
//    [self _createTabBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCart:) name:@"addCartNotification" object:nil];
}
- (void) addCart: (NSNotification *)noti{
    NSDictionary *userInfo = [noti userInfo];
    NSDictionary *goodsInfo = [userInfo objectForKey:@"goodsInfo"];
    if (!goodsInfo) {
        [SVProgressHUD showErrorWithStatus:@"请等待数据加载后，再试！"];
        return;
    }
    NSMutableDictionary *cartList =[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"cartList"]];
//    NSLog(@"cartList:%ld",cartList.count);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *cart_id = [NSString stringWithFormat:@"cart_%@",goodsInfo[@"id"]];
    if (!cartList[cart_id]) {
        dict[@"info"] = goodsInfo;
        dict[@"num"] = @1;
        dict[@"selected"] = @1;
    }else{
        dict = [NSMutableDictionary dictionaryWithDictionary:cartList[cart_id]];
        NSInteger num = [dict[@"num"] integerValue] + 1;
        if (goodsInfo[@"jfenInfo"] && [goodsInfo[@"jfenInfo"][@"times"] integerValue] < num) {
            num = [goodsInfo[@"jfenInfo"][@"times"] integerValue];
        }
        
        dict = [NSMutableDictionary dictionaryWithDictionary:cartList[cart_id]];
        dict[@"num"] = [NSNumber numberWithInteger:num] ;
    }
    cartList[cart_id] = dict;
    [[NSUserDefaults standardUserDefaults]setObject:cartList forKey:@"cartList"];
    [SVProgressHUD showSuccessWithStatus:@"加入购物车成功"];
    [self loadCart];
}

-(void)loadCart{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCartNotification" object:nil];
    NSDictionary *cartList = [[NSUserDefaults standardUserDefaults]objectForKey:@"cartList"];
    NSString *numStr = [NSString stringWithFormat:@"%ld",(unsigned long)cartList.count];
//    [(TabBarButton *)_btnArray[3] showBadgeValue:numStr PlaceForNumber:3];
    if (cartList.count > 0) {
        ((UIViewController *)self.viewControllers[3]).tabBarItem.badgeValue = numStr;
    }else{
        ((UIViewController *)self.viewControllers[3]).tabBarItem.badgeValue = nil;
    }
    
}

//创建子控制器
-(void)_createSubControllers {
    NSArray *names = @[@"First",@"AllGoods",@"Discover",@"ShopCar",@"Mine"];
    NSMutableArray *navArray = [NSMutableArray array];
    for (int i = 0; i < names.count; i++)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:names[i] bundle:nil];
        BaseNavigationController *nav = [storyBoard instantiateInitialViewController];
        [navArray addObject:nav];
    }
    self.viewControllers = navArray;
    
    [self loadCart];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCart) name:@"loadCartNotification" object:nil];
}
////创建标签栏
//-(void)_createTabBar {
//    
//    _btnArray = [NSMutableArray array];
//    
//    //移除tabbarbutton
//    for (UIView *view in self.view.subviews)
//    {
//        Class cls = NSClassFromString(@"UITabBarButton");
//        if ([view isKindOfClass:cls])
//        {
//            [view removeFromSuperview];
//        }
//    }
//    //添加背景
//    UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 49)];
//    //    bgImageView.image = [UIImage imageNamed:@"tabbar.jpg"];
//    bgImageView.backgroundColor = [UIColor whiteColor];
//    [self.tabBar addSubview:bgImageView];
//    
//    //按钮
//    NSArray *buttonNames = @[@"首页",
//                             @"商品",
//                             @"发现",
//                             @"购物车",
//                             @"我的"];
//    _normalImages = @[@"shouye_nor",
//                      @"shangpin_nor",
//                      @"faxiang_nor",
//                      @"gouwuche_sel",
//                      @"my_nor"];
//    
//    _selectImages = @[@"shouye_sel",
//                      @"shangpin_sel",
//                      @"faxiang_sel",
//                      @"gouwuche_nor",
//                      @"my_sel"];
//    //按钮宽度
//    CGFloat width = kScreenWidth/_normalImages.count;
//    
//    for (int i = 0; i < _normalImages.count; i++)
//    {
//        TabBarButton *button = [[TabBarButton alloc] initWithFrame:CGRectMake(i*width, 0, width, 49) Title:buttonNames[i] ImageName:_normalImages[i]];
//        button.tag = i;
//        [button addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self.tabBar addSubview:button];
//        [_btnArray addObject:button];
//        if (i==0)
//        {
//            button.label.textColor = [UIColor blackColor];
//            button.myImgView.image = [UIImage imageNamed:_selectImages[0]];
//        }
//    }
//}
//
//-(void)selectAction:(TabBarButton *)button{
//    NSInteger index = button.tag;
//    self.selectedIndex = index;
//    for (int i = 0; i < _normalImages.count; i++)
//    {
//        if (i == index)
//        {
//            button.label.textColor = navColor;
//            button.myImgView.image = [UIImage imageNamed:_selectImages[index]];
//        }
//        else
//        {
//            TabBarButton *btn = _btnArray[i];
//            btn.label.textColor = [UIColor blackColor];
//            btn.myImgView.image = [UIImage imageNamed:_normalImages[i]];
//        }
//    }
//    
//}

@end
