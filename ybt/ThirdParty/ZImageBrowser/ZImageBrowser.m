//
//  ZImageBrowser.m
//  图片浏览器
//
//  Created by 林彦佐 on 6/3/15.
//  Copyright (c) 2015 zero. All rights reserved.
//

#import "ZImageBrowser.h"
#import "ZImageScrollView.h"
#import "UIView+ZExtension.h"
#import "Global.h"

@interface ZImageBrowser () <UIScrollViewDelegate, ZImageScrollViewDelegate> {
    NSInteger _currentIndex;
}

@property (strong, nonatomic) UIScrollView *zScrollView;
@property (strong, nonatomic) NSMutableArray *zImageArr;

@end

@implementation ZImageBrowser

- (instancetype)init {
    if (self = [super init]) {
        [self setupSelf];
    }
    return self;
}

- (instancetype)initWithImages:(NSArray *)images {
    if ([self init]) {
        self.images = images;
    }
    return self;
}

- (void)setupSelf {
    _currentIndex = 0;
    self.enableDoubleTapZoom = YES;
}

- (void)setCurrentIndex:(NSInteger)selectIndex{
    _currentIndex = selectIndex;
    [self.zScrollView setContentOffset:CGPointMake(_currentIndex * SCREEN_WIDTH, 0) animated:NO];
}

// 更新图片
- (void)refreshSubImageView {
    // 清除原先的所有zImageView
    for (UIView *tmpView in _zScrollView.subviews) {
        [tmpView removeFromSuperview];
    }
    [self.zImageArr removeAllObjects];
    
    // 添加新的zImageView
    self.zScrollView.contentSize = CGSizeMake(self.images.count * self.view.width, self.view.height);
    for (int i = 0; i < self.images.count; i++) {
        CGFloat x = self.view.frame.size.width * i;
        ZImageScrollView *zImageView = [self createImageViewWithFrame:CGRectMake(x, 0, self.view.width, self.view.height) Tag:i];
        [zImageView setImage:self.images[i]];
        [self.zScrollView addSubview:zImageView];
        [self.zImageArr addObject:zImageView];
    }
}

- (ZImageScrollView *)createImageViewWithFrame:(CGRect)rect Tag:(NSInteger)tag {
    ZImageScrollView *zImageView = [[ZImageScrollView alloc] initWithFrame:rect];
    zImageView.tag = tag;
    
    if (self.maxDragScaleZoom)
        zImageView.maxDragScaleZoom = _maxDragScaleZoom.floatValue;
    if (self.enableTapGesture) {
        zImageView.enableTapGesture = _enableTapGesture;
        zImageView.zDelegate = self;
    }
    if (self.enableDoubleTapZoom)
        zImageView.enableDoubleTapGesture = _enableDoubleTapZoom;
    if (self.doubleTapSclaeZoom && self.enableDoubleTapZoom)
        zImageView.doubleTapScaleZoom = _doubleTapSclaeZoom.floatValue;
    
    return zImageView;
}

#pragma mark - Getter & Setter

- (UIScrollView *)zScrollView {
    if ( !_zScrollView) {
        _zScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _zScrollView.pagingEnabled = YES;
        _zScrollView.delegate = self;
        [self.view addSubview:_zScrollView];
    }
    return _zScrollView;
}

- (NSMutableArray *)zImageArr {
    if ( !_zImageArr) {
        _zImageArr = [NSMutableArray array];
    }
    return _zImageArr;
}

- (void)setImages:(NSArray *)images {
    _images = images;
    // 设置图片源时更新子视图
    [self refreshSubImageView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / self.view.width;
    if (_currentIndex != index) {
        ZImageScrollView *zImageView = self.zImageArr[_currentIndex];
        zImageView.zoomScale = 1.0;
        
        _currentIndex = index;
    }
}

#pragma mark - ZImageScrollViewDelegate

- (void)didTappedZImageView:(ZImageScrollView *)zImageView {
    if ([self.delegate respondsToSelector:@selector(imageBroser:didTapImageAtIndex:)]) {
        [self.delegate imageBroser:self didTapImageAtIndex:zImageView.tag];
    }
}

@end
