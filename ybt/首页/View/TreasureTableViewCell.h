//
//  TreasureTableViewCell.h
//  ybt
//
//  Created by mac on 16/4/25.
//  Copyright © 2016年 少蛟 周. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TreasureTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *kucunLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *allCountImageView;
@property (weak, nonatomic) IBOutlet UILabel *allNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) NSString *goodsId;
- (IBAction)buyGesAction:(UITapGestureRecognizer *)sender;

@end
