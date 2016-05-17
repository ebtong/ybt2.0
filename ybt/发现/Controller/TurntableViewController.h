//
//  TurntableViewController.h
//  一币通购
//
//  Created by mac on 16/4/6.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "BaseViewController.h"
#import "TYAttributedLabel.h"

@interface TurntableViewController : BaseViewController
@property (strong, nonatomic) TYAttributedLabel *turnLabel;
@property (weak, nonatomic) IBOutlet UIImageView *turnTableImgView;
@property (weak, nonatomic) IBOutlet UIScrollView *prizesScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *msgBgImageView;

- (IBAction)ruleButtonAction:(UIButton *)sender;
- (IBAction)turnGes:(UITapGestureRecognizer *)sender;
- (IBAction)inviteRecordAction:(UIButton *)sender;

@property (strong, nonatomic) UIView *msgView;
@property (strong, nonatomic) UIView *resView;
@property (strong, nonatomic) UIView *buttonView;
@property (strong,nonatomic) NSTimer *timer;

@end
