//
//  HtmlViewController.h
//  facade
//
//  Created by Dotton on 15/8/24.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface HtmlViewController : BaseViewController
@property (strong,nonatomic) NSString *webUrl;
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *htmlStr;

@end
