//
//  PrizeRecordTableViewCell.h
//  一币通购
//
//  Created by mac on 16/4/14.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrizeRecordTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UILabel *prizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;

@end
