//
//  ZMZScrollView.h
//  SimpleBanner
//
//  Created by 赵萌智 on 16/1/17.
//  Copyright © 2016年 赵萌智. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"

// 定义枚举值 确定pageControl的位置
typedef NS_ENUM(NSInteger,UIPageControlOfStyle) {
    UIPageControlOfStyleNone,// 默认值
    UIPageControlOfStyleLeft,
    UIPageControlOfStyleCenter,
    UIPageControlOfStyleRight,

};


@interface ZMZScrollView : UIScrollView
// 枚举值为 NSInteger 定义属性为assign
@property(nonatomic,assign,readwrite)UIPageControlOfStyle UIPageControlOfStyle;
@property (strong,nonatomic,readonly) SMPageControl * pageControl;
@property (strong,nonatomic,readwrite) NSArray * imageArray;

@end
