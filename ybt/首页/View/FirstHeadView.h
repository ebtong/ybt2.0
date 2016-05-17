//
//  FirstHeadView.h
//  0元夺宝
//
//  Created by mac on 16/3/30.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstHeadView : UICollectionReusableView<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSArray *_buttonNames;
    NSArray *_buttonImgs;
    NSArray *_buttonCid;
    UIScrollView *_bannerScrollView;
    UIScrollView *_messageScrollView;
    UIPageControl *_pageControl;
    UIScrollView *_scrollerView;
    UICollectionView *_collectionView;
    NSMutableArray *_playImageNames;
    NSArray *_messageList;
    NSArray *_bannerList;
    NSInteger _count;
    NSArray *_array;
    NSInteger _timeNum;
    NSMutableArray *_bannerArr;
}

@property (strong,nonatomic)NSTimer *timer;
-(void)loadMessgeData;
-(void)loadBannerData;
-(void)loadGoodsData;
@end
