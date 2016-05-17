//
//  PrizeDetailViewController.m
//  0元夺宝
//
//  Created by mac on 16/4/2.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "PrizeDetailViewController.h"
#import "HttpService.h"
#import "LogInViewController.h"
#import "UIImageView+AFNetworking.h"
#import "KGModal.h"
#import "SVProgressHUD.h"
#import "KSKRoundCornerCell.h"
#import "ShaiDanTableViewController.h"

/*爱贝云支付*/
#import <IapppayKit/IapppayOrderUtils.h>
#import <IapppayKit/IapppayKit.h>


@interface PrizeDetailViewController ()<UIScrollViewDelegate,UITableViewDelegate,UIAlertViewDelegate,UITableViewDataSource,IapppayKitPayRetDelegate>
{
    NSInteger number;

    CGFloat cellNormolHeight;
    CGFloat cellSelectHeight;
    NSMutableArray *state;
    NSString *mAppId;
    NSString *mChannel;
    NSString *mCheckResultKey;
}
@property (strong,nonatomic) NSDictionary *userInfo;
@property (strong,nonatomic) NSDictionary *orderInfo;
@property (strong,nonatomic) NSArray *addressArr;
@property (strong,nonatomic) UITableView *selectTableView;
@property (assign,nonatomic) NSInteger selectedAddressRow;
@property (strong,nonatomic) UIView *headerView;
@property (strong,nonatomic) NSString *orderSn;
@property (assign,nonatomic) float price;
@property (assign,nonatomic) float payMoney;

@end

@implementation PrizeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = HGColor(245, 245, 245);
    state = [NSMutableArray array];
    self.addressArr = [NSArray array];
    self.selectedAddressRow = -1;
    [self setNavItem];
    [self loadOrder];
    [self setRightNavItem];

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView.tag == 65) {
        return self.headerView;
    }
    return nil;
}


-(void)loadOrder{
    self.userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    if (!self.userInfo) {
        LogInViewController *vc = [[LogInViewController alloc] init];
        vc.title = @"登陆";
        UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:nvc animated:YES completion:nil];
        return;
    }
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"goodsId":self.dataInfo[@"id"],
                            @"orderId":self.dataInfo[@"orderId"]};
    [service POST:order_detail parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.orderInfo = responseObject;
        self.addressArr = responseObject[@"businessList"];
        NSString *mode = self.orderInfo[@"order"][@"mode"];
        if ([mode integerValue] == 0) {
            [self _createChooseView];
        }
        else
        {
            [self _createView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)selectedBusiness{
    HttpService *service = [HttpService getInstance];
    NSDictionary *dict = self.addressArr[self.selectedAddressRow];
    NSDictionary *param = @{@"goodsId":self.dataInfo[@"id"],
                            @"businessID":[NSString stringWithFormat:@"%@",dict[@"businessID"]],
                            @"orderId":self.orderInfo[@"order"][@"id"],
                            @"uid":self.userInfo[@"uid"]};
    [service POST:order_reserve parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.orderInfo = responseObject;
        self.addressArr = responseObject[@"businessList"];
        [self loadOrder];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)getPrizes{
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"orderId":self.orderInfo[@"order"][@"id"],
                            @"goodsId":self.dataInfo[@"id"],
                            @"uid":self.userInfo[@"uid"]};
    [service POST:order_receive parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self loadOrder];
        [SVProgressHUD showSuccessWithStatus:@"领取成功!"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (alertView.tag == 77) {
            [self getPrizes];
        }else if (alertView.tag == 11){
            [self selectedBusiness];
        }else if (alertView.tag == 88){
            [self payWelfareByBalance];
        }else if (alertView.tag == 99){
            [self payWelfareAction];
        }
    }
}

-(void)selectButtonPress:(UIButton *)sender{
    if (self.selectedAddressRow < 0) {
        [SVProgressHUD showErrorWithStatus:@"请选择商家！"];
        return;
    }
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"确定选择商家？" message:@"确认选择后无法修改" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 11;
    [alertView show];
    
}

-(void)_createChooseView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    view.backgroundColor = TABLE_BG_COLOR;
    [self.view addSubview:view];
    
    CGFloat width = (kScreenWidth - 30)/2;
    UIView *autoView = [[UIView alloc] initWithFrame:CGRectMake(10, 74, width, 250)];
    autoView.backgroundColor = [UIColor whiteColor];
    autoView.layer.cornerRadius = 10;
    [view addSubview:autoView];
    
    UIImageView *autoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width / 2 - 35, 22, 70, 70)];
    autoImageView.image = [UIImage imageNamed:@"xuanzeduijiang_1"];
    [autoView addSubview:autoImageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, autoImageView.bottom + 20, width - 20, 80)];
    label.text = @"实物奖品兑奖（手机、电器、汽车）等物品，需到一币通品牌合作商家实体店取货";
    label.numberOfLines = 0;
    label.textColor = GREY_LABEL_COLOR;
    label.font = HGfont(12);
    label.textAlignment = NSTextAlignmentCenter;
    [autoView addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(width / 2 - 65, 250 - 14 - 48, 130, 48);
    [button setBackgroundImage:[UIImage imageNamed:@"xuanzeduijiang_anniu_1"] forState:UIControlStateNormal];
    [button setTitle:@"自助兑奖" forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    button.titleLabel.font = HGfont(14);
    [button addTarget:self action:@selector(autoButton) forControlEvents:UIControlEventTouchUpInside];
    [autoView addSubview:button];
    UITapGestureRecognizer *autoPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autoButton)];
    [autoView addGestureRecognizer:autoPress];
    
    UIView *conView = [[UIView alloc] initWithFrame:CGRectMake(10 + width + 10, 74, width, 250)];
    conView.backgroundColor = [UIColor whiteColor];
    conView.layer.cornerRadius = 10;
    [view addSubview:conView];
    
    UIImageView *conImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width / 2 - 35, 22, 70, 70)];
    conImageView.image = [UIImage imageNamed:@"xuanzeduijiang_6"];
    [conView addSubview:conImageView];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, autoImageView.bottom + 20, width - 20, 80)];
    label1.text = @"虚拟奖品兑奖（充值卡、代金券）请联系客服";
    label1.numberOfLines = 0;
    label1.textColor = GREY_LABEL_COLOR;
    label1.font = HGfont(12);
    label1.textAlignment = NSTextAlignmentCenter;
    [conView addSubview:label1];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(width / 2 - 65, 250 - 14 - 48, 130, 48);
    [button1 setBackgroundImage:[UIImage imageNamed:@"xuanzeduijiang_anniu_2"] forState:UIControlStateNormal];
    [button1 setTitle:@"联系客服兑奖" forState:UIControlStateNormal];
    [button1 setTintColor:[UIColor whiteColor]];
    button1.titleLabel.font = HGfont(14);
    UITapGestureRecognizer *conPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(conButton)];
    [conView addGestureRecognizer:conPress];
    [button1 addTarget:self action:@selector(conButton) forControlEvents:UIControlEventTouchUpInside];
    [conView addSubview:button1];
    
}

-(void)autoButton
{
    //确认收货。@{@"uid":用户ID，“mode”:(1:自助，2:客服)，“orderId”:订单ID}
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":self.userInfo[@"uid"],
                            @"mode":[NSString stringWithFormat:@"1"],
                            @"orderId":self.orderInfo[@"order"][@"id"]};
    [service POST:order_modeChange parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self _createView];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)conButton
{
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":self.userInfo[@"uid"],
                            @"mode":[NSString stringWithFormat:@"2"],
                            @"orderId":self.orderInfo[@"order"][@"id"]};
    [service POST:order_modeChange parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"联系客服" message:@"拨打客服热线：0577-85600011" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *certainAction = [UIAlertAction actionWithTitle:@"拨打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self callAction];
    }];
    [alertController addAction:certainAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)_createView
{
    for (int i = 0; i <= 5; i++) {
        if ([self.orderInfo[@"state"] integerValue] > i) {
            state[i] = @3;
        }else if ([self.orderInfo[@"state"] integerValue] == i) {
            state[i] = @2;
        }else{
            state[i] = @1;
        }
    }
    
    number = [self.orderInfo[@"state"] integerValue];
    
    UIView *bgScrollView = [[UIView alloc]init];
//    [self.view addSubview:bgScrollView];
    self.headerView  = bgScrollView;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, 30)];
    view.backgroundColor = [UIColor whiteColor];
    [bgScrollView addSubview:view];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UIFont *fnt = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    timeLabel.text =[NSString stringWithFormat: @"［第%@期］ ",self.dataInfo[@"qishu"]];
    timeLabel.font = [UIFont systemFontOfSize:14];
    timeLabel.textColor = [UIColor lightGrayColor];
    CGSize timeSize = [timeLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt,NSFontAttributeName, nil]];
    timeLabel.frame = CGRectMake(10, 8, timeSize.width, 14);
    [view addSubview:timeLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeSize.width + 20, 8, kScreenWidth - 20 - timeSize.width, 14)];
    titleLabel.text = [NSString stringWithFormat: @"%@",self.dataInfo[@"title"]];
    titleLabel.font = [UIFont systemFontOfSize:14];
    [view addSubview:titleLabel];
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 94, kScreenWidth, 100)];
    view1.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    [bgScrollView addSubview:view1];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    [imgView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@statics/uploads/%@",HOST_PATH,self.dataInfo[@"thumb"]]] placeholderImage:[UIImage imageNamed:@"shangpin_2.jpg"]];
    [view1 addSubview:imgView];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    UIFont *fnt1 = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
    label1.text = @"获奖帐号: ";
    label1.font = [UIFont systemFontOfSize:12];
    label1.textColor = [UIColor lightGrayColor];
    CGSize labelSize1 = [label1.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt1,NSFontAttributeName, nil]];
    label1.frame = CGRectMake(100, 20, labelSize1.width, 20);
    [view1 addSubview:label1];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(100 + labelSize1.width + 10, 20, kScreenWidth - 110 - labelSize1.width, 20)];
    contentLabel.text = [NSString stringWithFormat: @"%@",self.dataInfo[@"q_user"]];
    contentLabel.font = [UIFont systemFontOfSize:12];
    [view1 addSubview:contentLabel];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 40, contentLabel.frame.size.width, 20)];
    label2.text = @"本期参与:";
    label2.font = [UIFont systemFontOfSize:12];
    label2.textColor = [UIColor lightGrayColor];
    [view1 addSubview:label2];
    
    UILabel *contentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(100 + labelSize1.width + 10, 40, kScreenWidth - 110 - labelSize1.width, 20)];
    contentLabel2.text = [NSString stringWithFormat: @"%@人次",self.dataInfo[@"canyurenshu"]];
    contentLabel2.font = [UIFont systemFontOfSize:12];
    [view1 addSubview:contentLabel2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(100, 60, contentLabel.frame.size.width, 20)];
    label3.text = @"幸运号码:";
    label3.font = [UIFont systemFontOfSize:12];
    label3.textColor = [UIColor lightGrayColor];
    [view1 addSubview:label3];
    
    UILabel *contentLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(100 + labelSize1.width + 10, 60, kScreenWidth - 110 - labelSize1.width, 20)];
    contentLabel3.text = [NSString stringWithFormat: @"%@",self.dataInfo[@"q_user_code"]];
    contentLabel3.font = [UIFont systemFontOfSize:12];
    [view1 addSubview:contentLabel3];
    
    UIImageView *prizeView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 63, view1.frame.size.height / 2 - 18, 63, 36)];
    prizeView.image = [UIImage imageNamed:@"zhongjiangla"];
    [view1 addSubview:prizeView];
    
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0, 196, kScreenWidth, 40)];
    view3.backgroundColor = [UIColor whiteColor];
    [bgScrollView addSubview:view3];
    
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 70, 20)];
    stateLabel.text = @"奖品状态:";
    stateLabel.font = [UIFont systemFontOfSize:14];
    stateLabel.textColor = [UIColor lightGrayColor];
    [view3 addSubview:stateLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(stateLabel.width + 20, 10, kScreenWidth - stateLabel.width + - 20, 20);
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:[NSString stringWithFormat: @"%@",self.orderInfo[@"stateInfo"]] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft;
    [view3 addSubview:button];
    
    UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(0, 246, kScreenWidth, 40)];
    view4.backgroundColor = [UIColor whiteColor];
    [bgScrollView addSubview:view4];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 246, kScreenWidth - 20 , 40)];
    label.backgroundColor = [UIColor whiteColor];
    label.text = @"奖品跟踪";
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor lightGrayColor];
    [bgScrollView addSubview:label];
    
    bgScrollView.frame = CGRectMake(0, 0, kScreenWidth, 286);
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tag = 65;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.selectTableView = tableView;
    [self.view addSubview:tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 66)
    {
        return self.addressArr.count;
    }
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == 66) {
        KSKRoundCornerCell *cell =[KSKRoundCornerCell cellWithTableView:tableView style:UITableViewCellStyleDefault radius:8 indexPath:indexPath strokeLineWidth:1 strokeColor:TABLE_BG_COLOR];
        cell.backgroundColor = CELL_BG_COLOR;
        
        NSDictionary *address = self.addressArr[indexPath.row];
        
        UIImageView *checkImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, 20, 20)];
        if (self.selectedAddressRow == indexPath.row) {
            [checkImageView setImage:[UIImage imageNamed:@"xuanze_sel"]];
        }else{
            [checkImageView setImage:[UIImage imageNamed:@"xuanze_nor"]];
        }
        
        checkImageView.contentMode =  UIViewContentModeScaleAspectFit;
        [cell addSubview:checkImageView];
        
        UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(checkImageView.right + 10, 10, kScreenWidth - checkImageView.right - 10, 20)];
        addressLabel.text = address[@"shopname"];
        addressLabel.textColor = NORMAL_LABEL_COLOR;
        addressLabel.font = [UIFont systemFontOfSize:12];
        [cell addSubview:addressLabel];
        cell.tag = indexPath.row;
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 1, cell.height)];
    lineView.backgroundColor = CELL_BG_COLOR;
    [cell.contentView addSubview:lineView];
    
    UIImageView *pointView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 10, 10)];
    if ([state[indexPath.row] isEqual: @1]) {
        pointView.image = [UIImage imageNamed:@"20xuanze_sel"];
    }
    else if ([state[indexPath.row] isEqual: @2])
    {
        pointView.image = [UIImage imageNamed:@"12dian_sel"];
    }
    else
    {
        pointView.image = [UIImage imageNamed:@"12dian_nor"];
    }
    [cell.contentView addSubview:pointView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(pointView.right + 15, 20, 200, 12)];
    label.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:label];
    if (indexPath.row == 0) {
        label.text = @"恭喜你，中奖了";
    }
    if (indexPath.row == 1) {
        label.text = @"请选择商家";
        
        if (number == indexPath.row)
        {
            UITableView *addressTableView = [[UITableView alloc] initWithFrame:CGRectMake(label.left, label.bottom + 10, kScreenWidth - label.left - 10, 44 *4)];
            addressTableView.delegate = self;
            addressTableView.dataSource = self;
            addressTableView.tag = 66;
            [cell.contentView addSubview:addressTableView];
            
            
            UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
            selectButton.frame = CGRectMake(addressTableView.right - 126, addressTableView.bottom + 10, 126, 34);
            [selectButton setTitle:@"确 定" forState:UIControlStateNormal];
            selectButton.layer.cornerRadius = 17;
            [selectButton setBackgroundColor:HGColor(255, 153, 43)];
            [selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [selectButton addTarget:self action:@selector(selectButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:selectButton];
            
            cellSelectHeight = selectButton.bottom + 10;
        }
        else
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(label.left, label.bottom + 10, kScreenWidth - label.left - 10, 0)];
            view.backgroundColor = CELL_BG_COLOR;
            view.clipsToBounds = YES;
            view.layer.cornerRadius = 8;
            view.layer.borderColor = [TABLE_BG_COLOR CGColor];
            view.layer.borderWidth = 1.0;
            [cell.contentView addSubview:view];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
            [label1 setNumberOfLines:0];
            label1.text = [NSString stringWithFormat: @"%@",self.orderInfo[@"order"][@"businessName"]];
            UIFont *fnt = [UIFont fontWithName:@"HelveticaNeue" size:10.0f];
            label1.font = fnt;
            label1.textColor = [UIColor lightGrayColor];
            CGSize size1 = CGSizeMake(view.width - 70, 0);
            CGSize labelSize1 = [label1.text boundingRectWithSize:size1 options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:label1.font,NSFontAttributeName, nil] context:nil].size;
            label1.frame = CGRectMake(label.left + 15, 10, labelSize1.width, labelSize1.height);
            view.height = labelSize1.height + 20;
            [view addSubview:label1];
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50, 10)];
            label2.text = @"已选择：";
            label2.font = [UIFont systemFontOfSize:10];
            [view addSubview:label2];
            
            cellNormolHeight = view.height + 20 + 22 + 10;
        }
    }
    
    if (indexPath.row == 2) {
        label.text = @"支付1%公益金";
        
        if (number == indexPath.row) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(label.left, label.bottom + 10, kScreenWidth - label.left - 10, 86)];
            view.backgroundColor = CELL_BG_COLOR;
            view.clipsToBounds = YES;
            view.layer.cornerRadius = 3.0;
            view.layer.borderColor = [TABLE_BG_COLOR CGColor];
            view.layer.borderWidth = 1.0;
            [cell.contentView addSubview:view];
            
            UIImageView *wgyView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 13, 60, 60)];
            wgyView.image = [UIImage imageNamed:@"weigongyi"];
            [view addSubview:wgyView];
            UILabel *pLable = [[UILabel alloc] initWithFrame:CGRectZero];
            [pLable setNumberOfLines:0];
            
            pLable.text = [NSString stringWithFormat:@"您获得价值%@元，%@\n应支付%.2f元公益金",self.dataInfo[@"money"],self.dataInfo[@"title"],[self.dataInfo[@"money"] floatValue] * 0.01];
            UIFont *fnt = [UIFont fontWithName:@"HelveticaNeue" size:10.0f];
            pLable.font = fnt;
            pLable.textColor = [UIColor lightGrayColor];
            CGSize size1 = CGSizeMake(view.width - wgyView.width - 26.0 - 10,0);
            CGSize labelSize1 = [pLable.text boundingRectWithSize:size1 options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:pLable.font,NSFontAttributeName, nil] context:nil].size;
            pLable.frame = CGRectMake(wgyView.width + 26, view.height / 2 - labelSize1.height / 2, labelSize1.width, labelSize1.height);
            [view addSubview:pLable];
            
            UIButton *agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            agreeButton.frame = CGRectMake(view.left + 10, view.bottom + 8, 16, 16);
            [agreeButton setImage:[UIImage imageNamed:@"gou_nor"] forState:UIControlStateNormal];
            [agreeButton setImage:[UIImage imageNamed:@"gou_sel"] forState:UIControlStateSelected];
            [agreeButton addTarget:self action:@selector(agreenAction:) forControlEvents:UIControlEventTouchUpInside];
            agreeButton.tag = 77;
            [cell.contentView addSubview:agreeButton];
            
            
            UILabel *agreenLable = [[UILabel alloc] initWithFrame:CGRectMake(agreeButton.right + 5, agreeButton.top, view.width - 28, 16)];
            agreenLable.text = @"我已阅读并同意《支付1%公益金协议》";
            agreenLable.textColor = [UIColor lightGrayColor];
            agreenLable.font = [UIFont systemFontOfSize:10];
            [cell.contentView addSubview:agreenLable];
            UIButton *agreeLabelBtn = [[UIButton alloc]initWithFrame:agreenLable.frame];
            [agreeLabelBtn addTarget:self action:@selector(agreenAction:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *nowButton = [UIButton buttonWithType:UIButtonTypeCustom];
            nowButton.frame = CGRectMake(view.right - 126, agreenLable.bottom + 10, 126, 34);
            [nowButton setTitle:@"立即支付" forState:UIControlStateNormal];
            nowButton.layer.cornerRadius = 17;
            [nowButton setBackgroundColor:HGColor(255, 153, 43)];
            [nowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [nowButton addTarget:self action:@selector(nowAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:nowButton];
            cellSelectHeight = 196;
        }
        else if(number > indexPath.row){
            if ([state[indexPath.row]  isEqual: @1]) {
                cellNormolHeight = 50;
                return cell;
            }
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(label.left, label.bottom + 10, kScreenWidth - label.left - 10, 40)];
            view.backgroundColor = CELL_BG_COLOR;
            view.clipsToBounds = YES;
            view.layer.cornerRadius = 8;
            view.layer.borderColor = [TABLE_BG_COLOR CGColor];
            view.layer.borderWidth = 1.0;
            [cell.contentView addSubview:view];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view.width - 20, view.height)];
            label1.text = [NSString stringWithFormat:@"已成功支付%.2f元公益金",[self.dataInfo[@"money"] floatValue] * 0.01];
            label1.font = HGfont(10);
            [view addSubview:label1];
            cellNormolHeight = view.height + 52;
        }
    }
    if (indexPath.row == 3) {
        label.text = @"获取领奖码";
        if ([state[indexPath.row] isEqual:@1]) {
            cellNormolHeight = 50;
            return cell;
        }
        else
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(label.left, label.bottom + 10, kScreenWidth - label.left - 10, 40)];
            view.backgroundColor = CELL_BG_COLOR;
            view.clipsToBounds = YES;
            view.layer.cornerRadius = 8;
            view.layer.borderColor = [TABLE_BG_COLOR CGColor];
            view.layer.borderWidth = 1.0;
            [cell.contentView addSubview:view];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view.width - 20, view.height)];
            label1.text = [NSString stringWithFormat:@"领奖码：%@",self.orderInfo[@"order"][@"huode"]];
            label1.font = HGfont(10);
            [view addSubview:label1];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(view.left, view.bottom + 10, view.width, 30);
            [button setTitle:@"领奖码使用说明>>" forState:UIControlStateNormal];
            [button setTitleColor:navColor forState:UIControlStateNormal];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.titleLabel.font = HGfont(10);
            [cell.contentView addSubview:button];
            cellSelectHeight = view.height + 42 + 30;
        }
    }
    if (indexPath.row == 4) {
        label.text = @"待确认领取商品";
        if ([state[indexPath.row] isEqual:@2]) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(label.left, label.bottom + 10, kScreenWidth - label.left - 10, 40)];
            view.backgroundColor = CELL_BG_COLOR;
            view.clipsToBounds = YES;
            view.layer.cornerRadius = 8;
            view.layer.borderColor = [TABLE_BG_COLOR CGColor];
            view.layer.borderWidth = 1.0;
            [cell.contentView addSubview:view];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view.width - 20, view.height)];
            label1.text = [NSString stringWithFormat:@"商家已发奖品，签收人：%@\n已确认收到奖品",self.orderInfo[@"order"][@"receiver"]];
            label1.font = HGfont(10);
            [view addSubview:label1];
            
            UIButton *getPrizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            getPrizeButton.frame = CGRectMake(view.left, view.bottom + 10, 100, 30);
            [getPrizeButton setTitle:@"我已领取奖品" forState:UIControlStateNormal];
            getPrizeButton.titleLabel.font = HGfont(10);
            getPrizeButton.layer.cornerRadius = 15;
            [getPrizeButton setBackgroundColor:HGColor(255, 153, 43)];
            [getPrizeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [getPrizeButton addTarget:self action:@selector(getPrizeAction) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:getPrizeButton];
            cellNormolHeight = view.height + 42;
            
            UIButton *noPrizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            noPrizeButton.frame = CGRectMake(view.right - 100, view.bottom + 10, 100, 30);
            [noPrizeButton setTitle:@"未领取奖品" forState:UIControlStateNormal];
            noPrizeButton.titleLabel.font = HGfont(10);
            noPrizeButton.layer.cornerRadius = 15;
            [noPrizeButton setBackgroundColor:navColor];
            [noPrizeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [noPrizeButton addTarget:self action:@selector(noPrizeAction) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:noPrizeButton];
            cellSelectHeight = view.height + 52 + 40;
        }
        else
        {
            if ([state[indexPath.row] isEqual:@1]) {
                cellNormolHeight = 50;
                return cell;
            }
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(label.left, label.bottom + 10, kScreenWidth - label.left - 10, 60)];
            view.backgroundColor = CELL_BG_COLOR;
            view.clipsToBounds = YES;
            view.layer.cornerRadius = 8;
            view.layer.borderColor = [TABLE_BG_COLOR CGColor];
            view.layer.borderWidth = 1.0;
            [cell.contentView addSubview:view];
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view.width - 20, view.height)];
            label1.numberOfLines = 0;
            label1.text = [NSString stringWithFormat:@"商家 已发奖品，签收人：%@\n已确认收到奖品",self.orderInfo[@"order"][@"receiver"]];
            label1.font = HGfont(10);
            [view addSubview:label1];
            cellNormolHeight = view.height + 52;
        }
    }
    if (indexPath.row == 5) {
        label.text = @"晒单";
        if ([state[indexPath.row] isEqual:@1]) {
            cellNormolHeight = 50;
            return cell;
        }
        else
        {
            
            BOOL isShare = [self.orderInfo[@"order"][@"is_share"] integerValue] > 0 ? YES : NO;
            if (isShare) {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(label.left, label.bottom + 10, kScreenWidth - label.left - 10, 38)];
                view.backgroundColor = CELL_BG_COLOR;
                view.clipsToBounds = YES;
                view.layer.cornerRadius = 8;
                view.layer.borderColor = [TABLE_BG_COLOR CGColor];
                view.layer.borderWidth = 1.0;
                [cell.contentView addSubview:view];
                
                UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view.width - 20, view.height)];
                label1.text = @"查看晒单详情";
                [view addSubview:label1];
                label1.font = HGfont(14);
                UIImageView *rCionImageView = [[UIImageView alloc]initWithFrame:CGRectMake(view.width - 40, 11, 7, 14)];
                rCionImageView.image = [UIImage imageNamed:@""];
                [view addSubview:rCionImageView];
            }else{
                UILabel *labelMsg = [[UILabel alloc]initWithFrame:CGRectMake(label.left, label.bottom + 10, kScreenWidth - label.left - 10, 20)];
                labelMsg.text = @"晒单时请勿泄露领奖码信息";
                labelMsg.font = HGfont(12);
                [cell.contentView addSubview:labelMsg];
                
                UIButton *sdBtn = [[UIButton alloc]initWithFrame:CGRectMake(labelMsg.left, labelMsg.bottom + 10, 100, 36)];
                sdBtn.backgroundColor = ORANGE_LABEL_COLOR;
                [sdBtn setTitle:@"去晒单" forState:UIControlStateNormal];
                sdBtn.clipsToBounds = YES;
                [sdBtn addTarget:self action:@selector(sdBtnPress) forControlEvents:UIControlEventTouchUpInside];
                sdBtn.layer.cornerRadius = sdBtn.height / 2.0;
                [cell.contentView addSubview:sdBtn];
                cellSelectHeight = sdBtn.bottom + 20;
            }
            
        }
    }
    
    return cell;
}

-(void)sdBtnPress{
    ShaiDanTableViewController *vc = [[UIStoryboard storyboardWithName:@"Mine" bundle:nil]instantiateViewControllerWithIdentifier:@"ShaiDanTableViewControllerID"];
    vc.title = @"发布晒单";
    vc.orderId = self.orderInfo[@"order"][@"id"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 66) {
        return 44;
    }
    else
    {
        if (indexPath.row == 0)
        {
            return 50;
        }
        
        else if (indexPath.row == 1)
        {
            if (number == 1)
            {
                return cellSelectHeight;
            }
            return cellNormolHeight;
        }
        else if (indexPath.row == 2)
        {
            if (number == 2)
            {
                return cellSelectHeight;
            }
            return cellNormolHeight;
        }
        else if (indexPath.row == 3)
        {
            if ([state[indexPath.row] isEqual:@1])
            {
                return cellNormolHeight;
            }
            return cellSelectHeight;
        }
        
        else if (indexPath.row == 4)
        {
            if ([state[indexPath.row] isEqual:@1])
            {
                return 50;
            }
            return cellSelectHeight;
        }
        else
        {
            if ([state[indexPath.row] isEqual:@2])
            {
                return cellSelectHeight;
            }
            return cellNormolHeight;
        }
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == 66)
    {
        return 1;
    }
    return 286;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 65)
    {
//        number = indexPath.row;
//        [tableView reloadData];
    }
    else
    {
        self.selectedAddressRow = indexPath.row;
        [tableView reloadData];
    }
}

-(void)agreenAction:(UIButton *)btn
{
    btn.selected = !btn.selected;
}

-(void)nowAction:(UIButton *)btn
{
    UIButton * button = (UIButton *)[self.view viewWithTag:77];
    
    //立即支付
    if (button.selected)
    {
        [self selectedBtn];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"需要您先阅读并同意《支付1%公益金协议》"];
        return;
        
    }
}

-(void)selectedBtn{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"支付方式" message:[NSString stringWithFormat:@"您需支付%.2f公益金",[self.dataInfo[@"money"] floatValue] * 0.01] delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确认支付", nil];
    alert.tag = 88;
    [alert show];
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
    _userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    
    IapppayOrderUtils *orderInfo = [[IapppayOrderUtils alloc] init];
    orderInfo.appId         = mOrderUtilsAppId;
    orderInfo.cpPrivateKey  = mOrderUtilsCpPrivateKey;
    orderInfo.notifyUrl     = mOrderUtilsNotifyurl;
    orderInfo.cpOrderId     = cpOrderId;
    orderInfo.waresId       = @"2";
    orderInfo.price         = [NSString stringWithFormat:@"%.2f",_payMoney];
    orderInfo.appUserId     = _userInfo[@"uid"];
    orderInfo.waresName     = [NSString stringWithFormat:@"1%%公益金"]
    ;
    orderInfo.cpPrivateInfo = [NSString stringWithFormat:@"1%%公益金(%.2f)",_payMoney];
    
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
    [self payWelfare];
    
    // 调用支付成功
}
//支付宝、微信支付失败
- (void)payFail {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"支付失败" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    alert.tag = 33;
    [alert show];
}

-(void)payWelfareByBalance{
    [SVProgressHUD showWithStatus:@"正在支付订单！"];
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"orderId":self.orderInfo[@"order"][@"id"],
                            @"orderCode":self.orderInfo[@"order"][@"code"],
                            @"uid":self.userInfo[@"uid"],
                            @"SessionId":self.userInfo[@"SessionId"]};
    [service POST:order_payWelfareByBalance parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] integerValue] == 1) {
            [self loadOrder];
            [SVProgressHUD showSuccessWithStatus:@"支付成功!"];
        }else if ([responseObject[@"status"] integerValue] == 2) {
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"您的通币不足" message:@"使用其他支付方式？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去支付", nil];
            alertView.tag = 99;
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)payWelfare{
    [SVProgressHUD showWithStatus:@"正在支付订单！"];
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"orderId":self.orderInfo[@"order"][@"id"],
                            @"sn":_orderSn,
                            @"uid":self.userInfo[@"uid"],
                            @"SessionId":
                                self.userInfo[@"SessionId"]};
    [service POST:order_payWelfare parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self loadOrder];
        [SVProgressHUD showSuccessWithStatus:@"支付成功!"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)payWelfareAction{
    [SVProgressHUD showWithStatus:@"正在支付订单！"];
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"orderId":self.orderInfo[@"order"][@"id"],
                            @"uid":self.userInfo[@"uid"],
                            @"SessionId":
                                self.userInfo[@"SessionId"]};
    [service POST:order_payWelfareAction parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        _orderSn = responseObject[@"sn"];
        _payMoney = [responseObject[@"third_money"] floatValue];
//        _payMoney = 0.01;
        [self payByLapppay];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)getPrizeAction
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"确定领取商品" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 77;
    [alertView show];
}

-(void)noPrizeAction
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 278, 264)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 20;
    [[KGModal sharedInstance] showWithContentView:view andAnimated:YES];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(view.width - 16, - 16, 32, 32);
    [button setImage:[UIImage imageNamed:@"guanbi"] forState:UIControlStateNormal];
    button.layer.cornerRadius = 16;
    [button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, view.width - 60, view.height - 90)];
    label.numberOfLines = 0;
    label.text =  [NSString stringWithFormat:@"您好！\n奖品跟踪信息上提示商家奖品已发，签收人：%@\n\n如您本人未收到奖品，请拨打一币通客服电话为您解决！",self.orderInfo[@"order"][@"receiver"]];
    label.font = HGfont(14);
    
    [view addSubview:label];
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(30, view.height - 30 - 40, view.width - 60, 40)];
    buttonView.backgroundColor = navColor;
    buttonView.layer.cornerRadius = 20;
    [view addSubview:buttonView];
    
    UIImageView *mobileView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 8, 24, 24)];
    mobileView.image = [UIImage imageNamed:@"dianhua"];
    [buttonView addSubview:mobileView];
    
    UILabel *telNum = [[UILabel alloc] initWithFrame:CGRectMake(mobileView.right + 9, 0, view.width - 9 - mobileView.width - 20, 40)];
    telNum.text = @"0577-86669911";
    telNum.textColor = [UIColor whiteColor];
    telNum.font = HGfont(18);
    [buttonView addSubview:telNum];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callAction)];
    tap.numberOfTapsRequired = 1;
    [buttonView addGestureRecognizer:tap];
    
}

-(void)callAction
{
    //联系客服
    NSString *callNum = @"0577-85600011";
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",callNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

-(void)closeAction:(UIButton *)btn
{
    [[KGModal sharedInstance ] hide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    if ([self.selectTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.selectTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.selectTableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.selectTableView setLayoutMargins:UIEdgeInsetsZero];
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
-(void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
}

@end
