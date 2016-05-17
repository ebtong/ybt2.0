//
//  ForgetPasswordViewController.m
//  一币通购
//
//  Created by mac on 16/4/6.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "SVProgressHUD.h"

@interface ForgetPasswordViewController ()<UITextFieldDelegate>
{
    UITextField *_accountTF;
    UITextField *_codeF;
    UITextField *_passwordF;
    NSTimer *_timer;
    NSInteger _second;
}

@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.backgroundColor = navColor;
    self.view.backgroundColor = [UIColor whiteColor];
    //1.返回按钮
    [self setNavItem];
    [self _createView];
    _second = 60;
}

-(void)_createView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 32 + 64, kScreenWidth - 40, 44)];
    view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 5;
    view.layer.borderColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;
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
    [button setBackgroundColor:GREEN_LABEL_COLOR];
    button.tag = 115;
    [button setTitle:@"获取验证码" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(getCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [view2 addSubview:button];
    
    
    //密码
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(20, view2.bottom + 20, kScreenWidth - 40, 44)];
    view1.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    view1.layer.borderWidth = 1;
    view1.layer.cornerRadius = 5;
    view1.layer.borderColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;
    [self.view addSubview:view1];
    
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
    
    UIButton *eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeButton.frame = CGRectMake(view1.width - 12 - 15, 18, 15, 8);
    [eyeButton setImage:[UIImage imageNamed:@"yanjin_nor"] forState:UIControlStateNormal];
//    [eyeButton setImage:[UIImage imageNamed:@"yanjin_sel"] forState:UIControlStateHighlighted];
    [eyeButton setImage:[UIImage imageNamed:@"yanjin_sel"] forState:UIControlStateSelected];
    [eyeButton addTarget:self action:@selector(eyeAction:) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:eyeButton];
    
    //登录
    UIButton *logInBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, view1.bottom + 110, kScreenWidth - 40, 40)];
    logInBtn.backgroundColor = [UIColor orangeColor];
    logInBtn.layer.cornerRadius = logInBtn.height/2;
    [self.view addSubview:logInBtn];
    [logInBtn setTitle:@"确定" forState:UIControlStateNormal];
    [logInBtn addTarget:self action:@selector(logInAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)logInAction:(UIButton *)button{
        HttpService *service = [HttpService getInstance];
        NSDictionary *param = @{@"username":_accountTF.text,@"password":_passwordF.text,@"code":_codeF.text};
        [service POST:user_resetPwd parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [_accountTF resignFirstResponder];
    [_passwordF resignFirstResponder];
    [_codeF resignFirstResponder];
}

-(void)eyeAction:(UIButton *)button
{
    button.selected = !button.selected;
    _passwordF.secureTextEntry = !_passwordF.secureTextEntry;
}

-(void)getCodeAction:(UIButton *)button
{
    [button setTitleColor:ORANGE_LABEL_COLOR forState:UIControlStateNormal];
    [button setBackgroundColor:TABLE_BG_COLOR];
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"username":_accountTF.text};
    [service POST:user_sendMsgCode parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"验证码发送成功"];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeOut) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)timeOut
{
    _second -- ;
    UIButton *button = (UIButton *)[self.view viewWithTag:115];
    if (_second > 0) {
        button.userInteractionEnabled = NO;
        NSString *str = [NSString stringWithFormat:@"重发（%li）",(long)_second];
        [button setTitleColor:ORANGE_LABEL_COLOR forState:UIControlStateNormal];
        [button setTitle:str forState:UIControlStateNormal];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
