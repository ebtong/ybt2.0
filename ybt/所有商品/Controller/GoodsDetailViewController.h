//
//  GoodsDetailViewController.h
//  一币通购
//
//  Created by 少蛟 周 on 16/4/13.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsDetailViewController : UIViewController
@property (strong,nonatomic) NSDictionary *goodsInfo;
@property (strong,nonatomic) NSString *goods_id;
@property (assign,nonatomic) BOOL is_new;
-(void)createBottomView;
-(void)deleteBottomView;


@end
