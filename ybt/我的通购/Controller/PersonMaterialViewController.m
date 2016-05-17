//
//  PersonMaterialViewController.m
//  一币通购
//
//  Created by mac on 16/4/13.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "PersonMaterialViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ForgetPasswordViewController.h"
#import "SVProgressHUD.h"

@interface PersonMaterialViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UITextField *nameField;
    UILabel *sexLable;
    UITableView *tableView;
}

@end

@implementation PersonMaterialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavItem];
    [self _createView];
    // Do any additional setup after loading the view.
}

-(void)_createView
{
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = TABLE_BG_COLOR;
    [self.view addSubview:tableView];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"perCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"perCell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    for (id subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    if (indexPath.section == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 60, 12)];
        label.text = @"个人头像";
        label.font = HGfont(12);
        [cell.contentView addSubview:label];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 54, 5, 44, 44)];
        imageView.layer.cornerRadius = 22;
        imageView.clipsToBounds = YES;
        NSString *str = [NSString stringWithFormat:@"http://m.ybt999.com/statics/uploads/%@",dic[@"img"]];
        NSURL *url = [NSURL URLWithString:str];
        [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Default diagram_Small"]];
        [cell.contentView addSubview:imageView];
        
    }
    if (indexPath.section == 1) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 25, 12)];
        label.text = @"昵称";
        label.font = HGfont(12);
        [cell.contentView addSubview:label];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(label.right + 5, 10, 1, 22)];
        lineView.backgroundColor = TABLE_BG_COLOR;
        [cell.contentView addSubview:lineView];
        
        nameField = [[UITextField alloc] initWithFrame:CGRectMake(lineView.right + 5, 16, 200, 12)];
        nameField.text = dic[@"username"];
        nameField.font = HGfont(12);
        nameField.delegate = self;
        nameField.textColor = NORMAL_LABEL_COLOR;
        [cell.contentView addSubview:nameField];
        
    }
    if (indexPath.section == 2) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 25, 12)];
        label.text = @"性别";
        label.font = HGfont(12);
        [cell.contentView addSubview:label];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(label.right + 5, 10, 1, 22)];
        lineView.backgroundColor = TABLE_BG_COLOR;
        [cell.contentView addSubview:lineView];
        
        sexLable = [[UILabel alloc] initWithFrame:CGRectMake(lineView.right + 5, 16, 200, 12)];
        sexLable.text = dic[@"sex"];
        sexLable.font = HGfont(12);
        sexLable.textColor =NORMAL_LABEL_COLOR;
        [cell.contentView addSubview:sexLable];
    }
    if (indexPath.section == 3) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 16, 200, 12)];
        label.text = @"修改密码";
        label.font = HGfont(12);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.contentView addSubview:label];
    }
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 54;
    }
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 5;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 3) {
        ForgetPasswordViewController *vc = [[ForgetPasswordViewController alloc] init];
        vc.title = @"修改密码";
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.section == 2){
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女",nil];
        sheet.tag = 2;
        [sheet showInView:[[UIApplication sharedApplication] keyWindow]];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    NSString *username = textField.text;
    if(username.length == 0){
        return YES;
    }

    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":dic[@"uid"],
                            @"SessionId":dic[@"SessionId"],
                            @"username":username};
    [service POST:user_profileChange parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"修改成功"];
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"userInfo"];
        nameField.text = username;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];

    return YES;
}

//点击选取or从本机相册选择的ActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    NSString *sexStr = @"";
    if (0 == buttonIndex) {
        sexStr = @"男";
    } else if (1 == buttonIndex){
        sexStr = @"女";
    }
    
    if(sexStr.length == 0){
        return;
    }
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":dic[@"uid"],
                            @"SessionId":dic[@"SessionId"],
                            @"sex":sexStr};
    [service POST:user_profileChange parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"修改成功"];
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"userInfo"];
        sexLable.text = sexStr;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
}

//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [nameField resignFirstResponder];
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
