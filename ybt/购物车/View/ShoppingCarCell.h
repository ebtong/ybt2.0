//
//  ShoppingCarCell.h
//  一币通购
//
//  Created by mac on 16/4/12.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYAttributedLabel.h"

@interface ShoppingCarCell : UITableViewCell<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *dataNumLanle;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UILabel *allNumberLable;
@property (strong, nonatomic)TYAttributedLabel *overNumberLable;
@property (weak, nonatomic) IBOutlet UIImageView *allNumberImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *showButtonLabel;
@property (weak, nonatomic) IBOutlet UIButton *getAllGoodsButton;
@property(strong,nonatomic)NSDictionary *infoDictionary;
@property(assign,nonatomic)NSInteger count;
@property(copy,nonatomic)NSString *allCount;
@property(copy,nonatomic)NSDictionary *cartInfo;

- (IBAction)selectButtonAction:(UIButton *)sender;

- (IBAction)subtractButtonAction:(UIButton *)sender;
- (IBAction)addButtonAction:(UIButton *)sender;
- (IBAction)getAllGoodsAction:(UIButton *)sender;

- (IBAction)deleteAction:(UIButton *)sender;
@end
