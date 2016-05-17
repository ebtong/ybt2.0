//
//  ThemeButton.m
//  weibo
//
//  Created by mac on 15/10/9.
//  Copyright (c) 2015年 huiwen. All rights reserved.
//

#import "ThemeButton.h"
#import "ThemeManager.h"

@implementation ThemeButton

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChange:) name:kThemeNameDidChangeNotification object:nil];
    }
    return self;
}

-(void)setNormalImageName:(NSString *)normalImageName{
    if (![_normalImageName isEqualToString:normalImageName]) {
        _normalImageName = [normalImageName copy];
        [self loadImage];
    }
}

-(void)setBgNormalImageName:(NSString *)bgNormalImageName
{
    if (![_bgNormalImageName isEqualToString:bgNormalImageName]) {
        _bgNormalImageName = [bgNormalImageName copy];
        [self loadImage];
    }
}

-(void)themeDidChange:(NSNotification *)notification
{
    [self loadImage];
    
    
}
-(void)loadImage
{
    ThemeManager *manager = [ThemeManager shareInstance];
    if (_normalImageName != nil) {
        UIImage *normalImage = [manager getThemeImage:self.normalImageName];
        [self setImage:normalImage forState:UIControlStateNormal];
    }
    if (_bgNormalImageName != nil) {
        UIImage *bgNormalImageName = [manager getThemeImage:self.bgNormalImageName];
        [self setBackgroundImage:bgNormalImageName forState:UIControlStateNormal];
    }
}

@end
