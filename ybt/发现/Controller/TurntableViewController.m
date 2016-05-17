//
//  TurntableViewController.m
//  一币通购
//
//  Created by mac on 16/4/6.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "TurntableViewController.h"
#import "KGModal.h"
#import "SVProgressHUD.h"
#import "PrizeRecordViewController.h"
#import "LogInViewController.h"
#import "WXApi.h"

@interface TurntableViewController ()<UIAlertViewDelegate,UIScrollViewDelegate>
{
    BOOL isHidden;
    NSArray *prizesArr;
    NSInteger _timeNum;
    NSInteger angle;
    NSInteger isRuned;
    NSInteger res;
    NSArray *angleArr;
}
@property (weak, nonatomic) IBOutlet UIImageView *startImageView;
@property (nonatomic) enum WXScene currentScene;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation TurntableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _scrollView.delegate = self;
    [_scrollView setContentSize:CGSizeMake(kScreenWidth, 780)];
    isRuned = 0;
    angleArr = @[@{@"min":@225,@"max":@270},
                 @{@"min":@270,@"max":@315},
                 @{@"min":@0,@"max":@45},
                 @{@"min":@180,@"max":@225},
                 @{@"min":@90,@"max":@135},
                 @{@"min":@135,@"max":@180},
                 @{@"min":@315,@"max":@260},
                 @{@"min":@45,@"max":@90}];
    
    [self loadMsgView];
    [self setNavItem];
    [self setRightNavItem];
    self.view.frame = CGRectMake(0, 64, kScreenWidth, 730);
    self.turnLabel = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(20, 3, 174, 24)];
    self.turnLabel.backgroundColor = [UIColor clearColor];
    self.turnLabel.textAlignment = NSTextAlignmentLeft;
    [self.msgBgImageView addSubview:self.turnLabel];
}

-(void)viewWillAppear:(BOOL)animated{
    [self reloadUserData];
    [self loadPrizesData];
    self.tabBarController.tabBar.hidden = YES;
    _timeNum = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [_timer invalidate];
    _timer = nil;
    [_timer setFireDate:[NSDate distantFuture]];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

-(void)timerAction:(NSTimer *)timer
{
    if ([prizesArr count] > 0) {
        NSInteger m = _timeNum % [prizesArr count];
        CGFloat b = [prizesArr count] * 20 -_prizesScrollView.height;
        b = (int)b%20 == 0 ? b : ceil( b / 20) * 20;
        CGFloat y = b - m * 20;
        
        if (y < 0) {
            y = 0;
        }
        [_prizesScrollView setContentOffset:CGPointMake(0, y) animated:YES];
        _timeNum++;
    }
}

-(void)reloadUserData{
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    self.turnLabel = [CommonUtil getLabel:self.turnLabel str:[NSString stringWithFormat:@"您还有<c>0<c>次抽奖机会"] color:@[[UIColor whiteColor],ORANGE_LABEL_COLOR] font:@[@16]];
    if (!userInfo) {
        
        return;
    }
    
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":userInfo[@"uid"],
                            @"SessionId":userInfo[@"SessionId"]};
    [service POST:user_detail parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"userInfo"];
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
        
        NSInteger zhuanpan = [dic[@"zhuanpan"] integerValue];
        self.turnLabel = [CommonUtil getLabel:self.turnLabel str:[NSString stringWithFormat:@"您还有<c>%ld<c>次抽奖机会",(long)zhuanpan] color:@[[UIColor whiteColor],ORANGE_LABEL_COLOR] font:@[@16]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)loadPrizesData
{
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"page":@1};
    [service POST:lottery_activityLottery parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        prizesArr = responseObject;
        [self loadPrizesScroll];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)loadPrizesScroll{
    for (id view in [_prizesScrollView subviews]) {
        [view removeFromSuperview];
    }
    
    if ([prizesArr count] > 0) {
        [_prizesScrollView setContentSize:CGSizeMake(_prizesScrollView.width, [prizesArr count] * 20)];
        _prizesScrollView.userInteractionEnabled = NO;
        
        CGFloat b = [prizesArr count] * 20 -_prizesScrollView.height ;
        b = (int)b%20 == 0 ? b : ceil( b / 20) * 20;
        NSInteger m = _timeNum % [prizesArr count];
        [_prizesScrollView setContentOffset:CGPointMake(0, b - m * 20) animated:NO];
        for (int i = 0; i < [prizesArr count]; i++) {
            CGFloat y = 20 * i;
            NSDictionary *dict = prizesArr[i];
            TYAttributedLabel *nameLabel = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(10, y, self.prizesScrollView.width / 3.0 + 30, 20)];
            
            nameLabel = [CommonUtil getLabel:nameLabel str:[NSString stringWithFormat:@"恭喜<c>%@",dict[@"username"]] color:@[ORANGE_LABEL_COLOR,[UIColor whiteColor]] font:@[@12]];
            nameLabel.backgroundColor = [UIColor clearColor];
            [_prizesScrollView addSubview:nameLabel];
            
            UILabel *goodsLabel = [[UILabel alloc]initWithFrame:CGRectMake(_prizesScrollView.width / 2.0 - 20, y, self.prizesScrollView.width / 3.0 - 10, 20)];
            goodsLabel.text = dict[@"desc"];
            goodsLabel.textColor = [UIColor whiteColor];
            goodsLabel.font = HGfont(12);
            [_prizesScrollView addSubview:goodsLabel];
            
            UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(goodsLabel.right + 10, y, self.prizesScrollView.width / 3.0 - 30, 20)];
            timeLabel.text = dict[@"timeAgo"];
            timeLabel.textColor = [UIColor whiteColor];
            timeLabel.font = HGfont(12);
            [_prizesScrollView addSubview:timeLabel];
        }
    }
}

-(void)runTable
{
    [[KGModal sharedInstance]hide];
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    if (!dic) {
        LogInViewController *vc = [[LogInViewController alloc] init];
        vc.title = @"登陆";
        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:nvc animated:YES completion:nil];
        return;
    }
    if ([dic[@"zhuanpan"] integerValue] <=0 && [dic[@"score"] integerValue] < 100) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"appSetting"]) {
            NSDictionary *appSetting = [[NSUserDefaults standardUserDefaults] objectForKey:@"appSetting"];
            if ([appSetting[@"thirdHide"] integerValue] == 1) {
                [SVProgressHUD showErrorWithStatus:@"转盘次数已用完！"];
                return;
            }
        }
        NSDictionary *info = @{@"status":@0};
        [self loadData:info];
        [self performSelector:@selector(showMsg) withObject:nil afterDelay:0.1f];
        return;
    }
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":dic[@"uid"],
                            @"SessionId":dic[@"SessionId"]};
    angle = 360 * 20;
    isRuned = 0;
    res = -1;
    self.startImageView.userInteractionEnabled = NO;
    [self startAnimation];
    [service POST:lottery_award parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self loadData:responseObject];
        [self reloadUserData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)getAngle:(NSInteger) p{
    if (isRuned > 0) {
        NSDictionary *dict = angleArr[p];
        angle = 360 * 10 + arc4random() % 43 + [dict[@"min"] integerValue] + 1;
    }else{
        angle = 360 * 10;
    }
    
}

-(void)startAnimation{
    CABasicAnimation* rotationAnimation;
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: - angle * M_PI/180 ];
    rotationAnimation.duration = 2.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.delegate = self;
    rotationAnimation.fillMode=kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
     rotationAnimation.repeatCount = 1;
    [_turnTableImgView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (angle % 360 == 0) {
        if (res >= 0) {
            isRuned = 1;
            [self getAngle:res];
        }
        
        [self startAnimation];
    }else{
        [self resetImageAnimation];
        [self performSelector:@selector(showMsg) withObject:nil afterDelay:2.0f];
    }
}

-(void)showMsg{
    self.startImageView.userInteractionEnabled = YES;
    [[KGModal sharedInstance] showWithContentView:_msgView andAnimated:YES];
}

-(void)resetImageAnimation{
    NSInteger a =  - angle%360;
    angle = 0;
    CABasicAnimation* rotationAnimation;
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:a * M_PI/180 ];
    rotationAnimation.duration = 2.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.delegate = nil;
    rotationAnimation.fillMode=kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.timingFunction =
    [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
    [_turnTableImgView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
}

- (IBAction)ruleButtonAction:(UIButton *)sender {
    [self showRuleView];
}

-(void)showRuleView{
    UIView *ruleView = [self.view viewWithTag:98];
    if (!ruleView) {
        ruleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
        ruleView.backgroundColor = [UIColor whiteColor];
        ruleView.layer.cornerRadius = 4;
        ruleView.clipsToBounds = YES;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 270,30)];
        label.text = @"一币通购大转盘规则";
        label.font = HGfont(16);
        label.textColor = NORMAL_LABEL_COLOR;
        label.textAlignment = NSTextAlignmentCenter;
        [ruleView addSubview:label];
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(15, label.bottom , 270,250)];
        label1.text = @"1.用户登录一币通购，连续完成7日签到任务，即可获得一次抽奖机会。\n2.用户成功邀请好友注册并参与一币通购通购活动，可获赠一次抽奖转盘机会。\n3.实物商品我们在您确认无误之后，中奖客户可去一币通购实体商家领取奖品，虚拟商品（如话费，十足代金券，加油卡）一币通购在线充值。\n4.凡以不正当手段参与游戏的用户，一经查实，一币通购有权取消获奖资格。\n5. 关于此活动的任何疑问，可电话联系0577-85600011。\n6.该活动苹果公司(apple.inc)不是赞助商，并且苹果公司(apple.inc)也不会以任何形式参与。\n7.本游戏的最终解释权归一币通购所有。";
        label1.font = HGfont(13);
        label1.textColor = ORANGE_LABEL_COLOR;
        label1.numberOfLines = 0;
        [ruleView addSubview:label1];
    }
    [[KGModal sharedInstance]showWithContentView:ruleView andAnimated:YES];
}

-(void)loadData:(NSDictionary *)info{
    for (id view in [_msgView subviews]) {
        [view removeFromSuperview];
    }
    [self loadMsgView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callAction)];
    tap.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer *ctap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(runTable)];
    ctap.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer *stap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareAction:)];
    stap.numberOfTapsRequired = 1;
    
    if ([info[@"status"] integerValue] > 0) {
        res = [info[@"p"] integerValue];
        if ([info[@"p"] integerValue] > 0) {
            UILabel *serviceLabel = [[UILabel alloc]initWithFrame:CGRectMake(26, 236 - 40 - 28 - 14 - 5, 278 - 26 - 26, 16)];
            serviceLabel.font = [UIFont systemFontOfSize:14];
            serviceLabel.text = @"联系客服领取奖品";
            serviceLabel.textAlignment = NSTextAlignmentCenter;
            serviceLabel.textColor = [UIColor whiteColor];
            [_msgView addSubview:serviceLabel];
            
            UILabel *topLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 50, 178, 30)];
            topLabel.font = [UIFont systemFontOfSize:18];
            topLabel.text = @"恭喜你抽中了";
            topLabel.textColor = ORANGE_LABEL_COLOR;
            topLabel.textAlignment = NSTextAlignmentCenter;
            [_msgView addSubview:topLabel];
            
            UILabel *resLabel = [[UILabel alloc]initWithFrame:CGRectMake(26, topLabel.bottom + 10, 278 - 26 - 26, 23)];
            resLabel.font = [UIFont systemFontOfSize:21];
            resLabel.text = info[@"msg"];
            resLabel.textColor = [UIColor whiteColor];
            resLabel.textAlignment = NSTextAlignmentCenter;
            [_msgView addSubview:resLabel];
            
            UIImageView *mobileView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 8, 24, 24)];
            mobileView.image = [UIImage imageNamed:@"dianhua"];
            [_buttonView addSubview:mobileView];
            
            UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake(mobileView.right + 9, 0, _buttonView.width - 9 - mobileView.width, 40)];
            number.text = @"0577-85600011";
            number.textColor = [UIColor whiteColor];
            number.font = HGfont(18);
            [_buttonView addSubview:number];
            
            [_buttonView removeGestureRecognizer:ctap];
            [_buttonView removeGestureRecognizer:stap];
            [_buttonView addGestureRecognizer:tap];
            
            [self loadPrizesData];
        }else{
            UILabel *topLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 50, 178, 30)];
            topLabel.font = [UIFont systemFontOfSize:18];
            topLabel.numberOfLines = 2;
            topLabel.text = @"姿势不对吧";
            topLabel.textColor = ORANGE_LABEL_COLOR;
            topLabel.textAlignment = NSTextAlignmentCenter;
            [_msgView addSubview:topLabel];
            
            UILabel *resLabel = [[UILabel alloc]initWithFrame:CGRectMake(26, topLabel.bottom + 10, 278 - 26 - 26, 16)];
            resLabel.font = [UIFont systemFontOfSize:21];
            resLabel.numberOfLines = 2;
            resLabel.text = @"再来一次";
            resLabel.textColor = [UIColor whiteColor];
            resLabel.textAlignment = NSTextAlignmentCenter;
            [_msgView addSubview:resLabel];
            
            UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _buttonView.width, 40)];
            number.text = @"继续抽奖";
            number.textColor = [UIColor whiteColor];
            number.font = HGfont(18);
            number.textAlignment = NSTextAlignmentCenter;
            [_buttonView addSubview:number];
            
            [_buttonView removeGestureRecognizer:tap];
            [_buttonView removeGestureRecognizer:stap];
            [_buttonView addGestureRecognizer:ctap];

        }
    }else{
        UILabel *topLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 50, 178, 50)];
        topLabel.font = [UIFont systemFontOfSize:18];
        topLabel.numberOfLines = 2;
        topLabel.text = @"抱歉你的抽奖机会用完了";
        topLabel.textColor = ORANGE_LABEL_COLOR;
        topLabel.textAlignment = NSTextAlignmentCenter;
        [_msgView addSubview:topLabel];
        
        UILabel *resLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, topLabel.bottom + 10, 178, 50)];
        resLabel.font = [UIFont systemFontOfSize:18];
        resLabel.numberOfLines = 2;
        resLabel.text = @"每天分享一次，即可获取一次抽奖机会";
        resLabel.textColor = [UIColor whiteColor];
        resLabel.textAlignment = NSTextAlignmentCenter;
        [_msgView addSubview:resLabel];
        
        UILabel *number = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _buttonView.width, 40)];
        number.text = @"立即分享";
        number.textColor = [UIColor whiteColor];
        number.font = HGfont(18);
        number.textAlignment = NSTextAlignmentCenter;
        [_buttonView addSubview:number];

        [_buttonView removeGestureRecognizer:tap];
        [_buttonView removeGestureRecognizer:ctap];
        [_buttonView addGestureRecognizer:stap];
    }
}

-(void)loadMsgView{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 278, 236)];
    view.center = CGPointMake(kScreenWidth / 2, kScreenHeight / 2);
    view.layer.cornerRadius = 10;
    _msgView = view;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 278, 236)];
    imageView.image = [UIImage imageNamed:@"bg"];
    imageView.layer.cornerRadius = 10;
    [view addSubview:imageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(imageView.right - 32, imageView.top, 32, 32);
    [button setImage:[UIImage imageNamed:@"guanbi"] forState:UIControlStateNormal];
    button.layer.cornerRadius = 16;
    [button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    _buttonView = [[UIView alloc] initWithFrame:CGRectMake(26, imageView.bottom - 40 - 28, imageView.width -26 - 26, 40)];
    _buttonView.backgroundColor = navColor;
    _buttonView.layer.cornerRadius = 20;
    [view addSubview:_buttonView];
    
}

- (IBAction)turnGes:(UITapGestureRecognizer *)sender {
    [self runTable];
}

- (IBAction)inviteRecordAction:(UIButton *)sender {
    PrizeRecordViewController * vc = [[PrizeRecordViewController alloc]init];
    vc.title = @"获奖纪录";
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)callAction
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"拨打客服电话" message:@"0577-85600011" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        //联系客服
        NSString *callNum = @"0577-85600011";
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",callNum];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}


-(void)closeAction:(UIButton *)btn
{
    [[KGModal sharedInstance ]hide];
}

-(void)shareAction:(UIButton *)btn
{
    [[KGModal sharedInstance ]hide];
    [self reloadUserData];
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
