//
//  ShaiDanTableViewController.m
//  ybt
//
//  Created by 少蛟 周 on 16/4/26.
//  Copyright © 2016年 少蛟 周. All rights reserved.
//

#import "ShaiDanTableViewController.h"
#import "SVProgressHUD.h"
#import "ThemeButton.h"

@interface ShaiDanTableViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *infoDefaultLabel;


@end

@implementation ShaiDanTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.submitBtn.layer.cornerRadius = 20.0;
    self.submitBtn.clipsToBounds = YES;
    [self createUploadView];
    self.infoTextView.delegate = self;
    [self setNavItem];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.infoDefaultLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text length] == 0) {
        self.infoDefaultLabel.hidden = NO;
    }
}

-(void)setNavItem
{
    //1.返回按钮
    ThemeButton *backButton = [[ThemeButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    backButton.normalImageName = @"fanhui";
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bakeItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:bakeItem];
    
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (void)createUploadView {
    //初始化view
    self.uploadImageView = [[[NSBundle mainBundle]loadNibNamed:@"Upload" owner:self options:nil]firstObject];
    self.uploadImageView.vc = self;
    self.uploadImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 300);
    [self.uploadImageView createChosenImagesArray];
    [self.imagesListView addSubview:self.uploadImageView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Return the number of sections.
    if (indexPath.row == 1) {
        NSInteger imageCount = self.uploadImageView.allImages.count;
        CGFloat imageWidth = self.uploadImageView.imageWidth;
        CGFloat height = (imageCount / 4 + 1) * (imageWidth + 10) + 10 ;
        return height;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


- (IBAction)submitBtnPress:(id)sender {
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"]) {
        
        return;
    }
    
    self.userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    if (self.infoTextView.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入内容！"];
        return;
    }
    if (self.uploadImageView.allImages.count <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请上传图片！"];
        return;
    }
    
    NSDictionary *param = @{@"uid":self.userInfo[@"uid"],
                            @"SessionId":self.userInfo[@"SessionId"],
                            @"orderId":self.orderId,
                            @"content":self.infoTextView.text};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [SVProgressHUD showWithStatus:@"正在上传图片" maskType:SVProgressHUDMaskTypeGradient];
    [manager POST:[NSString stringWithFormat:@"%@/%@",HOST_URL,user_shaidanCreate] parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i < self.uploadImageView.allImages.count; i++) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(self.uploadImageView.allImages[i],0.8) name:[NSString stringWithFormat:@"Filedata_%d",i] fileName:@"something.jpg" mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"code"] isEqualToNumber:@1]) {
            [SVProgressHUD showSuccessWithStatus:@"发布成功！"];
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([[responseObject objectForKey:@"code"] isEqualToNumber:@2]) {
            [SVProgressHUD dismiss];
            //                    unLogin();
        } else {
            [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[responseObject objectForKey:@"msg"] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [[[UIAlertView alloc]initWithTitle:@"上传失败" message:@"网络故障，请稍后重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


@end
