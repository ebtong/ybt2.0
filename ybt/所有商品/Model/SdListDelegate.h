//
//  SdListDelegate.h
//  ybt
//
//  Created by 少蛟 周 on 16/5/16.
//  Copyright © 2016年 少蛟 周. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GoodsDetailsTableViewController.h"

@interface SdListDelegate : NSObject<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) NSMutableArray *tableViewHeight;
@property (nonatomic, strong) GoodsDetailsTableViewController *vc;
- (instancetype)initWithViewController:(GoodsDetailsTableViewController *)vc;

@property (assign, nonatomic) NSInteger selectIndex;

@end
