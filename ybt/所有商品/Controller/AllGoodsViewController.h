//
//  AllGoodsViewController.h
//  0元夺宝
//
//  Created by hezhou on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "BaseViewController.h"

@interface AllGoodsViewController : BaseViewController

@property(strong,nonatomic)UICollectionView *collectionView;
@property(copy,nonatomic)NSString *orderBy;
@property(copy,nonatomic)NSString *page;
@property(copy,nonatomic)NSString *cid;
@property(copy,nonatomic)NSString *keywords;
@property (weak, nonatomic) IBOutlet UIView *findView;
@property (weak, nonatomic) IBOutlet UITextField *findTextField;
@property(assign,nonatomic) BOOL isSecondView;
@property(strong,nonatomic)UITableView *tableView;

- (IBAction)findButtonAction:(UIButton *)sender;

@end
