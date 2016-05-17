//
//  IdeaViewController.h
//  一币通购
//
//  Created by mac on 16/4/13.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "BaseViewController.h"

@interface IdeaViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *upButton;
- (IBAction)upButtonAction:(UIButton *)sender;

@end
