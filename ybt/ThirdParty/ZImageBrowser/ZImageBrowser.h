//
//  ZImageBrowser.h
//  图片浏览器
//
//  Created by 林彦佐 on 6/3/15.
//  Copyright (c) 2015 zero. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZImageBrowser;

@protocol ZImageBrowserDelegate <NSObject>
/**
 *  启用单击手势时, 单击图片会调用此方法
 *
 *  @param broswer 图片浏览器对象
 *  @param index   单击图片的索引
 */
- (void)imageBroser:(ZImageBrowser *)broswer didTapImageAtIndex:(NSInteger)index;

@end

@interface ZImageBrowser : UIViewController
- (void)setCurrentIndex:(NSInteger)selectIndex;
@property (weak, nonatomic) id<ZImageBrowserDelegate> delegate;

/** 图片源 */
@property (strong, nonatomic) NSArray *images;
/** 是否启用单击手势, 默认不开启 */
@property (assign, nonatomic) BOOL enableTapGesture;
/** 是否启用双击放大图片手势, 默认开启 */
@property (assign, nonatomic) BOOL enableDoubleTapZoom;
/** 双击放大比例, 默认为2.0 */
@property (strong, nonatomic) NSNumber *doubleTapSclaeZoom;
/** 手势拖拽的最大放大比例, 默认为拉伸到充满屏幕 */
@property (strong, nonatomic) NSNumber *maxDragScaleZoom;

@end
