//
//  WinnerTableViewCell.m
//  一币通购
//
//  Created by 少蛟 周 on 16/4/8.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "WinnerTableViewCell.h"

@implementation WinnerTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.headerImg.layer.cornerRadius = 23.0;
    self.headerImg.clipsToBounds = YES;
    self.headerImg.layer.borderWidth = 2;
    self.headerImg.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.winnerLabel.textColor = GREEN_LABEL_COLOR;
    self.codeLabel.textColor = ORANGE_LABEL_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
