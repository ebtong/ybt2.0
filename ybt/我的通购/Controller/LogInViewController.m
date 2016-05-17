//
//  LogInViewController.m
//  0元夺宝
//
//  Created by mac on 16/3/27.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "LogInViewController.h"
#import "ForgetPasswordViewController.h"
#import "RegisterViewController.h"
#import "WXApi.h"
#import "BindMobileViewController.h"
#import "JPUSHService.h"
#import "SVProgressHUD.h"

@interface LogInViewController ()<UITextFieldDelegate,WXApiDelegate>
{
    UITextField *_accountTF;
    UITextField *_passwordF;
}
@property (strong,nonatomic) NSDictionary *userInfo;

@end

@implementation LogInViewController
-(instancetype)init{
    if (self = [super init]) {
        //初始的时候设置隐藏tabbar
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

-(void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.title = @"登录";
//    [self.navigationController.navigationBar setHidden:NO];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //1.返回按钮
    [self setNavItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxLogined:) name:@"WXLoginedNotification" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [self _createView];
}

-(void)_createView{
    for (id view in self.view.subviews) {
        [view removeFromSuperview];
    }
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    CGFloat scrollViewHeight = kScreenHeight ;
    if (kScreenHeight < 568) {
        scrollViewHeight = 568;
    }
    scrollViewHeight = scrollViewHeight - 64;
    [scrollView setContentSize:CGSizeMake(kScreenWidth, scrollViewHeight)];
    [self.view addSubview:scrollView];
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 32, kScreenWidth - 40, 44)];
    view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 5;
    view.layer.borderColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;
    [scrollView addSubview:view];
    
    //账号
    UIImageView *leftI = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_nor_l.png"]];
    leftI.frame = CGRectMake(15, 13, 16 ,18);
    leftI.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:leftI];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(leftI.right + 15, 6, 1, 30)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:lineView];
    
    _accountTF = [[UITextField alloc] initWithFrame:CGRectMake(lineView.right + 18, 0, view.width - lineView.right - 18, 44)];
    [view addSubview:_accountTF];
    _accountTF.placeholder = @"请输入您的手机号码";
    _accountTF.keyboardType = UIKeyboardTypeNumberPad;
    _accountTF.font = [UIFont systemFontOfSize:14];
    
    //密码
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(20, view.bottom + 20, kScreenWidth - 40, 44)];
    view1.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    view1.layer.borderWidth = 1;
    view1.layer.cornerRadius = 5;
    view1.layer.borderColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;
    [scrollView addSubview:view1];
    
    UIImageView *passwordI = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"suo.png"]];
    passwordI.frame = CGRectMake(15, 13, 16 ,18);
    passwordI.contentMode = UIViewContentModeScaleAspectFit;
    [view1 addSubview:passwordI];
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(passwordI.right + 15, 6, 1, 30)];
    lineView1.backgroundColor = [UIColor lightGrayColor];
    [view1 addSubview:lineView1];
    
    _passwordF = [[UITextField alloc] initWithFrame:CGRectMake(lineView.right + 18, 0, view.width - lineView.right - 18, 44)];
    [view1 addSubview:_passwordF];
    _passwordF.placeholder = @"密码";
    _passwordF.font = [UIFont systemFontOfSize:14];
    _passwordF.keyboardType = UIKeyboardTypeDefault;
    _passwordF.secureTextEntry = YES;
    
    //忘记密码?
    UIButton *forgetB = [[UIButton alloc] initWithFrame:CGRectMake(view1.right - 100, view1.top, 100, 44)];
    [forgetB setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [forgetB setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    forgetB.titleLabel.font = [UIFont systemFontOfSize:14];
    forgetB.titleLabel.textAlignment = NSTextAlignmentCenter;
    [forgetB addTarget:self action:@selector(forgetAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:forgetB];
    
    //登录
    UIButton *logInBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, view1.bottom + 50, kScreenWidth - 40, 40)];
    logInBtn.backgroundColor = ORANGE_LABEL_COLOR;
    logInBtn.layer.cornerRadius = logInBtn.height/2;
    [scrollView addSubview:logInBtn];
    [logInBtn setTitle:@"登录" forState:UIControlStateNormal];
    [logInBtn addTarget:self action:@selector(logInAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //新用户注册
    UIButton *newB = [[UIButton alloc] initWithFrame:CGRectMake(20, logInBtn.bottom + 30, kScreenWidth - 40, 40)];
    [newB setTitle:@"新用户注册" forState:UIControlStateNormal];
    newB.layer.borderColor = [ORANGE_LABEL_COLOR CGColor];
    newB.layer.borderWidth = 1;
    [newB setTitleColor:ORANGE_LABEL_COLOR forState:UIControlStateNormal];
    newB.layer.cornerRadius = logInBtn.height/2;
    [newB addTarget:self action:@selector(newAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:newB];
    
    UILabel *bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, scrollViewHeight - 14 - 15, kScreenWidth - 20, 14)];
    bottomLabel.text = @"浙ICP 备 16003608号-1 壹币通公司版权所有";
    bottomLabel.textColor = GREY_LABEL_COLOR;
    bottomLabel.font = HGfont(12);
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:bottomLabel];
    
    UILabel *coinLabel = [[UILabel alloc]init];
    coinLabel.bounds = CGRectMake(0, 0, 20, 14);
    coinLabel.center = CGPointMake(bottomLabel.center.x, bottomLabel.top - 10 - 7);
    coinLabel.text = @"|";
    coinLabel.textColor = GREY_LABEL_COLOR;
    coinLabel.font = HGfont(13);
    coinLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:coinLabel];
    
    UIButton *sBtn = [[UIButton alloc]initWithFrame:CGRectMake(coinLabel.left - 60, coinLabel.top, 60, 14)];
    [sBtn setTitle:@"服务协议" forState:UIControlStateNormal];
    [sBtn setTitleColor:BLUE_LABEL_COLOR forState:UIControlStateNormal];
    sBtn.titleLabel.font = HGfont(13);
    [scrollView addSubview:sBtn];
    
    UIButton *yBtn = [[UIButton alloc]initWithFrame:CGRectMake(coinLabel.right, coinLabel.top, 60, 14)];
    [yBtn setTitle:@"隐私政策" forState:UIControlStateNormal];
    [yBtn setTitleColor:BLUE_LABEL_COLOR forState:UIControlStateNormal];
    yBtn.titleLabel.font = HGfont(13);
    [scrollView addSubview:yBtn];
    
    
    //QQ登录
    UIButton *QQBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2 + 25, yBtn.top - 20 - 49, 49, 49)];
    [QQBtn setImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
    [QQBtn addTarget:self action:@selector(qqLogIn:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:QQBtn];
    
    //微信登录
    UIButton *WeiChatBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2 - 25 - 49, yBtn.top - 20 - 49, 49, 49)];
    [WeiChatBtn setImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
    [WeiChatBtn addTarget:self action:@selector(weiChatLogIn:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:WeiChatBtn];
    
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    UIFont *fnt1 = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    label1.text = @"一键登录";
    label1.font = fnt1;
    label1.textColor = HGColor(153, 153, 153);
    CGSize labelSize1 = [label1.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt1,NSFontAttributeName, nil]];
    label1.frame = CGRectMake(kScreenWidth / 2 - labelSize1.width / 2, WeiChatBtn.top - 46, labelSize1.width, 14);
    [scrollView addSubview:label1];
    
    //中间分隔线
    UIView *apartL = [[UIView alloc] initWithFrame:CGRectMake(20, label1.center.y, kScreenWidth/2 - labelSize1.width / 2 - 26 - 20 ,1)];
    apartL.backgroundColor = HGColor(245, 245, 245);
    [scrollView addSubview:apartL];
    
    UIView *apartL1 = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth/2 + labelSize1.width / 2 + 26, label1.center.y, kScreenWidth/2 - labelSize1.width / 2 - 26 - 20,1 )];
    apartL1.backgroundColor = HGColor(245, 245, 245);
    [scrollView addSubview:apartL1];

    
    if (![WXApi isWXAppInstalled]) {
        QQBtn.hidden = YES;
        WeiChatBtn.hidden = YES;
        label1.hidden = YES;
        apartL.hidden = YES;
        apartL1.hidden = YES;
    }else{
        QQBtn.hidden = NO;
        WeiChatBtn.hidden = NO;
        label1.hidden = NO;
        apartL.hidden = NO;
        apartL1.hidden = NO;
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"appSetting"]) {
        NSDictionary *appSetting = [[NSUserDefaults standardUserDefaults] objectForKey:@"appSetting"];
        if ([appSetting[@"thirdHide"] integerValue] == 1) {
            QQBtn.hidden = YES;
            WeiChatBtn.hidden = YES;
            label1.hidden = YES;
            apartL.hidden = YES;
            apartL1.hidden = YES;
        }else{
            QQBtn.hidden = NO;
            WeiChatBtn.hidden = NO;
            label1.hidden = NO;
            apartL.hidden = NO;
            apartL1.hidden = NO;
        }
        
    }
    
}

//点击return 按钮 去掉
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_accountTF resignFirstResponder];
    [_passwordF resignFirstResponder];
}

-(void)logInAction:(UIButton *)button{
    if (_passwordF.text && _accountTF.text)
    {
        
        HttpService *service = [HttpService getInstance];
        NSDictionary *param = @{@"username":_accountTF.text,@"password":_passwordF.text};
        [service POST:user_login parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:_accountTF.text forKey:@"telNum"];
            [userDefaults setObject:_passwordF.text forKey:@"password"];
            
            [userDefaults setObject:responseObject forKey:@"userInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [JPUSHService setAlias:responseObject[@"uid"] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
            
            if (responseObject[@"username"]) {
                [userDefaults setObject:responseObject[@"username"] forKey:@"userName"];
            }
            NSNotification *notice = [NSNotification notificationWithName:@"firstLogin" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter]postNotification:notice];
            
            NSMutableDictionary *appSetting = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"appSetting"]];
            if ([responseObject[@"uid"] integerValue] == 8675) {
                appSetting[@"thirdHide"] = @1;
                [[NSUserDefaults standardUserDefaults]setObject:appSetting forKey:@"appSetting"];
            }

            [self dismissViewControllerAnimated:YES completion:nil];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }

}

-(void)forgetAction:(UIButton *)button{
    ForgetPasswordViewController * vc = [[ForgetPasswordViewController alloc] init];
    vc.title = @"忘记密码";
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)newAction:(UIButton *)button{
    RegisterViewController *vc = [[RegisterViewController alloc] init];
    vc.title = @"注册";
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)qqLogIn:(UIButton *)button{
    [SVProgressHUD showErrorWithStatus:@"暂无此功能，等待后续开发！"];
}

-(void)weiChatLogIn:(UIButton *)button{
    [self sendAuthRequest];
}

-(void)sendAuthRequest  {
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"0744" ;
    [WXApi sendReq:req];
}

- (void)wxLogined: (NSNotification *)noti{
    /*
     {
     city = Haidian;
     country = CN;
     headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
     language = "zh_CN";
     nickname = "xxx";
     openid = oyAaTjsDx7pl4xxxxxxx;
     privilege =     (
     );
     province = Beijing;
     sex = 1;
     unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
     }
     */
    NSDictionary *userInfo = [noti userInfo];
    NSString *wx_openid = [userInfo objectForKey:@"openid"];
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"openid":wx_openid,
                            @"nickName":[userInfo objectForKey:@"nickname"],
                            @"headerImage":[userInfo objectForKey:@"headimgurl"]};
    [service POST:user_loginByWx parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNotification *notice = [NSNotification notificationWithName:@"firstLogin" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notice];
        self.userInfo = responseObject;
        if ([self.userInfo[@"needBind"] integerValue] > 0) {
            BindMobileViewController *vc = [[BindMobileViewController alloc]init];
            vc.userInfo = self.userInfo;
            vc.openid = wx_openid;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [JPUSHService setAlias:self.userInfo[@"uid"] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
            
            
            [[NSUserDefaults standardUserDefaults] setObject:self.userInfo forKey:@"userInfo"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
