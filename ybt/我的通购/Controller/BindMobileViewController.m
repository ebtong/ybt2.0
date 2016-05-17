//
//  BindMobileViewController.m
//  ybt
//
//  Created by 少蛟 周 on 16/4/22.
//  Copyright © 2016年 少蛟 周. All rights reserved.
//

#import "BindMobileViewController.h"
#import "SVProgressHUD.h"

@interface BindMobileViewController ()<UITextFieldDelegate>
{
    UITextField *_accountTF;
    UITextField *_codeF;
    UITextField *_passwordF;
    NSTimer *_timer;
    NSInteger _second;
}



@end

@implementation BindMobileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor = navColor;
    //1.返回按钮
    self.title = @"绑定手机";
    [self setNavItem];
    [self _createView];
    _second = 60;
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)_createView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 32 + 64, kScreenWidth - 40, 44)];
    view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 5;
    view.layer.borderColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;
    view.clipsToBounds = YES;
    [self.view addSubview:view];
    
    //手机号
    UIImageView *leftI = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xiaoshouji"]];
    leftI.frame = CGRectMake(15, 13, 16 ,18);
    leftI.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:leftI];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(leftI.right + 15, 6, 1, 30)];
    lineView.backgroundColor = [UIColor grayColor];
    [view addSubview:lineView];
    
    _accountTF = [[UITextField alloc] initWithFrame:CGRectMake(lineView.right + 18, 0, view.width - lineView.right - 18, 44)];
    [view addSubview:_accountTF];
    _accountTF.placeholder = @"输入您的手机号码";
    _accountTF.keyboardType = UIKeyboardTypeNumberPad;
    _accountTF.font = [UIFont systemFontOfSize:14];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(20, view.bottom + 20, kScreenWidth - 40, 44)];
    view2.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    view2.layer.borderWidth = 1;
    view2.layer.cornerRadius = 5;
    view2.layer.borderColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;
    view2.clipsToBounds = YES;
    [self.view addSubview:view2];
    
    UIImageView *leftC = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xinfeng"]];
    leftC.frame = CGRectMake(15, 13, 16 ,18);
    leftC.contentMode = UIViewContentModeScaleAspectFit;
    [view2 addSubview:leftC];
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(leftC.right + 15, 6, 1, 30)];
    lineView2.backgroundColor = [UIColor grayColor];
    [view2 addSubview:lineView2];
    
    _codeF = [[UITextField alloc] initWithFrame:CGRectMake(lineView2.right + 18, 0, view2.width - lineView2.right - 18, 44)];
    [view2 addSubview:_codeF];
    _codeF.placeholder = @"输入验证码";
    _codeF.keyboardType = UIKeyboardTypeNumberPad;
    _codeF.font = [UIFont systemFontOfSize:14];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(view2.width - 80, 0, 80, 44);
    button.tag = 118;
    [button setBackgroundColor:GREEN_LABEL_COLOR];
    [button setTitle:@"获取验证码" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(getCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [view2 addSubview:button];
    
    //注册
    UIButton *regBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, view2.bottom + 57, kScreenWidth - 40, 40)];
    regBtn.backgroundColor = [UIColor orangeColor];
    [regBtn setImage:[UIImage imageNamed:@"yanzhengma"] forState:UIControlStateNormal];
    [self.view addSubview:regBtn];
    [regBtn setTitle:@"确定" forState:UIControlStateNormal];
    regBtn.layer.cornerRadius = 20;
    [regBtn addTarget:self action:@selector(bindAction) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)bindAction
{
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":self.userInfo[@"uid"],
                            @"mobile":_accountTF.text,
                            @"SessionId":self.userInfo[@"SessionId"],
                            @"openid":self.openid,
                            @"code":_codeF.text};
    [service POST:user_bindMobile parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"userInfo"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [_accountTF resignFirstResponder];
    [_passwordF resignFirstResponder];
    [_codeF resignFirstResponder];
}


-(void)getCodeAction:(UIButton *)button
{
    [button setTitleColor:ORANGE_LABEL_COLOR forState:UIControlStateNormal];
    [button setBackgroundColor:TABLE_BG_COLOR];
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"username":_accountTF.text,
                            @"uid":self.userInfo[@"uid"]};
    [service POST:user_sendBindCode parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"验证码发送成功"];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeOut) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)timeOut
{
    _second -- ;
    UIButton *button = (UIButton *)[self.view viewWithTag:118];
    if (_second > 0) {
        button.userInteractionEnabled = NO;
        NSString *str = [NSString stringWithFormat:@"重发（%li）",(long)_second];
        [button setTitle:str forState:UIControlStateNormal];
        [button setBackgroundColor:TABLE_BG_COLOR];
    }
    else
    {
        _second = 60;
        button.userInteractionEnabled = YES;
        [button setTitle:@"获取验证码" forState:UIControlStateNormal];
        UIImage *image = [UIImage imageNamed:@"yanzhengma"];
        [button setBackgroundImage:[image stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
        [_timer invalidate];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
