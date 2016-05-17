//
//  UserService.m
//  MobileSheild
//
//  Created by HuangXiuJie on 15/3/28.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "HttpService.h"
#import "SVProgressHUD.h"
#import "JPUSHService.h"

@implementation HttpService
- (instancetype)init {
    self.manager = [AFHTTPRequestOperationManager manager];
    return self;
}
+ (instancetype)getInstance {
    static HttpService *instance;
    if (instance == nil) {
        instance = [[self alloc]init];
    }
    return instance;
}

- (void)POST:(NSString *)actionStr parameters:(NSDictionary *)parameters success:(success)success failure:(failure)failure{
    NSString *urlstr = [NSString stringWithFormat:@"%@/%@",HOST_URL,actionStr];
    
    [self.manager POST:urlstr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:CODE_STRING] isEqualToNumber:SUCCESS_CODE]) {
            success(operation,responseObject[@"data"]);
        } else if ([[responseObject objectForKey:CODE_STRING] isEqualToNumber:UNLOGIN_CODE]) {
            [SVProgressHUD showSuccessWithStatus:@"身份验证失败！"];
            [JPUSHService clearAllLocalNotifications];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"userInfo"];
            //                    unLogin();
        } else {
            [SVProgressHUD dismiss];
            NSLog(@"responseString:%@",responseObject);
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[responseObject objectForKey:@"msg"] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"urlstr:%@",urlstr);
        NSLog(@"responseString:%@",operation.responseString);
        if (failure) {
            failure(operation,error);
        }
    }];

}
@end
