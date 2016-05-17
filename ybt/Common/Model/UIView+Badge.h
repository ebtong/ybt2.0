//
//  UIView+Badge.h
//  WiseMall
//
//  Created by Dotton on 15/5/15.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Badge)

- (UIView *)showBadgeValue:(NSString *)strBadgeValue PlaceForNumber:(NSInteger)number;
- (void)removeBadgeValue;
@end
