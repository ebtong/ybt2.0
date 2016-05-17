//
//  ZImageScrollView.m
//  图片浏览器
//
//  Created by 林彦佐 on 6/3/15.
//  Copyright (c) 2015 zero. All rights reserved.
//

#import "ZImageScrollView.h"
#import "UIView+ZExtension.h"

#define AnimationDuration 0.4

@interface ZImageScrollView () <UIScrollViewDelegate> {
    CGRect _scaleOriginRect;     //记录自己的位置
    CGSize _imgSize;     //图片的大小
    CGRect _initRect;        //缩放前大小
}

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITapGestureRecognizer *tapExitGesture;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapZoomGesture;

@end

@implementation ZImageScrollView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSelf];
    }
    return self;
}

- (void)setupSelf {
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.backgroundColor = [UIColor blackColor];
    self.delegate = self;
    self.minimumZoomScale = 1.0;
    
    // 属性默认值
    self.enableTapGesture = NO;
    self.enableDoubleTapZoom = YES;
    self.doubleTapScaleZoom = 2.0;
}

- (void)setImage:(UIImage *)image {
    if ( !image) return;
    
    self.imageView.image = image;
    _imgSize = image.size;
    
    // 默认拉伸最大情况
    float scaleX = self.frame.size.width/_imgSize.width;
    float scaleY = self.frame.size.height/_imgSize.height;
    // 判断缩放的值, 倍数小的，先到边缘
    if (scaleX > scaleY) {
        //Y方向先到边缘
        float imgViewWidth = _imgSize.width*scaleY;
        self.maximumZoomScale = self.frame.size.width/imgViewWidth;
        
        _scaleOriginRect = (CGRect){self.frame.size.width/2 - imgViewWidth/2, 0, imgViewWidth,self.frame.size.height};
    } else {
        //X先到边缘
        float imgViewHeight = _imgSize.height*scaleX;
        self.maximumZoomScale = self.frame.size.height/imgViewHeight;
        
        _scaleOriginRect = (CGRect){0,self.frame.size.height/2-imgViewHeight/2,self.frame.size.width,imgViewHeight};
    }
    
    // 设置了最大拖拽比例
    if (self.maxDragScaleZoom) {
        self.maximumZoomScale = self.maxDragScaleZoom;
    }
    
    self.imageView.frame = _scaleOriginRect;
}

#pragma mark - Gesture

- (void)updateTapGesture {
    if (self.enableTapGesture && !self.tapExitGesture) {
        _tapExitGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapExitAction:)];
        [_tapExitGesture requireGestureRecognizerToFail:self.doubleTapZoomGesture];
        [self addGestureRecognizer:_tapExitGesture];
    } else if ( !self.enableTapGesture && self.tapExitGesture) {
        [self removeGestureRecognizer:_tapExitGesture];
    }
}

- (void)tapExitAction:(UITapGestureRecognizer *)gesture {
    if ([self.zDelegate respondsToSelector:@selector(didTappedZImageView:)]) {
        [self.zDelegate didTappedZImageView:self];
    }
}

- (void)updateDoubleTapZoomGesture {
    if (self.enableDoubleTapGesture && !self.doubleTapZoomGesture) {
        _doubleTapZoomGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapZoomActioin:)];
        _doubleTapZoomGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:_doubleTapZoomGesture];
    } else if ( !self.enableDoubleTapGesture && self.doubleTapZoomGesture) {
        [self removeGestureRecognizer:_doubleTapZoomGesture];
    }
}

- (void)doubleTapZoomActioin:(UITapGestureRecognizer *)gesture {
    CGFloat scale = self.zoomScale == 1.0 ? self.doubleTapScaleZoom : 1.0;
    [UIView animateWithDuration:AnimationDuration animations:^{
        self.zoomScale = scale;
    }];
}

#pragma mark - Getter & Setter

- (UIImageView *)imageView {
    if ( !_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_imageView setBackgroundColor:[UIColor redColor]];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (void)setEnableTapGesture:(BOOL)enableTapGesture {
    _enableTapGesture = enableTapGesture;
    [self updateTapGesture];
}

- (void)setEnableDoubleTapZoom:(BOOL)enableDoubleTapZoom {
    _enableDoubleTapGesture = enableDoubleTapZoom;
    [self updateDoubleTapZoomGesture];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize contentSize = scrollView.contentSize;
    CGPoint centerPoint = CGPointMake(contentSize.width / 2, contentSize.height / 2);
    
    // 水平居中
    if (_imageView.width <= scrollView.width) {
        centerPoint.x = scrollView.width / 2;
    }
    // 垂直居中
    if (_imageView.height <= scrollView.height) {
        centerPoint.y = scrollView.height / 2;
    }
    _imageView.center = centerPoint;
}

@end
