//
//  TureNameTableViewController.m
//  一币通购
//
//  Created by mac on 16/4/13.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "TureNameTableViewController.h"
#import "ThemeButton.h"
#import "SVProgressHUD.h"

@interface TureNameTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *realnameTextF;
@property (weak, nonatomic) IBOutlet UITextField *IDCardTextF;
@property (strong, nonatomic) NSDictionary *userInfo;

@end

@implementation TureNameTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavItem];
    self.view.backgroundColor = TABLE_BG_COLOR;
    _infoButton.layer.cornerRadius = 15;
    _infoButton.clipsToBounds = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    [self loadData];
}

-(void)loadData{
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"]) {
        return;
    }
    _userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"userInfo"];
    _realnameTextF.text = [NSString stringWithFormat:@"%@",_userInfo[@"true_name"]];
    _IDCardTextF.text = [NSString stringWithFormat:@"%@",_userInfo[@"ID_num"]];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}



- (IBAction)infoButtonAction:(UIButton *)sender {
    if (_realnameTextF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请填写真实姓名！"];
        return;
    }
    if (_IDCardTextF.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请填写身份证号码！"];
        return;
    }
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"uid":_userInfo[@"uid"],
                            @"SessionId":
                                _userInfo[@"SessionId"],
                            @"realName":
                                _realnameTextF.text,
                            @"cardNum":
                                _IDCardTextF.text};
    [service POST:user_updateProfile parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"修改成功"];
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"userInfo"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
@end
