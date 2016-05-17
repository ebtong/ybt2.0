//
//  ShaiDanTableViewController.h
//  ybt
//
//  Created by 少蛟 周 on 16/4/26.
//  Copyright © 2016年 少蛟 周. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZImageBrowser.h"
#import "UploadImageView.h"

@interface ShaiDanTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) UploadImageView *uploadImageView;
@property (weak, nonatomic) IBOutlet UIView *imagesListView;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@end
