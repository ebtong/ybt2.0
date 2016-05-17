//
//  GoodsDetailsTableViewController.h
//  一币通购
//
//  Created by 少蛟 周 on 16/4/12.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailViewController.h"

@interface GoodsDetailsTableViewController : UITableViewController
@property (strong,nonatomic) NSDictionary *goodsInfo;
@property (strong,nonatomic) NSString *goods_id;
@property (strong,nonatomic) GoodsDetailViewController *vc;
- (IBAction)shareAction:(UIButton *)sender;
-(void)addCart;
-(void)joinBtn;
@end
