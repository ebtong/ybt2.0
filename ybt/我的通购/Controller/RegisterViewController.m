//
//  RegisterViewController.m
//  一币通购
//
//  Created by mac on 16/4/10.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "RegisterViewController.h"
#import "SVProgressHUD.h"

@interface RegisterViewController ()<UITextFieldDelegate>
{
    UITextField *_accountTF;
    UITextField *_codeF;
    UITextField *_passwordF;
    NSTimer *_timer;
    NSInteger _second;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor = navColor;
    //1.返回按钮
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
    
    //密码
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(20, view.bottom + 20, kScreenWidth - 40, 44)];
    view1.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    view1.layer.borderWidth = 1;
    view1.layer.cornerRadius = 5;
    view1.layer.borderColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;
    view1.clipsToBounds = YES;
    [self.view addSubview:view1];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(20, view1.bottom + 20, kScreenWidth - 40, 44)];
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
    button.tag = 98;
    button.frame = CGRectMake(view2.width - 80, 0, 80, 44);
    [button setTitle:@"获取验证码" forState:UIControlStateNormal];
    [button setBackgroundColor:GREEN_LABEL_COLOR];
    [button addTarget:self action:@selector(getCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [view2 addSubview:button];
    UIImageView *passwordI = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"suo.png"]];
    passwordI.frame = CGRectMake(15, 13, 16 ,18);
    passwordI.contentMode = UIViewContentModeScaleAspectFit;
    [view1 addSubview:passwordI];
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(passwordI.right + 15, 6, 1, 30)];
    lineView1.backgroundColor = [UIColor grayColor];
    [view1 addSubview:lineView1];
    
    _passwordF = [[UITextField alloc] initWithFrame:CGRectMake(lineView.right + 18, 0, view.width - lineView.right - 18, 44)];
    [view1 addSubview:_passwordF];
    _passwordF.placeholder = @"密码";
    _passwordF.font = [UIFont systemFontOfSize:14];
    _passwordF.keyboardType = UIKeyboardTypeDefault;
    _passwordF.secureTextEntry = YES;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, view2.bottom + 57, kScreenWidth, 14)];
    label.text = @"点击注册即表示接受《服务协议》";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = HGfont(14);
    [self.view addSubview:label];
    
    //注册
    UIButton *regBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, label.bottom + 15, kScreenWidth - 40, 40)];
    regBtn.backgroundColor = [UIColor orangeColor];
//    [regBtn setImage:[UIImage imageNamed:@"yanzhengma"] forState:UIControlStateNormal];
    [self.view addSubview:regBtn];
    [regBtn setTitle:@"注册" forState:UIControlStateNormal];
    regBtn.layer.cornerRadius = 20;
    [regBtn addTarget:self action:@selector(regAction) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)regAction
{
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"username":_accountTF.text,@"password":_passwordF.text,@"code":_codeF.text};
    [service POST:user_register parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"userInfo"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)timeOut
{
    _second -- ;
    UIButton *button = (UIButton *)[self.view viewWithTag:98];
    if (_second > 0) {
        button.userInteractionEnabled = NO;
        NSString *str = [NSString stringWithFormat:@"重发（%li）",(long)_second];
        [button setTitle:str forState:UIControlStateNormal];
        [button setTitleColor:ORANGE_LABEL_COLOR forState:UIControlStateNormal];
        [button setBackgroundColor:TABLE_BG_COLOR];
    }
    else
    {
        _second = 60;
        button.userInteractionEnabled = YES;
        [button setTitle:@"获取验证码" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIImage *image = [UIImage imageNamed:@"yanzhengma"];
        [button setBackgroundImage:[image stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
        [_timer invalidate];
    }
    
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
    NSDictionary *param = @{@"username":_accountTF.text};
    [service POST:user_sendRegCode parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"验证码发送成功"];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeOut) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
