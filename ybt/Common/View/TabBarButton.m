//
//  TabBarButton.m
//  0元夺宝
//
//  Created by 老钱 on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "TabBarButton.h"

@implementation TabBarButton

-(id)initWithFrame:(CGRect)frame Title:(NSString *)title ImageName:(NSString *)imageName{
    if (self == [super initWithFrame:frame]) {
        //创建图片和label
        _myImgView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-20)/2, 8, 20, 22)];
        _myImgView.image = [UIImage imageNamed:imageName];
        //设置图片拉伸模式
        _myImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_myImgView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 31, frame.size.width, 15)];
        _label.text = title;
        _label.font = [UIFont systemFontOfSize:13];
        _label.textColor = [UIColor blackColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}


@end
