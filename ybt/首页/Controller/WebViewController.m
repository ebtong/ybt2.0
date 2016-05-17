//
//  WebViewController.m
//  风景网
//
//  Created by mac on 15/10/14.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "WebViewController.h"
@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIWebView *web=[[UIWebView alloc]initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height +49)];
    
    web.scalesPageToFit = YES;
    [self.view addSubview:web];

    [(UIScrollView *)[[web subviews] objectAtIndex:0] setBounces:NO];
    
    NSURL *url = [NSURL URLWithString:_urlString];
    
    //网络请求
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url];
    //使用一个网络请求来加载网页
    [web loadRequest:request];

}



@end
