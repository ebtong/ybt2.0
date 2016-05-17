//
//  TreasureTableViewCell.m
//  ybt
//
//  Created by mac on 16/4/25.
//  Copyright © 2016年 少蛟 周. All rights reserved.
//

#import "TreasureTableViewCell.h"
#import "BuyGoodsView.h"
#import "BaseViewController.h"

@implementation TreasureTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIImageView *kindImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"biaoqian"]];
    kindImageView.frame = CGRectMake(10, 0, 60.0 / 750.0 * kScreenWidth, 60.0 / 750.0 * kScreenWidth * 39.0 / 30.0);
    [self.contentView addSubview:kindImageView];
    _goodImageView.layer.borderWidth = 1;
    _goodImageView.layer.borderColor = [CELL_BG_COLOR CGColor];
    _buttonView.layer.cornerRadius = 18;
    _allCountImageView.layer.cornerRadius = 4.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (IBAction)buyGesAction:(UITapGestureRecognizer *)sender {
    
    for (UIView* next = [self superview]; next; next =
         next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                          class]])
        {
            UIWindow *window = [[UIApplication sharedApplication] keyWindow] ;
            BuyGoodsView *buyView = (BuyGoodsView *)[window viewWithTag:[self.goodsId integerValue]];
            if (!buyView) {
                BaseViewController *baseC =  (BaseViewController *)nextResponder;
                BuyGoodsView *buyView = [[BuyGoodsView alloc]initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 254)];
                buyView.tag = [self.goodsId integerValue];
                buyView.Bvc = (BaseViewController *)baseC;
                [buyView loadDataById:self.goodsId];
                [window addSubview:buyView];
                [UIView animateWithDuration:0.3 animations:^{
                    buyView.frame = CGRectMake(0, kScreenHeight - 254, kScreenWidth, 254);
                }];
            }
        }
    }
}

@end
