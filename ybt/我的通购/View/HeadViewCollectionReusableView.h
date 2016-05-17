//
//  HeadViewCollectionReusableView.h
//  0元夺宝
//
//  Created by mac on 16/3/30.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeadViewCollectionReusableView : UICollectionReusableView<UIScrollViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSArray *_buttonNames;
    NSArray *_buttonImgs;
    UIScrollView *_scrollerView;
    UIPageControl *_pageC;
    
}
@property (strong,nonatomic) UILabel *jewelleryCount;
@property (strong,nonatomic) UILabel *coinCount;
@property (strong,nonatomic) UILabel *beanCount;
@property (strong,nonatomic) UILabel *nameLable;
@property (strong,nonatomic) UILabel *starLable;
@property (strong,nonatomic) UIImageView *headImageView;
-(void)reloadCView;


@end
