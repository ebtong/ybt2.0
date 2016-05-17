//
//  InviteFriendsViewController.m
//  0元夺宝
//
//  Created by mac on 16/3/31.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import "ThemeButton.h"
#import "SVProgressHUD.h"
#import "InviteRecordViewController.h"
#import "WXApi.h"

@interface InviteFriendsViewController ()<UIScrollViewDelegate>
@property (nonatomic) enum WXScene currentScene;

@end

@implementation InviteFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.hidden = NO;
    
    [self setNavItem];
    [self setRightNavItem];

    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    
    CGRect tabFrame = self.tabBarController.tabBar.frame;
    tabFrame.size.height = 0;
    tabFrame.origin.y = self.view.frame.size.height ;
    self.tabBarController.tabBar.frame = tabFrame;
    
    UIImage *image = [UIImage imageNamed:@"beijintu"];
    [_labelView setImage:[image stretchableImageWithLeftCapWidth:30 topCapHeight:30]];
    _greenView.frame = CGRectMake(kScreenWidth + 50, 0, 173, 149);
    
    _greenRectView.frame = CGRectMake(kScreenWidth + 63, 200, 58, 46);
    self.tabBarController.tabBar.hidden = YES;
    [self shakeToShow];
    [self rotationToShow];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) shakeToShow
{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.8;
    animation.repeatCount = INT_MAX;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    animation.values = values;
    [_carView.layer addAnimation:animation forKey:nil];
}

-(void)rotationToShow
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_4 / 4, 0, 0, 1)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, -1)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_4 / 4, 0, 0, -1)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 1)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_4 / 4, 0, 0, 1)]];
    animation.duration  =  1;
    animation.repeatCount = INT_MAX;
    animation.values = values;
    [_blueView.layer addAnimation:animation forKey:nil];

    [_bluePointView.layer addAnimation:animation forKey:nil];
    [_greenPointView.layer addAnimation:animation forKey:nil];
    [_yellowRectView.layer addAnimation:animation forKey:nil];

}

-(void)translationToShow
{
//    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
//    
//    NSMutableArray *values = [NSMutableArray array];
////    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(kScreenWidth  , 0, 0)]];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(kScreenWidth - 80 , 0, 0)]];
//    animation.duration = 1;
//    animation.values = values;
//    [_greenRectView.layer addAnimation:animation forKey:nil];
    
    CGAffineTransform transform =
    CGAffineTransformMakeTranslation(0.0f, -100.0f);
    [UIView animateWithDuration:2 animations:^{
        _greenRectView.transform = transform;
        
    } completion:nil];


}

-(void)viewDidAppear:(BOOL)animated
{
    [self translationToShow];
}

-(void)viewWillDisappear:(BOOL)animated
{
    CGRect tabFrame = self.tabBarController.tabBar.frame;
    tabFrame.size.height = 49;
    tabFrame.origin.y = self.view.frame.size.height - 49;
    self.tabBarController.tabBar.frame = tabFrame;
    self.tabBarController.tabBar.hidden = NO;
}

- (IBAction)inviteAction:(UITapGestureRecognizer *)sender {
    
    InviteRecordViewController * vc = [[InviteRecordViewController alloc]init];
    vc.title = @"邀请纪录";
    self.hidesBottomBarWhenPushed = YES;    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)buttonAction:(UIButton *)sender
{
    UIView *view = (UIView *)[self.view viewWithTag:88];
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 108, kScreenWidth, 108)];
        view.tag = 88;
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        [self.view addSubview:view];
        NSArray *names = @[@"share_wechat_bg",@"share_friend_bg",@"share_copy_bg",@"share_sina_bg"];
        NSArray *lables = @[@"微信好友",@"朋友圈",@"复制链接",@"新浪微博"];
        CGFloat width = (kScreenWidth - 48 * 4 - 40) / 3;
        for (int i = 0; i < 4; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(20 + (48 + width) * i, 18, 48, 48);
            [button setBackgroundImage:[UIImage imageNamed:names[i]] forState:UIControlStateNormal];
            button.tag = 60 + i;
            [button addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
            
            UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth / 4 * i , 85, kScreenWidth / 4, 14)];
            lable.text = lables[i];
            lable.font = [UIFont systemFontOfSize:14];
            lable.textAlignment = NSTextAlignmentCenter;
            lable.textColor = [UIColor grayColor];
            [view addSubview:lable];
        }
    }
    else
    {
        view.hidden = NO;
    }
}

-(void)shareButtonAction:(UIButton *)btn
{
    NSInteger count = btn.tag - 60;
    if (count == 0) {
        _currentScene = WXSceneSession;
        [self sendTextContent];
    }else if (count == 1) {
        _currentScene = WXSceneTimeline;
        [self sendTextContent];
    }else if (count == 2) {
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [NSString stringWithFormat:@"%@?/mobile/user/register/&yuid=%@",HOST_PATH,userInfo[@"uid"]];
        if (pasteboard == nil) {
            [SVProgressHUD showErrorWithStatus:@"复制失败"];
        }else {
            [SVProgressHUD showSuccessWithStatus:@"复制成功"];
        }
    }else{
        [SVProgressHUD showErrorWithStatus:@"暂无此功能，待后续开发"];
    }
}

- (void) sendTextContent
{
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    if (!userInfo) {
        [SVProgressHUD showErrorWithStatus:@"请登录"];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[UIImage imageNamed:@"ybt_logo"]];
    message.title = @"一币通购";
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [NSString stringWithFormat:@"%@?/mobile/user/register/&yuid=%@",HOST_PATH,userInfo[@"uid"]];
    
    message.mediaObject = ext;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _currentScene;
    [WXApi sendReq:req];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIView *view = (UIView *)[self.view viewWithTag:88];
    view.hidden = YES;
}


@end
