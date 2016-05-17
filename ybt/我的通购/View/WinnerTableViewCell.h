//
//  WinnerTableViewCell.h
//  一币通购
//
//  Created by 少蛟 周 on 16/4/8.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WinnerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImg;
@property (weak, nonatomic) IBOutlet UILabel *winnerLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
