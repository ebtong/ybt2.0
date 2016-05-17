//
//  TabBarButton.h
//  0元夺宝
//
//  Created by 老钱 on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarButton : UIButton
@property(nonatomic,strong)UIImageView *myImgView;
@property(nonatomic,strong)UILabel *label;

-(id)initWithFrame:(CGRect)frame
             Title:(NSString *)title
         ImageName:(NSString *)imageName;
@end
