//
//  ThemeManager.h
//  weibo
//
//  Created by mac on 15/10/9.
//  Copyright (c) 2015年 huiwen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kThemeNameDidChangeNotification @"themeNameDidChangeNotification"
#define kThemeName @"themeName"

@interface ThemeManager : NSObject
@property(nonatomic,copy)NSString *themeName;
@property(nonatomic,copy)NSDictionary *themeConfig;
@property(nonatomic,copy)NSDictionary *colorConfig;

+(ThemeManager *)shareInstance;

-(UIImage *)getThemeImage:(NSString *)imageName;
-(UIColor *)getThemeColor:(NSString *)colorName;

@end
