//
//  ThemeManager.m
//  weibo
//
//  Created by mac on 15/10/9.
//  Copyright (c) 2015年 huiwen. All rights reserved.
//

#import "ThemeManager.h"


@implementation ThemeManager


+(ThemeManager *)shareInstance
{
    static ThemeManager *instance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}
-(instancetype)init
{
    self = [super init];
    if (self) {
        _themeName = [[NSUserDefaults standardUserDefaults] objectForKey:kThemeName];
        if (_themeName.length == 0) {
            
            _themeName = @"Cat";
        }
        NSString *configPath = [[NSBundle mainBundle] pathForResource:@"theme" ofType:@"plist"];
        self.themeConfig = [NSDictionary dictionaryWithContentsOfFile:configPath];
        
        //读取config.plist文件，把颜色配置字典读出来
        NSString *themePath = [self themePath];
        NSString *filePath = [themePath stringByAppendingPathComponent:@"config.plist"];
        _colorConfig = [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    return self;
}
//主题名字
-(void)setThemeName:(NSString *)themeName
{
    if (![_themeName isEqualToString:themeName]) {
        _themeName = [themeName copy];
        //将记录保存到持久化文件中
        [[NSUserDefaults standardUserDefaults] setObject:_themeName forKey:kThemeName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //读取config.plist文件，把颜色配置字典读出来
        NSString *themePath = [self themePath];
        NSString *filePath = [themePath stringByAppendingPathComponent:@"config.plist"];
        _colorConfig = [NSDictionary dictionaryWithContentsOfFile:filePath];
        //发通知
        [[NSNotificationCenter defaultCenter] postNotificationName:
         kThemeNameDidChangeNotification object:nil];
        
    }
}
-(UIColor *)getThemeColor:(NSString *)colorName
{
    NSDictionary *rgbDic = [_colorConfig objectForKey:colorName];
    CGFloat r = [rgbDic[@"R"] floatValue];
    CGFloat g = [rgbDic[@"G"] floatValue];
    CGFloat b = [rgbDic[@"B"] floatValue];
    
    CGFloat alpha = 1;
    if (rgbDic[@"alpha"] != nil) {
        alpha = [rgbDic[@"alpha"] floatValue];
    }
    UIColor *color = [UIColor colorWithRed:r / 255.0 green:g /255.0 blue:b /255.0 alpha:alpha];
    return color;
}
-(UIImage *)getThemeImage:(NSString *)imageName
{
    //得到主题包路径
    NSString *themePath = [self themePath];
    //拼接图片路径
    NSString *filePath = [themePath stringByAppendingPathComponent:imageName];
    //读取图片
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    return image;
    
}
//获取主题路径
-(NSString *)themePath
{
    NSString *resPath = [[NSBundle mainBundle]resourcePath];
    NSString *pathSufix = [_themeConfig objectForKey:self.themeName];
    NSString *path = [resPath stringByAppendingPathComponent:pathSufix];
    return path;
}

@end
