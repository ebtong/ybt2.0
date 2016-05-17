//
//  FirstViewController.h
//  0元夺宝
//
//  Created by hezhou on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "BaseViewController.h"

@interface FirstViewController : BaseViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic)UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;
- (IBAction)leftButton:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIView *navView;

@end
