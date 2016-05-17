//
//  ShoppingCarCell.m
//  一币通购
//
//  Created by mac on 16/4/12.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "ShoppingCarCell.h"
#import "GoodsDetailViewController.h"
#import "BaseViewController.h"
#import "TYAttributedLabel.h"
#import "SVProgressHUD.h"

@implementation ShoppingCarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _getAllGoodsButton.layer.cornerRadius = 13;
    [_selectButton setImage:[UIImage imageNamed:@"xuanze_nor"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"xuanze_sel"] forState:UIControlStateSelected];
    self.numberField.delegate = self;
    _allNumberImageView.layer.cornerRadius = 3;
    UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pause:)];
    self.goodImageView.userInteractionEnabled = YES;
    [self.goodImageView addGestureRecognizer:tapPress];
    
    self.overNumberLable = [[TYAttributedLabel alloc] initWithFrame:CGRectMake(kScreenWidth - 110, self.allNumberImageView.bottom + 34 + 4, 100, 14)];
    self.overNumberLable.backgroundColor = [UIColor clearColor];
    self.overNumberLable.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.overNumberLable];
}

-(void)pause:(id)sender{
    for (UIView* next = [self superview]; next; next =
         next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                          class]])
        {
            BaseViewController *baseC =  (BaseViewController *)nextResponder; 
            GoodsDetailViewController *vc = [[UIStoryboard storyboardWithName:@"AllGoods" bundle:nil] instantiateViewControllerWithIdentifier:@"GoodsDetailViewControllerID"];
            vc.goodsInfo = self.cartInfo[@"info"];
            vc.goods_id = self.cartInfo[@"info"][@"id"];
            [baseC.navigationController pushViewController:vc animated:YES];
        }
        
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSInteger num = [textField.text integerValue];
    if (num > [self.allCount integerValue]) {
        textField.text = self.allCount;
    }
    if ([textField.text integerValue] <= 0) {
        textField.text = @"0";
    }
    [self changeData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSInteger num = [textField.text integerValue];
    if (num > [self.allCount integerValue]) {
        textField.text = self.allCount;
    }
    if ([textField.text integerValue] <= 0) {
        textField.text = @"0";
    }
    [self changeData];
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectButtonAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    [self changeData];
}

- (IBAction)subtractButtonAction:(UIButton *)sender {
    _count = [_numberField.text integerValue];
    if (_count > 1) {
        _count --;
        _numberField.text = [NSString stringWithFormat:@"%li",(long)_count];
    }
    [self changeData];
}

- (IBAction)addButtonAction:(UIButton *)sender {
    _count = [_numberField.text integerValue];
    if (_count < [_allCount integerValue]) {
        _count ++;
        _numberField.text = [NSString stringWithFormat:@"%li",(long)_count];
    }
    [self changeData];
}

-(void)changeData{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.cartInfo];
    _count = [_numberField.text integerValue];
    if (self.cartInfo[@"info"][@"jfenInfo"] && [self.cartInfo[@"info"][@"jfenInfo"][@"times"] integerValue] < _count) {
        _numberField.text = [NSString stringWithFormat:@"%@",self.cartInfo[@"info"][@"jfenInfo"][@"times"]];
        _count = [_numberField.text integerValue];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"该O元夺宝商品只能购买%ld次",(long)_count]];
    }
    dict[@"num"] = [NSString stringWithFormat:@"%li",(long)_count];
    dict[@"selected"] = self.selectButton.selected ? @1 : @0;
    NSString *cart_id = [NSString stringWithFormat:@"cart_%@",dict[@"info"][@"id"]];
    
    NSMutableDictionary *cartList = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"cartList"]];
    cartList[cart_id] = dict;
    [[NSUserDefaults standardUserDefaults]setObject:cartList forKey:@"cartList"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getCartNotification" object:nil];
}

- (IBAction)getAllGoodsAction:(UIButton *)sender {
    _numberField.text = _allCount;
    _count = [_allCount integerValue];
    [self changeData];
}

- (IBAction)deleteAction:(UIButton *)sender {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.cartInfo];
    NSString *cart_id = [NSString stringWithFormat:@"cart_%@",dict[@"info"][@"id"]];
    NSMutableDictionary *cartList = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"cartList"]];
    [cartList removeObjectForKey:cart_id];
    [[NSUserDefaults standardUserDefaults]setObject:cartList forKey:@"cartList"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getCartNotification" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadCartNotification" object:nil];
    
}

//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_numberField resignFirstResponder];
}
@end
