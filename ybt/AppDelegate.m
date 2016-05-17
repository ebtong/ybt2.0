//
//  AppDelegate.m
//  0元夺宝
//
//  Created by 老钱 on 16/3/24.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTabBarController.h"
#import "SVProgressHUD.h"
#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>
#import "KGModal.h"
#import <IapppayKit/IapppayKit.h>

@interface AppDelegate ()<IapppayKitPayRetDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIColor *tintColor = navColor;
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setBarTintColor:tintColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance]setTintColor:navColor];
    
    
    // Override point for customization after application launch.
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions
                           appKey:kJPUSH_APP_ID
                          channel:@""
                 apsForProduction:NO
            advertisingIdentifier:advertisingId];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[IapppayKit sharedInstance] setAppAlipayScheme:@"iapppay.alipay.com.AiBei.ybt"];
    
    [WXApi registerApp:kWXAPP_ID withDescription:@"ybt"];
    self.window.rootViewController = [[MainTabBarController alloc] init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadLoginData) name:@"firstLogin" object:nil];
    return YES;
}

//和QQ,新浪并列回调句柄
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation  {
    [[IapppayKit sharedInstance] handleOpenUrl:url];
    [WXApi handleOpenURL:url delegate:self];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url  {
    [[IapppayKit sharedInstance] handleOpenUrl:url];
    [WXApi handleOpenURL:url delegate:self];
    return YES;
}

//微信支付代理方法
//回调支付成功与否
//授权后回调 WXApiDelegate
-(void)onResp:(BaseResp *)resp  {
    /*     ErrCode ERR_OK = 0(用户同意)
     ERR_AUTH_DENIED = -4（用户拒绝授权）
     ERR_USER_CANCEL = -2（用户取消）
     code    用户换取access_token的code，仅在ErrCode为0时有效                         state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
     lang    微信客户端当前语言
     country 微信用户当前国家信息
     */
    if([resp isKindOfClass:[SendMessageToWXResp class]]){
        
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        switch (resp.errCode) {
            case WXSuccess:
                [self WXSuccessAction];
                break;
            default:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sendFailNotification" object:nil];
                break;
        }
    }else if([resp isKindOfClass:[SendAuthResp class]]){
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.errCode== 0) {
            NSString *code = aresp.code;
            NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWXAPP_ID,kWXAPP_SECRET,code];
            [self getWX_token:url];
        }
    }
}

-(void)WXSuccessAction{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendSuccessNotification" object:nil];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]) {
        [SVProgressHUD showSuccessWithStatus:@"分享成功，每日登录后再分享，奖励30通豆哦！"];
        return;
    }
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    
    NSDictionary *param = @{@"uid":userInfo[@"uid"],
                            @"SessionId":userInfo[@"SessionId"]};
    
    HttpService *service = [HttpService getInstance];
    [service POST:user_shareScore parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:@"分享成功，获得30通豆！"];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"分享成功"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"分享失败！"];
    }];
    
}

-(void)getWX_token:(NSString *)url {
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
                 "expires_in" = 7200;
                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
                 scope = "snsapi_userinfo,snsapi_base";
                 }
                 */
                NSString *wx_token = [dic objectForKey:@"access_token"];
                NSString *wx_openid = [dic objectForKey:@"openid"];
                
                [self getUserInfo:wx_token openid:wx_openid];
                //                self.access_token.text = [dic objectForKey:@"access_token"];
                //                self.openid.text = [dic objectForKey:@"openid"];
            }
        });
    });
}

-(void)getUserInfo:(NSString *)wx_token  openid:(NSString *)wx_openid {
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",wx_token,wx_openid];
    
    [SVProgressHUD showWithStatus:@"加载数据。。" maskType:SVProgressHUDMaskTypeGradient];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
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
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WXLoginedNotification" object:self userInfo:dic];
            }
            [SVProgressHUD dismiss];
        });
    });
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
    
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
    [self getAppSetting];
}

-(void)getAppSetting{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    HttpService *service = [HttpService getInstance];
    [service POST:data_appSetting parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *appSetting = [NSMutableDictionary dictionaryWithDictionary:responseObject];
        NSString *checkVersion = [NSString stringWithFormat:@"%@",responseObject[@"checkVersion"]];
        if ([checkVersion isEqualToString:app_Version]) {
            appSetting[@"thirdHide"] = @1;
        }
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]) {
            NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
            if ([userInfo[@"uid"] integerValue] == 8675) {
                appSetting[@"thirdHide"] = @1;
            }
        }
        [[NSUserDefaults standardUserDefaults]setObject:appSetting forKey:@"appSetting"];
        
//        NSLog(@"appSetting:%@",appSetting);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
    [self getAppSetting];
    [self loadLoginData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadSafariSnNotification" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
}
#endif

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

-(void)loadLoginData
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]) {
        return;
    }
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":dic[@"uid"]};
    [service POST:home_qiandao parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"code"] integerValue ] == 1) {
            [self _createOnceView:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)_createOnceView:(NSDictionary *)dic
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    view.tag = 55;
    
    UIImageView *lightView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 874/2, 874.0 /2)];
    lightView.center = view.center;
    lightView.image = [UIImage imageNamed:@"Signin_Light"];
    [view addSubview:lightView];
    
    UIImageView *boxBg =[[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - (168.0 / 750.0 * kScreenWidth * 2), kScreenHeight / 2 - (194.0 / 1334.0 * kScreenHeight * 2), (168.0 / 750.0 * kScreenWidth * 2) * 2, (194.0 / 1334.0 * kScreenHeight * 2)*2)];
    boxBg.image = [UIImage imageNamed:@"Signin_flowering"];
    [view addSubview:boxBg];
    
    UIImageView *box = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - (94.0 / 750.0 * kScreenWidth * 2), kScreenHeight / 2 - (69.0 / 1334.0 * kScreenHeight * 2), (94.0/ 750.0 * kScreenWidth * 2) * 2, (69.0 / 1334.0 * kScreenHeight * 2) * 2)];
    box.image = [UIImage imageNamed:@"Signin_box"];
    [view addSubview:box];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 120 - 14, kScreenWidth / 2, 14)];
    label.text = @"通豆";
    label.textColor = [UIColor colorWithRed:254/255.0 green:239/255.0 blue:172/255.0 alpha:1];
    label.textAlignment = NSTextAlignmentRight;
    [view addSubview:label];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth / 2, label.top, kScreenWidth / 2, 14)];
    label1.text = @"+30";
    label1.textColor = [UIColor whiteColor];
    [view addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectZero];
    label2.text = [NSString stringWithFormat:@"%@",dic[@"sign_in_time"]];
    UIFont *fnt1 = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
    label2.font = fnt1;
    label2.textColor = [UIColor whiteColor];
    label2.textAlignment = NSTextAlignmentCenter;
    CGSize labelSize1 = [label1.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt1,NSFontAttributeName, nil]];
    label2.frame = CGRectMake(kScreenWidth / 2 - labelSize1.width / 2, label1.top - 28, labelSize1.width, labelSize1.height);
    [view addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, label2.center.y - 7, kScreenWidth / 2 - labelSize1.width, 14)];
    label3.text = @"连续第";
    label3.textColor = [UIColor colorWithRed:254/255.0 green:239/255.0 blue:172/255.0 alpha:1];
    label3.textAlignment = NSTextAlignmentRight;
    [view addSubview:label3];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth / 2 + labelSize1.width, label3.top, kScreenWidth / 2 - labelSize1.width, 14)];
    label4.text = @"日登录";
    label4.textColor = [UIColor colorWithRed:254/255.0 green:239/255.0 blue:172/255.0 alpha:1];
    [view addSubview:label4];
    
    if ([dic[@"zhuanpan"] integerValue]==1) {
        UILabel *turnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, label.bottom + 10, kScreenWidth, 14)];
        turnLabel.text = @"转盘次数＋1";
        turnLabel.textColor = [UIColor colorWithRed:254/255.0 green:239/255.0 blue:172/255.0 alpha:1];
        turnLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:turnLabel];
    }
    
    UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBtnPress)];
    [view addGestureRecognizer:tapPress];
    
    NSInteger a =  360;
    CABasicAnimation* rotationAnimation;
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0]; // 起始角度
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:a * M_PI/180 ];
    rotationAnimation.duration = 3.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.delegate = nil;
    rotationAnimation.fillMode=kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.repeatCount = 10;
    [lightView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

    [[KGModal sharedInstance]showWithContentView:view andAnimated:YES];
    
}

- (void)hideBtnPress{
    [[KGModal sharedInstance]hide];
}
@end
