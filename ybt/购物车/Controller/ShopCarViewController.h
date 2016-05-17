//
//  ShopCarViewController.h
//  0元夺宝
//
//  Created by hezhou on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "BaseViewController.h"

@interface ShopCarViewController : BaseViewController

@property(strong,nonatomic)NSMutableArray *goodsArray;
@property(strong,nonatomic)NSMutableArray *buyGoddsArray;
@property(strong,nonatomic)UITableView *tableView;

@end
