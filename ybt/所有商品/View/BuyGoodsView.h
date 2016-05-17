//
//  BuyGoodsView.h
//  一币通购
//
//  Created by 少蛟 周 on 16/4/19.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface BuyGoodsView : UIView

@property (strong,nonatomic) UITextField *numField;
@property (strong,nonatomic) UILabel *numLabel;
@property (assign,nonatomic) NSInteger count;
@property (strong,nonatomic) UIButton *selectedBtn;
@property (strong,nonatomic) NSDictionary *goodsInfo;
@property (strong,nonatomic) NSString *goodsId;
@property (strong,nonatomic) UIView *BGView;
@property (strong,nonatomic) BaseViewController *Bvc;
-(void)loadDataById:(NSString *)goodsId;

@end
