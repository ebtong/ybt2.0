//
//  ZImageScrollView.h
//  图片浏览器
//
//  Created by 林彦佐 on 6/3/15.
//  Copyright (c) 2015 zero. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZImageScrollView;

@protocol ZImageScrollViewDelegate <NSObject>
/**
 *  启用单击手势时, 点击图片调用该方法
 *
 *  @param zImageView 被点击的zImageView对象
 */
- (void)didTappedZImageView:(ZImageScrollView *)zImageView;

@end

@interface ZImageScrollView : UIScrollView

@property (weak, nonatomic) id<ZImageScrollViewDelegate> zDelegate;

/** 是否启用单击手势, 默认不开启 */
@property (assign, nonatomic) BOOL enableTapGesture;
/** 是否启用双击放大图片手势,默认开启 */
@property (assign, nonatomic) BOOL enableDoubleTapGesture;
/** 双击放大比例, 默认为2.0 */
@property (assign, nonatomic) CGFloat doubleTapScaleZoom;
/** 手势拖拽的最大放大比例, 默认为拉伸到充满屏幕 */
@property (assign, nonatomic) CGFloat maxDragScaleZoom;

/** 设置图片, 在配置完属性后设置 */
- (void)setImage:(UIImage *)image;

@end
