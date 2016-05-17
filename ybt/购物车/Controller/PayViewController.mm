//
//  PayViewController.m
//  一币通购
//
//  Created by mac on 16/4/19.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "PayViewController.h"
#import "SVProgressHUD.h"
#import "LogInViewController.h"
#import "PayDetailViewController.h"
#import "KGModal.h"
#import "TYAttributedLabel.h"
#import "TaskCenterTableViewController.h"

/*爱贝云支付*/
#import <IapppayKit/IapppayOrderUtils.h>
#import <IapppayKit/IapppayKit.h>

/*微信支付头文件开始*/
#import "WXApi.h"
#import "payRequsestHandler.h"
#import <QuartzCore/QuartzCore.h>
#define ALI_PAY_TYPE @"3"
#define WECHAT_PAY_TYPE @"4"

@interface PayViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,IapppayKitPayRetDelegate>{
    BOOL has_jifen;
    NSString *mAppId;
    NSString *mChannel;
    NSString *mCheckResultKey;
    NSDictionary *userInfo;
}
@property (assign,nonatomic) NSInteger payType;
@property (strong,nonatomic) UIButton *selectedBtn;

@property (strong,nonatomic) NSString *objectName;
@property (strong,nonatomic) NSString *orderSn;
@property (assign,nonatomic) float price;
@property (assign,nonatomic) float payMoney;
@property (strong,nonatomic) NSString *paperId;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSDictionary *appSetting;
@property (strong,nonatomic) NSString *safariSn;
@property (strong,nonatomic) UIButton *submitBtn;

@end

@implementation PayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavItem];
    [self setRightNavItem];
    _price = 0.0;
    if (self.listArray.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"商品不能为空！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoBySafariSn) name:@"loadSafariSnNotification" object:nil];
    
    self.view.backgroundColor = CELL_BG_COLOR;
    // Do any additional setup after loading the view from its nib.
    [self _createView];
}



-(void)viewWillAppear:(BOOL)animated{
    _appSetting = [[NSUserDefaults standardUserDefaults]objectForKey:@"appSetting"];
    self.tabBarController.tabBar.hidden = YES;
    [self reloadUserInfo];
    [self infoBySafariSn];
}
-(void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
}


-(void)_createView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 34 - 44) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = TABLE_BG_COLOR;
    tableView.bounces = NO;
    tableView.separatorColor = TABLE_BG_COLOR;
    [self.view addSubview:tableView];
    _tableView = tableView;
    
    CGFloat money = 0;
    BOOL has_money = NO;
    for (int i = 0; i < self.listArray.count; i++) {
        NSDictionary *dict = self.listArray[i];
        if ([dict[@"info"][@"jfen"] length] > 0) {
            has_jifen = YES;
            money += [dict[@"info"][@"jfenInfo"][@"limit_num"] floatValue] * [dict[@"num"] integerValue];
        }else{
            has_money = YES;
            money += [dict[@"info"][@"yunjiage"]floatValue] * [dict[@"num"] integerValue];
        }
    }
    
    if (has_jifen && has_money) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"暂不支持 通币商品 和 通豆商品 同时购买！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44 - 34, kScreenWidth, 34)];
    if (has_jifen) {
        label1.text = [NSString stringWithFormat:@"共%ld件商品，奖品合计：%.f通豆",(unsigned long)self.listArray.count,money];
    }else{
        label1.text = [NSString stringWithFormat:@"共%ld件商品，奖品合计：%.2f通币",(unsigned long)self.listArray.count,money];
        userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
        _price = money;
    }
    
    label1.font = HGfont(13);
    label1.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label1];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44);
    [button setBackgroundColor:ORANGE_LABEL_COLOR];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = HGfont(16);
    [button addTarget:self action:@selector(payAction) forControlEvents:UIControlEventTouchUpInside];
    _submitBtn = button;
    [self.view addSubview:button];
    self.view.backgroundColor = TABLE_BG_COLOR;
}

-(void)payToSafari:(NSDictionary *)param{
    HttpService *service = [HttpService getInstance];
    _submitBtn.userInteractionEnabled = NO;
    [_submitBtn setBackgroundColor:GREY_LABEL_COLOR];
    [service POST:order_payToSafari parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _safariSn = responseObject;
        [_submitBtn setBackgroundColor:ORANGE_LABEL_COLOR];
        _submitBtn.userInteractionEnabled = YES;
        NSString *urlstr = [NSString stringWithFormat:@"%@/%@/%@",HOST_URL,order_payBySafari,_safariSn];
        UIView *mView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 200)];
        mView.layer.cornerRadius = 4;
        mView.clipsToBounds = YES;
        mView.backgroundColor = [UIColor whiteColor];
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 270, 40)];
        tLabel.numberOfLines = 2;
        tLabel.textColor = ORANGE_LABEL_COLOR;
        tLabel.text = @"复制以下链接去 safari 浏览器打开，进行支付";
        tLabel.font = HGfont(14);
        [mView addSubview:tLabel];
        
        UILabel *mLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 60, 270, 80)];
        mLabel.textColor = GREY_LABEL_COLOR;
        mLabel.text = urlstr;
        mLabel.layer.borderColor = [ORANGE_BG_COLOR CGColor];
        mLabel.layer.borderWidth = 1;
        mLabel.font = HGfont(14);
        mLabel.layer.cornerRadius = 3;
        mLabel.textAlignment = NSTextAlignmentCenter;
        mLabel.clipsToBounds = YES;
        mLabel.numberOfLines = 0;
        [mView addSubview:mLabel];
        
        UIButton *copyBtn = [[UIButton alloc]initWithFrame:CGRectMake(300 - 15 - 15 - 80, mLabel.top - 15, 80, 30)];
        [copyBtn setTitle:@"立即复制" forState:UIControlStateNormal];
        [copyBtn setTitleColor:ORANGE_LABEL_COLOR forState:UIControlStateNormal];
        
        copyBtn.titleLabel.font = HGfont(14);
        copyBtn.layer.borderColor = [ORANGE_BG_COLOR CGColor];
        copyBtn.layer.borderWidth = 1;
        copyBtn.layer.cornerRadius = 3;
        copyBtn.clipsToBounds = YES;
        copyBtn.backgroundColor = [UIColor whiteColor];
        [copyBtn addTarget:self action:@selector(copyBtnPress) forControlEvents:UIControlEventTouchUpInside];
        [mView addSubview:copyBtn];
        
        UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, mLabel.bottom + 15, 90, 32)];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelBtn.backgroundColor = ORANGE_LABEL_COLOR;
        cancelBtn.layer.borderColor = [TABLE_BG_COLOR CGColor];
        cancelBtn.layer.borderWidth = 1;
        cancelBtn.layer.cornerRadius = 4;
        cancelBtn.clipsToBounds = YES;
        cancelBtn.titleLabel.font = HGfont(14);
        [cancelBtn addTarget:self action:@selector(cancelBtnPress) forControlEvents:UIControlEventTouchUpInside];
        [mView addSubview:cancelBtn];

        UIButton *finishedBtn = [[UIButton alloc]initWithFrame:CGRectMake(300 - 15 - 90, mLabel.bottom + 15, 90, 32)];
        [finishedBtn setTitle:@"已支付成功" forState:UIControlStateNormal];
        finishedBtn.backgroundColor = ORANGE_LABEL_COLOR;
        [finishedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        finishedBtn.layer.borderColor = [TABLE_BG_COLOR CGColor];
        finishedBtn.layer.borderWidth = 1;
        finishedBtn.layer.cornerRadius = 4;
        finishedBtn.clipsToBounds = YES;
        finishedBtn.titleLabel.font = HGfont(14);
        [finishedBtn addTarget:self action:@selector(finishedBtnPress) forControlEvents:UIControlEventTouchUpInside];
        [mView addSubview:finishedBtn];
        [[KGModal sharedInstance]showWithContentView:mView andAnimated:YES];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlstr]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _submitBtn.userInteractionEnabled = YES;
        [_submitBtn setBackgroundColor:ORANGE_LABEL_COLOR];
    }];
}

-(void)copyBtnPress{
    if (_safariSn.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"复制失败"];
        return;
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *urlstr = [NSString stringWithFormat:@"%@/%@/%@",HOST_URL,order_payBySafari,_safariSn];
    pasteboard.string = urlstr;
    if (pasteboard == nil) {
        [SVProgressHUD showErrorWithStatus:@"复制失败"];
    }else {
        [SVProgressHUD showSuccessWithStatus:@"复制成功"];
    }
}
-(void)cancelBtnPress{
    [[KGModal sharedInstance]hide];
}
-(void)finishedBtnPress{
    [self infoBySafariSn];
}

-(void)infoBySafariSn{
    if (_safariSn.length <= 0) {
        return;
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]) {
        return;
    }
    userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    
    NSDictionary *param = @{@"uid":userInfo[@"uid"],
                            @"SessionId":
                                userInfo[@"SessionId"],
                            @"safariSn":_safariSn};
    NSMutableDictionary *cartList = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"cartList"]];
    HttpService *service = [HttpService getInstance];
    [service POST:order_infoBySafariSn parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] integerValue] == 0) {
            [SVProgressHUD showErrorWithStatus:@"该订单尚未支付！"];
            return ;
        }else{
            [[KGModal sharedInstance]hide];
            NSMutableDictionary *goodsList = [NSMutableDictionary dictionary];
            NSMutableArray *goodsArr = [NSMutableArray array];
            for (int i = 0; i < _listArray.count; i++) {
                NSDictionary *dict = _listArray[i];
                goodsList[@"id"] = dict[@"info"][@"id"];
                goodsList[@"num"] = dict[@"num"];
                [goodsArr addObject:goodsList];
                NSString *cart_id = [NSString stringWithFormat:@"cart_%@",dict[@"info"][@"id"]];
                [cartList removeObjectForKey:cart_id];
            }
            [[NSUserDefaults standardUserDefaults] setObject:cartList forKey: @"cartList"];
            [SVProgressHUD showSuccessWithStatus:@"购买成功！"];
            [self payDetail];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)reloadUserInfo{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]) {
        return;
    }
    userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":userInfo[@"uid"],
                            @"SessionId":
                                userInfo[@"SessionId"]};
    [service POST:user_detail parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"userInfo"];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)payAction
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]) {
        LogInViewController *vc = [[LogInViewController alloc] init];
        vc.title = @"登陆";
        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:nvc animated:YES completion:nil];
        return;
    }
    userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];

    NSMutableDictionary *cartList = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"cartList"]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    NSMutableArray *goodsArr = [NSMutableArray array];
    for (int i = 0; i < self.listArray.count; i++) {
        NSDictionary *dict = self.listArray[i];
        dic[dict[@"info"][@"id"]] = dict[@"num"];
    }
    
//    NSString *listJson = [CommonUtil getJSONStr:goodsArr];
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":userInfo[@"uid"],
                            @"SessionId":userInfo[@"SessionId"],
                            @"goodsArr":dic};
    if (_appSetting && [_appSetting[@"thirdHide"] integerValue] == 1) {
        [self payToSafari:param];
        return;
    }
    
    if ([userInfo[@"money"] floatValue] < _price) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"您的通币不足" message:@"使用其他支付方式？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去支付", nil];
        alertView.tag = 88;
        [alertView show];
        return;
    }
    
    
    [SVProgressHUD showWithStatus:@"正在支付！"];
    [service POST:order_payByBalance parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            NSMutableDictionary *goodsList = [NSMutableDictionary dictionary];
            for (int i = 0; i < _listArray.count; i++) {
                NSDictionary *dict = _listArray[i];
                goodsList[@"id"] = dict[@"info"][@"id"];
                goodsList[@"num"] = dict[@"num"];
                NSString *cart_id = [NSString stringWithFormat:@"cart_%@",dict[@"info"][@"id"]];
                [cartList removeObjectForKey:cart_id];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:cartList forKey: @"cartList"];
            [SVProgressHUD showErrorWithStatus:@"购买成功！"];
            [self payDetail];
        }else if ([responseObject[@"status"] integerValue] == 2) {
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"您的通币不足" message:@"使用其他支付方式？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去支付", nil];
            alertView.tag = 88;
            [alertView show];
        }else if ([responseObject[@"status"] integerValue] == 3) {
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"您的通豆不足" message:@"立即赚取通豆？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"赚通豆", nil];
            alertView.tag = 77;
            [alertView show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 77) {
        if (buttonIndex == 1) {
            [self showTask];
        }
    }else if (alertView.tag == 88) {
        if (buttonIndex == 1) {
            [self payOrderAction];
        }
    }
}

-(void)payOrderAction{
    userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (int i = 0; i < self.listArray.count; i++) {
        NSDictionary *dict = self.listArray[i];
        dic[dict[@"info"][@"id"]] = dict[@"num"];
    }
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":userInfo[@"uid"],
                            @"SessionId":userInfo[@"SessionId"],
                            @"goodsArr":dic};
    [service POST:order_payOrderAction parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"responseObject:%@",responseObject);
        _orderSn = responseObject[@"sn"];
        _payMoney = [responseObject[@"third_money"] floatValue];
//        _payMoney = 0.01;
        [self payByLapppay];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)payByLapppay
{
    NSString *cpOrderId = _orderSn;
    if (cpOrderId == nil) {
        [SVProgressHUD showErrorWithStatus:@"订单号不存在"];
        return;
    }
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"]) {
        [SVProgressHUD showErrorWithStatus:@"请先登录！"];
        return;
    }
    userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    
    IapppayOrderUtils *orderInfo = [[IapppayOrderUtils alloc] init];
    orderInfo.appId         = mOrderUtilsAppId;
    orderInfo.cpPrivateKey  = mOrderUtilsCpPrivateKey;
    orderInfo.notifyUrl     = mOrderUtilsNotifyurl;
    orderInfo.cpOrderId     = cpOrderId;
    orderInfo.waresId       = @"2";
    orderInfo.price         = [NSString stringWithFormat:@"%.2f",_payMoney];
    orderInfo.appUserId     = userInfo[@"uid"];
    orderInfo.waresName     = [NSString stringWithFormat:@"购买商品,还需支付%.2f元",_payMoney]
    ;
    orderInfo.cpPrivateInfo = [NSString stringWithFormat:@"%ld件商品，奖品合计：%.2f通币",(unsigned long)self.listArray.count,_price];
    
    NSString *trandInfo = [orderInfo getTrandData];
    [[IapppayKit sharedInstance] makePayForTrandInfo:trandInfo payDelegate:self];
}


/**
 * 此处方法是支付结果处理
 **/
#pragma mark - IapppayKitPayRetDelegate
- (void)iapppayKitRetPayStatusCode:(IapppayKitPayRetCodeType)statusCode
                        resultInfo:(NSDictionary *)resultInfo
{
//    NSLog(@"statusCode : %d, resultInfo : %@", (int)statusCode, resultInfo);
    
    if (statusCode == IAPPPAY_PAYRETCODE_SUCCESS)
    {
        [self paySuccess];
        BOOL isSuccess = [IapppayOrderUtils checkPayResult:resultInfo[@"Signature"]
                                                withAppKey:mCheckResultKey];
        if (isSuccess) {
            //支付成功，验签成功
//            [SVProgressHUD showSuccessWithStatus:@"支付成功，验签成功"];
            
        } else {
            //支付成功，验签失败
//            [SVProgressHUD showErrorWithStatus:@"支付成功，验签失败"];
        }
    }
    else if (statusCode == IAPPPAY_PAYRETCODE_FAILED)
    {
        [self payFail];
        //支付失败
//        NSString *message = @"支付失败";
//        if (resultInfo != nil) {
//            message = [NSString stringWithFormat:@"%@:code:%@\n（%@）",message,resultInfo[@"RetCode"],resultInfo[@"ErrorMsg"]];
//        }
//        [SVProgressHUD showErrorWithStatus:message];
    }
    else
    {
        //支付取消
        NSString *message = @"支付取消";
//        if (resultInfo != nil) {
//            message = [NSString stringWithFormat:@"%@:code:%@\n（%@）",message,resultInfo[@"RetCode"],resultInfo[@"ErrorMsg"]];
//        }
        [SVProgressHUD showErrorWithStatus:message];
    }
}

-(void)showTask{
    TaskCenterTableViewController *vc = [[UIStoryboard storyboardWithName:@"Mine" bundle:nil]instantiateViewControllerWithIdentifier:@"TaskCenterTableViewControllerID"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)payDetail{
    PayDetailViewController *vc = [[PayDetailViewController alloc]init];
    vc.title = @"支付结果";
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"payCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"payCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (id subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    if (indexPath.row == 0) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, 70 / 2 - 10, 20, 20);
        [button setImage:[UIImage imageNamed:@"xuanze_nor"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"xuanze_sel"] forState:UIControlStateSelected];
        button.tag = 150 +indexPath.row;
        [cell.contentView addSubview:button];
        if (self.payType == 0) {
            button.selected = YES;
            _selectedBtn = button;
        }
        button.userInteractionEnabled = NO;
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(button.right + 20, 70 / 2 - 15, 30, 30)];
        imageView.image = [UIImage imageNamed:@"tongbi"];
        [cell.contentView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 8, 0, 200, 70)];
        label.text = @"通币支付";
        label.font = HGfont(15);
        label.textColor = NORMAL_LABEL_COLOR;
        [cell.contentView addSubview:label];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]) {
            userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
            
            TYAttributedLabel *moneyLabel = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(kScreenWidth - 150 - 8, 26, 150, 18)];
            moneyLabel.textAlignment = kCTTextAlignmentRight;
            [cell.contentView addSubview:moneyLabel];
            
            NSString *str = [NSString stringWithFormat:@"余额<c>%@<c>通币",userInfo[@"money"]];
            moneyLabel = [CommonUtil getLabel:moneyLabel str:str color:@[GREY_LABEL_COLOR,RED_BTN_COLOR] font:@[@13]];
        }
        
        
        if (has_jifen) {
            button.selected = NO;
            label.textColor = TABLE_BG_COLOR;
            cell.userInteractionEnabled = NO;
        }else{
            button.selected = YES;
            label.textColor = NORMAL_LABEL_COLOR;
            cell.userInteractionEnabled = YES;
        }
    }else if (indexPath.row == 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, 70 / 2 - 10, 20, 20);
        [button setImage:[UIImage imageNamed:@"xuanze_nor"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"xuanze_sel"] forState:UIControlStateSelected];
        button.tag = 150 +indexPath.row;
        [cell.contentView addSubview:button];
        if (self.payType == 1) {
            button.selected = YES;
            _selectedBtn = button;
        }
        button.userInteractionEnabled = NO;
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(button.right + 20, 70 / 2 - 15 + 6, 31.5, 18.5)];
        imageView.image = [UIImage imageNamed:@"tongdou"];
        [cell.contentView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right + 8, 0, 200, 70)];
        label.text = @"通豆支付";
        label.font = HGfont(15);
        label.textColor = NORMAL_LABEL_COLOR;
        [cell.contentView addSubview:label];
        
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]) {
            userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
            
            TYAttributedLabel *moneyLabel = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(kScreenWidth - 150 - 8, 26, 150, 18)];
            moneyLabel.textAlignment = kCTTextAlignmentRight;
            [cell.contentView addSubview:moneyLabel];
            
            NSString *str = [NSString stringWithFormat:@"余额<c>%@<c>通豆",userInfo[@"score"]];
            
            moneyLabel = [CommonUtil getLabel:moneyLabel str:str color:@[GREY_LABEL_COLOR,RED_BTN_COLOR] font:@[@13]];
        }
        
        
        if (!has_jifen) {
            button.selected = NO;
            label.textColor = TABLE_BG_COLOR;
            cell.userInteractionEnabled = NO;
        }else{
            button.selected = YES;
            label.textColor = NORMAL_LABEL_COLOR;
            cell.userInteractionEnabled = YES;
        }
    }else if (indexPath.row == 2) {
        cell.backgroundColor = TABLE_BG_COLOR;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 70)];
        label.numberOfLines = 0;
        label.font = HGfont(14);
        label.text = @"支付一元购买1M网盘，系统自动赠送1通币（1元＝1通币）可用于夺宝，充值的款项将无法退回。";
        [cell.contentView addSubview:label];
    }
    
    
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 2) {
        _selectedBtn.selected = NO;
        UIButton *button = (UIButton *)[self.view viewWithTag:150 + indexPath.row];
        button.selected = YES;
        _selectedBtn = button;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
}
/**
 *初始化通知，支付宝、微信共用
 */
- (void)initNotification {
    //    支付宝注册通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paySuccess) name:@"PaySuccessNotification" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payFail) name:@"PayFailNotification" object:nil];
}
/**
 *支付宝、微信成功
 */
- (void)paySuccess {
    //TODO 改充值订单状态
    [self payOrder];
    
    // 调用支付成功
}
//支付宝、微信支付失败
- (void)payFail {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"支付失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//    alert.delegate = self;
    [alert show];
}

-(void)payOrder{
    NSMutableDictionary *cartList = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"cartList"]];
    userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":userInfo[@"uid"],
                            @"SessionId":
                                userInfo[@"SessionId"],
                            @"sn":_orderSn};
    
    [service POST:order_payOrder parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *goodsList = [NSMutableDictionary dictionary];
        for (int i = 0; i < _listArray.count; i++) {
            NSDictionary *dict = _listArray[i];
            goodsList[@"id"] = dict[@"info"][@"id"];
            goodsList[@"num"] = dict[@"num"];
            NSString *cart_id = [NSString stringWithFormat:@"cart_%@",dict[@"info"][@"id"]];
            [cartList removeObjectForKey:cart_id];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:cartList forKey: @"cartList"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"订单支付成功！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [self payDetail];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
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
