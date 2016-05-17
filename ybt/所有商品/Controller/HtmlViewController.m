//
//  HtmlViewController.m
//  facade
//
//  Created by Dotton on 15/8/24.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "HtmlViewController.h"
#import "SVProgressHUD.h"

@interface HtmlViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (assign,nonatomic) BOOL isLoadedWeb;

@end

@implementation HtmlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD showWithStatus:@"正在加载。。"];
    self.navigationItem.title = self.name;
//    self.webView.scalesPageToFit = YES;

    [self setNavItem];
//    加载实际要现实的html
    [self.webView loadHTMLString:self.htmlStr baseURL:nil];
    self.webView.delegate = self;
            // Do any additional setup after loading the view.
}

-(void)viewWillDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    
    if(self.isLoadedWeb)
    {
        return;
    }
    
    //    js获取body宽度
    NSString *bodyWidth= [webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollWidth "];
    
    int widthOfBody = [bodyWidth intValue];
    
    NSString *htmlBody  = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];

    //    获取实际要显示的html
    NSString *html = [self htmlAdjustWithPageWidth:widthOfBody
                                              html:htmlBody
                                           webView:webView];
    self.isLoadedWeb = YES;
    //    加载实际要现实的html
    [self.webView loadHTMLString:html baseURL:nil];
    
}

//获取宽度已经适配于webView的html。这里的原始html也可以通过js从webView里获取
- (NSString *)htmlAdjustWithPageWidth:(CGFloat )pageWidth
                                 html:(NSString *)html
                              webView:(UIWebView *)webView
{
    NSMutableString *str = [NSMutableString stringWithString:html];
    //计算要缩放的比例
    //    CGFloat initialScale = webView.frame.size.width/pageWidth;
    //将</head>替换为meta+head
    
    CGFloat webWidth = SCREEN_WIDTH - [CommonUtil getVersionWidth];
    
     NSString *stringForReplace = [NSString stringWithFormat:@"<meta name=\"viewport\" http-equiv=\"Content-Type\"  content=\"charset=utf-8, minimum-scale=0.1, maximum-scale=3.0, user-scalable=yes\"><style>body{margin:0 auto;padding:0;width:%.2f;white-space:normal;}body img{width:100%%;} p{margin-left:0px;padding-left:0px;text-align:justify;text-align-last:justify;}</style></head>",webWidth];
    
    NSRange range =  NSMakeRange(0, str.length);
    //替换
    [str replaceOccurrencesOfString:@"</head>" withString:stringForReplace options:NSLiteralSearch range:range];
    return str;
}

@end
