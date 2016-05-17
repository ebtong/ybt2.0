//
//  MineViewController.h
//  0元夺宝
//
//  Created by hezhou on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "BaseViewController.h"

@interface MineViewController : BaseViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic)UICollectionView *collectionView;

@end
