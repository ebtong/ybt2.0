//
//  InviteFriendsViewController.h
//  0元夺宝
//
//  Created by mac on 16/3/31.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "BaseViewController.h"

@interface InviteFriendsViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIImageView *labelView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *bluePointView;
@property (weak, nonatomic) IBOutlet UIImageView *greenPointView;
@property (weak, nonatomic) IBOutlet UIImageView *greenView;
@property (weak, nonatomic) IBOutlet UIImageView *blueView;
@property (weak, nonatomic) IBOutlet UIImageView *greenRectView;
@property (weak, nonatomic) IBOutlet UIImageView *yellowRectView;
@property (weak, nonatomic) IBOutlet UIImageView *carView;

- (IBAction)inviteAction:(UITapGestureRecognizer *)sender;
- (IBAction)buttonAction:(UIButton *)sender;
@end
