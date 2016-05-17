//
//  HeadViewCollectionReusableView.m
//  0元夺宝
//
//  Created by mac on 16/3/30.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "HeadViewCollectionReusableView.h"
#import "InviteFriendsViewController.h"
#import "PrizeViewController.h"
#import "ShoppingRecordViewController.h"
#import "LogInViewController.h"
#import "SVProgressHUD.h"
#import "SettingViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AccountDetailViewController.h"
#import "ShowListViewController.h"
#import "PayDetailViewController.h"
#import "TaskCenterTableViewController.h"

@implementation HeadViewCollectionReusableView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self =[super initWithFrame:frame]) {
        _buttonNames = @[@"中奖商品",@"通购记录",@"我的晒单",@"任务中心",@"邀请有奖",@"在线客服",@"账户明细",@"招募合伙人"];
        _buttonImgs = @[@"zhongjiang",@"tonggou",@"shaidan",@"renwu",@"yaoqing",@"kefu",@"qianbao",@"zhaomo"];
        [self _createView];
    }
    return self;
}

-(void)_createView
{
    [self _createHeadView];
    [self _createGrageView];
    [self _createButtonView];
    [self _createScrollerView];
    [self _createCollectionView];
    
}

-(void)reloadCView{
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    NSURL *headStr = [CommonUtil getImageNsUrl:userInfo[@"img"]];
    if ([userInfo[@"img"] isEqualToString:@"photo/member.jpg"]) {
        if ([userInfo[@"headimg"] length] > 0) {
            headStr = [NSURL URLWithString:userInfo[@"headimg"]];
        }else{
            headStr = nil;
        }
    }
    [_headImageView setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"touxiang"]];
    
    NSString *userName = userInfo[@"username"];
    if (userName) {
        _nameLable.text = [NSString stringWithFormat:@"%@",userName];
    } else if (userInfo[@"mobile"]) {
        _nameLable.text = [NSString stringWithFormat:@"%@",userInfo[@"mobile"]];
    }else{
        _nameLable.text = @"未登录";
    }
    
    if (userInfo) {
        _starLable.text = [NSString stringWithFormat:@"经验:%ld",[userInfo[@"jianyan"] integerValue]];
    }
    if (userInfo[@"score"]) {
        _beanCount.text = userInfo[@"score"];
    } else {
        _beanCount.text = @"0";
    }

    if (userInfo[@"money"]) {
        _coinCount.text = userInfo[@"money"];
    } else {
        _coinCount.text = @"0";
    }
    
    _jewelleryCount.text = @"0";
}

-(void)_createHeadView
{
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 219)];
    headView.image = [UIImage imageNamed:@"beijing"];
    headView.userInteractionEnabled = YES;
    [self addSubview:headView];
    
//    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    messageButton.frame = CGRectMake(kScreenWidth - 36, 40 + 11, 26, 22);
//    [messageButton setBackgroundImage:[UIImage imageNamed:@"xiaoxi_nor"] forState:UIControlStateNormal];
//    [messageButton addTarget:self action:@selector(messageAction) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:messageButton];
    
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingButton.frame = CGRectMake(kScreenWidth - 33, 40 + 10.5, 23, 23);
    [settingButton setBackgroundImage:[UIImage imageNamed:@"shezhi"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingButton];
    
    UIImageView *headView1 = [[UIImageView alloc] initWithFrame:CGRectMake(30, 70, 60, 80)];
    [self addSubview:headView1];
    headView1.userInteractionEnabled = YES;
    
    UIImageView *rankImageView = [[UIImageView alloc] initWithFrame:CGRectMake(headView1.bounds.size.width / 2 - 8.5, headView1.bounds.size.height - 25, 19, 25)];
    rankImageView.image = [UIImage imageNamed:@"zuanshi"];
    [headView1 addSubview:rankImageView];
    
    UIImageView *backGroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    backGroundImageView.backgroundColor = [UIColor whiteColor];
    backGroundImageView.alpha = 0.3;
    [backGroundImageView.layer setCornerRadius:30];
    [headView1 addSubview:backGroundImageView];
    
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(headView1.bounds.size.width / 2 - 28, 2, 56, 56)];
    _headImageView.layer.cornerRadius = 28.0;
    _headImageView.clipsToBounds = YES;
    NSURL *headStr = [CommonUtil getImageNsUrl:userInfo[@"img"]];
    if ([userInfo[@"img"] isEqualToString:@"photo/member.jpg"]) {
        if ([userInfo[@"headimg"] length] > 0) {
            headStr = [NSURL URLWithString:userInfo[@"headimg"]];
        }else{
            headStr = nil;
        }
    }
    [_headImageView setImageWithURL:headStr placeholderImage:[UIImage imageNamed:@"touxiang"]];
    _headImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImagePress:)];
    [_headImageView addGestureRecognizer:tapPress];
    [headView1 addSubview:_headImageView];
    
    _nameLable = [[UILabel alloc] initWithFrame:CGRectMake(headView1.frame.origin.x + 70, headView1.frame.origin.y + 12, kScreenWidth - 100, 20)];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    if (userName) {
        _nameLable.text = userName;
    } else {
        NSString *telNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"telNum"];
        _nameLable.text = telNum;
    }
    _nameLable.font = [UIFont systemFontOfSize:14];
    _nameLable.textAlignment = NSTextAlignmentLeft;
    _nameLable.textColor = [UIColor whiteColor];
    [headView addSubview:_nameLable];
    
    _starLable = [[UILabel alloc] initWithFrame:CGRectMake(headView1.frame.origin.x + 70, headView1.frame.origin.y + 36, kScreenWidth - 100, 18)];
    _starLable.text = @"经验:0";
    _starLable.font = [UIFont systemFontOfSize:12];
    _starLable.textAlignment = NSTextAlignmentLeft;
    _starLable.alpha = 0.6;
    _starLable.textColor = [UIColor whiteColor];
    [headView addSubview:_starLable];
    
    UIView *moneyView = [[UIView alloc] initWithFrame:CGRectMake(0, 179, kScreenWidth, 40)];
    moneyView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [headView addSubview:moneyView];
    
    CGFloat lableWidth = kScreenWidth / 3;
    _beanCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, lableWidth, 14)];
    _beanCount.font = [UIFont systemFontOfSize:14];
    _beanCount.textAlignment = NSTextAlignmentCenter;
    
    if (userInfo[@"score"]) {
        _beanCount.text = userInfo[@"score"];
    } else {
        _beanCount.text = 0;
    }
    _beanCount.textColor = [UIColor whiteColor];
    [moneyView addSubview:_beanCount];
    
    UILabel *beanLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, lableWidth, 11)];
    beanLable.font = [UIFont systemFontOfSize:11];
    beanLable.textAlignment = NSTextAlignmentCenter;
    beanLable.text = @"通豆";
    beanLable.textColor = [UIColor whiteColor];
    [moneyView addSubview:beanLable];
    
    _coinCount = [[UILabel alloc] initWithFrame:CGRectMake(lableWidth, 6, lableWidth, 14)];
    _coinCount.font = [UIFont systemFontOfSize:14];
    _coinCount.textAlignment = NSTextAlignmentCenter;
    if (userInfo[@"money"]) {
        _coinCount.text = userInfo[@"money"];
    } else {
        _coinCount.text = 0;
    }
    _coinCount.textColor = [UIColor whiteColor];
    [moneyView addSubview:_coinCount];
    
    UILabel *coinLable = [[UILabel alloc] initWithFrame:CGRectMake(lableWidth, 23, lableWidth, 11)];
    coinLable.font = [UIFont systemFontOfSize:11];
    coinLable.textAlignment = NSTextAlignmentCenter;
    coinLable.text = @"通币";
    coinLable.textColor = [UIColor whiteColor];
    [moneyView addSubview:coinLable];
    
    _jewelleryCount = [[UILabel alloc] initWithFrame:CGRectMake(lableWidth * 2, 6, lableWidth, 14)];
    _jewelleryCount.font = [UIFont systemFontOfSize:14];
    _jewelleryCount.textAlignment = NSTextAlignmentCenter;
    _jewelleryCount.text = @"0";
    _jewelleryCount.textColor = [UIColor whiteColor];
    [moneyView addSubview:_jewelleryCount];
    
    UILabel *jewelleryLable = [[UILabel alloc] initWithFrame:CGRectMake(lableWidth * 2, 23, lableWidth, 11)];
    jewelleryLable.font = [UIFont systemFontOfSize:11];
    jewelleryLable.textAlignment = NSTextAlignmentCenter;
    jewelleryLable.text = @"幸运宝石";
    jewelleryLable.textColor = [UIColor whiteColor];
    [moneyView addSubview:jewelleryLable];
}

-(void)headImagePress:(id)sender{
    for (UIView* next = [self superview]; next; next =
         next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                          class]])
        {
            BaseViewController *baseC =  (BaseViewController *)nextResponder;
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]) {
                LogInViewController *vc = [[LogInViewController alloc] init];
                vc.title = @"登陆";
                UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
                [baseC.navigationController presentViewController:nvc animated:YES completion:nil];
                return;
            }
        }
    }
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄图片",@"图片选择",nil];
    [sheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

//点击选取or从本机相册选择的ActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (0 == buttonIndex) {
        [self takeOrSelectPhoto:UIImagePickerControllerSourceTypeCamera];
    } else if (1 == buttonIndex){
        [self takeOrSelectPhoto:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
}

- (void)takeOrSelectPhoto:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.mediaTypes = mediaTypes;
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    
    for (UIView* next = [self superview]; next; next =
         next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                          class]])
        {
            BaseViewController *baseC =  (BaseViewController *)nextResponder;
            [baseC.navigationController presentViewController:picker animated:YES completion:nil];
        }
    }
}
//用户上传照片-取消操作
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //    最原始的图
    UIImage *image = info[UIImagePickerControllerEditedImage];
    //    先减半传到服务器
    UIImage *imageOriginal = [CommonUtil shrinkImage:image toSize:CGSizeMake(0.3*image.size.width, 0.3*image.size.height)];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *urlstr = [NSString stringWithFormat:@"%@/%@",HOST_URL,user_changeTou];
        NSDictionary *param = @{@"uid":userInfo[@"uid"],
                                @"SessionId":userInfo[@"SessionId"]};
        [manager POST:urlstr parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(imageOriginal,0.8) name:@"Filedata" fileName:@"something.jpg" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([[responseObject objectForKey:CODE_STRING] isEqualToNumber:SUCCESS_CODE]) {
                [SVProgressHUD showSuccessWithStatus:@"上传头像成功"];
                
            } else if ([[responseObject objectForKey:CODE_STRING] isEqualToNumber:FAILURE_CODE]) {
                //                    unLogin();
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[responseObject objectForKey:@"message"] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[[UIAlertView alloc]initWithTitle:@"上传失败" message:@"网络故障，请稍后重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }];
    }];
}

-(void)_createGrageView
{
    UIView *gradeView = [[UIView alloc] initWithFrame:CGRectMake(0, 229, kScreenWidth, 76)];
    gradeView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [gradeView addGestureRecognizer:tap];
    [self addSubview:gradeView];
    
    UILabel *growNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, 70, 10)];
    growNum.text = @"成长值100%";
    growNum.textColor = [UIColor grayColor];
    growNum.font = [UIFont systemFontOfSize:10];
    growNum.textAlignment = NSTextAlignmentRight;
    [gradeView addSubview:growNum];
    
    UIImageView *growB = [[UIImageView alloc] initWithFrame:CGRectMake(80, 16, 156.0 / 375.0 * kScreenWidth, 6)];
    growB.backgroundColor = GREEN_BG_COLOR;
    growB.layer.cornerRadius = 3;
    [gradeView addSubview:growB];
    
    UIImageView *growF = [[UIImageView alloc] initWithFrame:CGRectMake(80, 15, 80, 8)];
    UIImage *growFImg = [UIImage imageNamed:@"chengzhangzh_sel"];
    [growF setImage:[growFImg stretchableImageWithLeftCapWidth:7 topCapHeight:0]];
    [gradeView addSubview:growF];
    
    UILabel *heartNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, 70, 10)];
    heartNum.text = @"爱心值30%";
    heartNum.textColor = [UIColor grayColor];
    heartNum.font = [UIFont systemFontOfSize:10];
    heartNum.textAlignment = NSTextAlignmentRight;
    [gradeView addSubview:heartNum];
    
    UIImageView *heatB = [[UIImageView alloc] initWithFrame:CGRectMake(80, 36, 156.0 / 375.0 * kScreenWidth, 6)];
    heatB.backgroundColor = HGColor(252, 223, 228);
    heatB.layer.cornerRadius = 3;
    [gradeView addSubview:heatB];
    
    UIImageView *heartF = [[UIImageView alloc] initWithFrame:CGRectMake(80, 35, 50, 8)];
    UIImage *heartFImg = [UIImage imageNamed:@"aixinzhi_sel@2x"];
    [heartF setImage:[heartFImg stretchableImageWithLeftCapWidth:7 topCapHeight:0]];
    [gradeView addSubview:heartF];
    
    UILabel *luckNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 54, 70, 10)];
    luckNum.text = @"幸运值3%";
    luckNum.textColor = [UIColor grayColor];
    luckNum.font = [UIFont systemFontOfSize:10];
    luckNum.textAlignment = NSTextAlignmentRight;
    [gradeView addSubview:luckNum];
    
    UIImageView *luckB = [[UIImageView alloc] initWithFrame:CGRectMake(80, 56, 156.0 / 375.0 * kScreenWidth,6)];
    luckB.backgroundColor = ORANGE_BG_COLOR;
    luckB.layer.cornerRadius = 3;
    [gradeView addSubview:luckB];
    
    UIImageView *luckF = [[UIImageView alloc] initWithFrame:CGRectMake(80, 55, 30, 8)];
    UIImage *luckFImg = [UIImage imageNamed:@"xinyun_sel"];
    [luckF setImage:[luckFImg stretchableImageWithLeftCapWidth:7 topCapHeight:0]];
    [gradeView addSubview:luckF];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(156.0 / 375.0 * kScreenWidth + 70 + 29, 0, 0.5, 76)];
    line.backgroundColor = TABLE_BG_COLOR;
    [gradeView addSubview:line];
    
    UIView *rankView = [[UIView alloc] initWithFrame:CGRectMake(156.0 / 375.0 * kScreenWidth + 70 + 30, 0, kScreenWidth - (156.0 / 375.0 * kScreenWidth + 70 + 30), 76)];
    rankView.backgroundColor = [UIColor whiteColor];
    [gradeView addSubview:rankView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(rankView.bounds.size.width / 2 - 12.5, 15, 25, 19)];
    imageView.image = [UIImage imageNamed:@"haoyou"];
    [rankView addSubview:imageView];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, rankView.bounds.size.height - 27, rankView.bounds.size.width, 12)];
    lable.text = @"我的排名";
    lable.textColor = [UIColor lightGrayColor];
    lable.font = [UIFont systemFontOfSize:12];
    lable.textAlignment = NSTextAlignmentCenter;
    [rankView addSubview:lable];
    
}

-(void)_createButtonView
{
    CGFloat buttonWidth = kScreenWidth / 4;
    for (int i = 0; i<_buttonNames.count; i++)
    {
        if (i < 4)
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.userInteractionEnabled = NO;
            [button setImage:[UIImage imageNamed:_buttonImgs[i]] forState:UIControlStateNormal];
            button.tag = 40 + i;
            [view addSubview:button];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            if (self.width >= 375) {
                view.frame = CGRectMake(i * buttonWidth, 310, buttonWidth, 80);
                button.frame = CGRectMake(view.bounds.size.width /2 - 15, 13, 30, 30);
                label.frame = CGRectMake(0, view.frame.size.height - 27 , view.frame.size.width, 12);
            }
            else
            {
                view.frame = CGRectMake(i * buttonWidth, 310, buttonWidth, 70);
                button.frame = CGRectMake(view.bounds.size.width /2 - 15, 8, 30, 30);
                label.frame = CGRectMake(0, view.frame.size.height - 22 , view.frame.size.width, 12);
            }
            view.backgroundColor = [UIColor whiteColor];
            view.tag = 140 + i;
            [self addSubview:view];
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonAction:)];
            [view addGestureRecognizer:tapGes];
        
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor lightGrayColor];
            label.text = _buttonNames[i];
            label.font = [UIFont systemFontOfSize:12];
            [view addSubview:label];
        }
        else
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.userInteractionEnabled = NO;
            [button setImage:[UIImage imageNamed:_buttonImgs[i]] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            if (self.width >= 375) {
                view.frame = CGRectMake((i - 4) * buttonWidth, 310 + 80.5, buttonWidth, 80);
                button.frame = CGRectMake(view.bounds.size.width /2 - 15, 13, 30, 30);
                label.frame = CGRectMake(0, view.frame.size.height - 27 , view.frame.size.width, 12);
            }
            else
            {
                view.frame = CGRectMake((i - 4) * buttonWidth, 310 + 70.5, buttonWidth, 70);
                button.frame = CGRectMake(view.bounds.size.width /2 - 15, 8, 30, 30);
                label.frame = CGRectMake(0, view.frame.size.height - 22 , view.frame.size.width, 12);
            }

            view.tag = 140 + i;
            view.backgroundColor = [UIColor whiteColor];
            [self addSubview:view];
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonAction:)];
            [view addGestureRecognizer:tapGes];
        
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor lightGrayColor];
            label.text = _buttonNames[i];
            label.font = [UIFont systemFontOfSize:12];
            [view addSubview:label];
            
            if (i == 4) {
                UIImageView *smallPointImgView = [[UIImageView alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width, 10, 8, 8)];
                smallPointImgView.image = [UIImage imageNamed:@"xiaoxidian"];
                [view addSubview:smallPointImgView];
            }
        }
    }
}

-(void)_createScrollerView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    if (self.width >= 375) {
        view.frame = CGRectMake(0, 475.5, kScreenWidth, 152.0 / 750.0 *kScreenWidth);
    }
    else
    {
        view.frame = CGRectMake(0, 455.5, kScreenWidth, 152.0 / 750.0 *kScreenWidth);
    }
#pragma mark - 创建scrollview
    _scrollerView = [[UIScrollView alloc]initWithFrame:view.bounds];
    _scrollerView.contentSize = CGSizeMake(kScreenWidth*1, 60);
    
    //设置代理
    _scrollerView.delegate = self;
    _scrollerView.pagingEnabled = YES;
    _scrollerView.showsHorizontalScrollIndicator = NO;
    for (int i= 1; i<2;i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((i-1)*kScreenWidth, 0, kScreenWidth, 152.0 / 750.0 *kScreenWidth)];
        imageView.image = [UIImage imageNamed:@"element"];
        [_scrollerView addSubview:imageView];
    }
    [view addSubview:_scrollerView];
    [self addSubview:view];
#pragma mark - 创建PageControl
    _pageC = [[UIPageControl alloc]initWithFrame:CGRectMake(0, view.bounds.size.height-10, kScreenWidth, 10)];
    
    _pageC.numberOfPages = 1;
    _pageC.backgroundColor = [UIColor clearColor];
    
    _pageC.currentPage = 0;
    _pageC.currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageC.pageIndicatorTintColor = [UIColor grayColor];
    [_pageC addTarget:self action:@selector(pageCon:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:_pageC];
}

-(void)_createCollectionView
{
    CGFloat height ;
    if (self.width >= 375) {
        height = 152.0 / 750.0 *kScreenWidth + 455.5 + 20 + 20;
    }
    else
    {
        height = 152.0 / 750.0 *kScreenWidth + 455.5 + 20;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 16, height, 48, 12)];
    label.text = @"猜你喜欢";
    label.font = [UIFont systemFontOfSize:12];
    [self addSubview:label];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, label.center.y, (kScreenWidth - 48 - 12 - 4) / 2 - 8, 1)];
    line1.backgroundColor = HGColor(200, 200, 200);
    [self addSubview:line1];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(label.left - 4 - 12, label.center.y - 5, 12, 10)];
    imageView.image = [UIImage imageNamed:@"xihuan"];
    [self addSubview:imageView];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake( label.right + 8, label.center.y,  kScreenWidth - label.right - 8, 1)];
    line2.backgroundColor = HGColor(200, 200, 200);
    [self addSubview:line2];
}

-(void)pageCon:(UIPageControl *)sender
{
    NSInteger index = sender.currentPage;
    
    CGFloat contentOffSetX = index*kScreenWidth;
    
    CGPoint off = CGPointMake(contentOffSetX, 0);
    [_scrollerView setContentOffset:off];
}

#pragma mark -结束减速
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //
    CGFloat offX = scrollView.contentOffset.x;
    
    NSInteger index = offX/kScreenWidth;
    
    _pageC.currentPage = index;
}





#pragma mark -按钮方法
-(void)buttonAction:(id)sender
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    NSInteger num = [tap view].tag - 140;
    for (UIView* next = [self superview]; next; next =
         next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                         class]])
        {
            BaseViewController *baseC =  (BaseViewController *)nextResponder;
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]) {
                LogInViewController *vc = [[LogInViewController alloc] init];
                vc.title = @"登陆";
                UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
                [baseC.navigationController presentViewController:nvc animated:YES completion:nil];
                return;
            }
            
            if (num == 4)
            {
                InviteFriendsViewController *vc = [[InviteFriendsViewController alloc] init];
                vc.title = @"邀请有奖";
                [baseC.navigationController pushViewController:vc animated:YES];
            }
            else if (num == 3)
            {
                TaskCenterTableViewController *vc = [[UIStoryboard storyboardWithName:@"Mine" bundle:nil]instantiateViewControllerWithIdentifier:@"TaskCenterTableViewControllerID"];
                baseC.hidesBottomBarWhenPushed = YES;
                [baseC.navigationController pushViewController:vc animated:YES];
                baseC.hidesBottomBarWhenPushed = NO;
            }
            else if (num == 0)
            {
                PrizeViewController *vc = [[PrizeViewController alloc] init];
                vc.title = @"中奖商品";
                [baseC.navigationController pushViewController:vc animated:YES];
            }
            else if (num == 1)
            {
                ShoppingRecordViewController *vc = [[ShoppingRecordViewController alloc] init];
                vc.title = @"通购记录";
                [baseC.navigationController pushViewController:vc animated:YES];
            }
            else if (num == 2)
            {
                ShowListViewController *vc = [[ShowListViewController alloc] init];
                vc.title = @"晒单分享";
                [baseC.navigationController pushViewController:vc animated:YES];
            }
            else if (num == 6)
            {
                AccountDetailViewController *vc = [[AccountDetailViewController alloc ]init];
                vc.title = @"账户明细";
                baseC.hidesBottomBarWhenPushed = YES;
                [baseC.navigationController pushViewController:vc animated:YES];
                baseC.hidesBottomBarWhenPushed = NO;
            }
            else if (num == 5)
            {

                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"联系客服" message:@"拨打客服热线：0577-85600011" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];

                UIAlertAction *certainAction = [UIAlertAction actionWithTitle:@"拨打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self callAction];
                }];
                [alertController addAction:certainAction];
                [baseC presentViewController:alertController animated:YES completion:nil];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"暂无此功能，待后续开发"];
            }
        }
        
    }
}


-(void)settingAction
{
    for (UIView* next = [self superview]; next; next =
         next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController
                                          class]])
        {
            BaseViewController *baseC =  (BaseViewController *)nextResponder;
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"]) {
                LogInViewController *vc = [[LogInViewController alloc] init];
                vc.title = @"登陆";
                UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
                [baseC.navigationController presentViewController:nvc animated:YES completion:nil];
                return;
            }
            SettingViewController *vc = [[SettingViewController alloc] init];
            vc.title = @"设置";
            [baseC.navigationController pushViewController:vc animated:YES];
        }
        
    }
}

-(void)callAction
{
    //联系客服
    NSString *callNum = @"0577-85600011";
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",callNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

-(void)messageAction
{
    [SVProgressHUD showErrorWithStatus:@"暂无此功能，待后续开发"];
}

-(void)tapAction
{
    [SVProgressHUD showErrorWithStatus:@"暂无此功能，待后续开发"];
}


@end
