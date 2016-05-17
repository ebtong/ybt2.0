//
//  UIView+Badge.m
//  WiseMall
//
//  Created by Dotton on 15/5/15.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "UIView+Badge.h"

@implementation UIView (Badge)

- (UIView *)showBadgeValue:(NSString *)strBadgeValue PlaceForNumber:(NSInteger)number
{
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
    item.badgeValue = strBadgeValue;
    NSArray *array = [[NSArray alloc] initWithObjects:item, nil];
    tabBar.items = array;
    
    if ([strBadgeValue integerValue] == 0) {
        [self removeBadgeValue];
        return self;
    }
    //寻找
    for (UIView *viewTab in tabBar.subviews) {
        for (UIView *subview in viewTab.subviews) {
            NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
            if ([strClassName isEqualToString:@"UITabBarButtonBadge"] ||
                [strClassName isEqualToString:@"_UIBadgeView"]) {
                //从原视图上移除
                [subview removeFromSuperview];
                //
                [self addSubview:subview];
                
                //手机数字对应位置 6:right , 1:左上 ,4:left ,其他:右上
                if (number == 6) {
                    subview.frame = CGRectMake(self.frame.size.width-subview.frame.size.width, 0,
                                               subview.frame.size.width, subview.frame.size.height);
                }else if (number == 1) {
                    subview.frame = CGRectMake(-subview.frame.size.width/2, -subview.frame.size.height/2,
                                               subview.frame.size.width, subview.frame.size.height);
                }else if (number == 4) {
                    subview.frame = CGRectMake(-subview.frame.size.width, 0,
                                               subview.frame.size.width, subview.frame.size.height);
                }else{
                    subview.frame = CGRectMake(self.frame.size.width-subview.frame.size.width/2, -subview.frame.size.height/2,
                                               subview.frame.size.width, subview.frame.size.height);
                }
                return subview;
            }
        }
    }
    return nil;
}

- (void)removeBadgeValue
{
    for (UIView *subview in self.subviews) {
        NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
        if ([strClassName isEqualToString:@"UITabBarButtonBadge"] ||
            [strClassName isEqualToString:@"_UIBadgeView"]) {
            [subview removeFromSuperview];
            break;
        }
    }
}

@end
