//
//  ZMZScrollView.m
//  SimpleBanner
//
//  Created by 赵萌智 on 16/1/17.
//  Copyright © 2016年 赵萌智. All rights reserved.
//

#import "ZMZScrollView.h"


@interface ZMZScrollView()<UIScrollViewDelegate>
{
    //循环滚动的周期时间
    NSTimer * _moveTime;
    //记录自动滚动or手动滚动
    BOOL _isTimeUp;
}
@property (retain,nonatomic,readonly) UIImageView * leftImageView;
@property (retain,nonatomic,readonly) UIImageView * centerImageView;
@property (retain,nonatomic,readonly) UIImageView * rightImageView;


@end

//banner轮播图/s切换一次
static CGFloat const chageImageTime = 2.0;
//记录中间图片的下标,开始总是为1
static NSUInteger currentImageNum = 1;

@implementation ZMZScrollView

#define UISCREENWIDTH  self.bounds.size.width//广告的宽度
#define UISCREENHEIGHT  self.bounds.size.height//广告的高度

#define HIGHT self.bounds.origin.y //由于_pageControl是添加进父视图的,所以实际位置要参考,滚动视图的y坐标


#define UISCREENHEIGHTV  self.view.bounds.size.width


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //拖动view不可以超出范围
        self.bounces = NO;
        // 拖动时没有线条
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        //一次滚动一页和下面的方法一起使用
        self.pagingEnabled = YES;
        //当前显示区域的顶点相对于frame顶点的偏移量
        self.contentOffset = CGPointMake(UISCREENWIDTH, 0);
        // 滚动的区域的大小
        self.contentSize = CGSizeMake(UISCREENWIDTH*3, UISCREENHEIGHT);
        self.delegate = self;

        // 创建imageview并添加到scrollview上
        _leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT)];
        [self addSubview:_leftImageView];
        _centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(UISCREENWIDTH, 0, UISCREENWIDTH, UISCREENHEIGHT)];
        [self addSubview:_centerImageView];
        _rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(UISCREENWIDTH*2, 0, UISCREENWIDTH, UISCREENHEIGHT)];
        [self addSubview:_rightImageView];
        
        // 创建定时器
        _moveTime = [NSTimer scheduledTimerWithTimeInterval:chageImageTime target:self selector:@selector(addImageview) userInfo:nil repeats:YES];
        //当手动滚动时
        _isTimeUp = NO;
    }
    return self;
}
#pragma mark- imageNameArray - set方法
-(void)setImageNameArray:(NSArray *)imageArray
{
    _imageArray = imageArray;
    
    _leftImageView.image = _imageArray[0];
    _centerImageView.image = _imageArray[1];
    _rightImageView.image = _imageArray[2];
    
}
#pragma mark-添加pageControll并设置样式
-(void)setUIPageControlOfStyle:(UIPageControlOfStyle)UIPageControlOfStyle
{
    if (UIPageControlOfStyle == UIPageControlOfStyleNone) {
        return;
    }
    _pageControl = [[SMPageControl alloc]init];
    _pageControl.numberOfPages = [_imageArray count];
    [self.pageControl setPageIndicatorImage:[UIImage imageNamed:@"ic_dot_normal"]];
    [self.pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"ic_dot_checked"]];

    if (UIPageControlOfStyle == UIPageControlOfStyleLeft)
    {
        _pageControl.frame = CGRectMake(10, HIGHT+UISCREENHEIGHT - 20, 20*_pageControl.numberOfPages, 20);
    }
    else if (UIPageControlOfStyle == UIPageControlOfStyleCenter)
    {
        _pageControl.frame = CGRectMake(0, 0, 20*_pageControl.numberOfPages, 20);
        _pageControl.center = CGPointMake(UISCREENWIDTH/2.0, HIGHT+UISCREENHEIGHT +114);
    }
    else
    {
        _pageControl.frame = CGRectMake( UISCREENWIDTH - 20*_pageControl.numberOfPages, HIGHT+UISCREENHEIGHT - 20, 20*_pageControl.numberOfPages, 20);
    }
    
    _pageControl.currentPage = 0;
    _pageControl.enabled = NO;
    
    [self performSelector:@selector(addPageControl) withObject:nil afterDelay:0.1f];
    
    
    
}
#pragma mark-添加PageControl
-(void)addPageControl
{
    
    [[self superview] addSubview:_pageControl];
}

#pragma mark- 定时器触发 让图片自动滚动
-(void)addImageview
{
    // 首次 加载center图片contentoffset(UISCREENWIDTH,0) 再次应是*2  并有过度的动画
    [self setContentOffset:CGPointMake(UISCREENWIDTH * 2, 0) animated:YES];
    
    _isTimeUp = YES;
    
    // 迅速定位相应图片
    [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(scrollViewDidEndDecelerating:) userInfo:nil repeats:NO];

}
#pragma mark- 当滚动视图嘎然而止
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 图片的下标是1开始  page是从0开始  余数组的总数加载不同的图片
    
     //NSLog(@"-----%f",self.contentOffset.x);
    
    if (self.contentOffset.x == 0) {
        currentImageNum = (currentImageNum-1)%_imageArray.count;
        _pageControl.currentPage = (_pageControl.currentPage - 1)%_imageArray.count;
    }
    else if(self.contentOffset.x == UISCREENWIDTH * 2)
    {
        currentImageNum = (currentImageNum+1)%_imageArray.count;
        _pageControl.currentPage = (_pageControl.currentPage + 1)%_imageArray.count;
    }
    else
    {
        return;
    }
    
    
    _leftImageView.image = _imageArray[(currentImageNum-1)%_imageArray.count];
    
    
    _centerImageView.image = _imageArray[currentImageNum%_imageArray.count];
    
    
    _rightImageView.image = _imageArray[(currentImageNum+1)%_imageArray.count];
    
    // 归位创建的样子 要不会立马闪到下张图
    self.contentOffset = CGPointMake(UISCREENWIDTH, 0);
    
    //手动控制图片滚动应该取消那个三秒的计时器
    if (!_isTimeUp) {
        [_moveTime setFireDate:[NSDate dateWithTimeIntervalSinceNow:chageImageTime]];
        
    }
    _isTimeUp = NO;
    

}







@end

















