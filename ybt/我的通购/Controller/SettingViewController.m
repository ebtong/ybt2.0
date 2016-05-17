//
//  SettingViewController.m
//  一币通购
//
//  Created by mac on 16/4/11.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "SettingViewController.h"
#import "SVProgressHUD.h"
#import "PersonMaterialViewController.h"
#import "TelNumTableViewController.h"
#import "TureNameTableViewController.h"
#import "IdeaViewController.h"
#import "AboutViewController.h"
#import "JPUSHService.h"


@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UILabel *_cacheLable;//缓存大小
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavItem];
    // Do any additional setup after loading the view.
    [self _createView];
}

-(void)_createView
{
    self.view.backgroundColor = HGColor(235, 235, 235);
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 80) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = HGColor(235, 235, 235);
    tableView.bounces = NO;
    [self.view addSubview:tableView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, kScreenHeight - 20 - 40, kScreenWidth - 40, 40);
    button.layer.cornerRadius = 20;
    [button setBackgroundColor:HGColor(255, 153, 43)];
    [button setTitle:@"退出登录" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    else return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = @[@"个人资料"/*,@"绑定号码"*/,@"实名认证",@"反馈与建议"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setCell"];
    if (!cell) {
        cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"setCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (id subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 150, 24)];
    label.font = HGfont(12);

    if (indexPath.section == 0) {
        label.text = arr[indexPath.row];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.height - 1, kScreenWidth, 1)];
        lineView.backgroundColor = HGColor(249, 249, 249);
        [cell.contentView addSubview:lineView];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 1)
    {
        label.text = @"清除缓存";
        _cacheLable = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 16 - 120, 16, 120, 12)];
        _cacheLable.text = [NSString stringWithFormat:@"%.2fMB",[self countCacheFileSize]];
        _cacheLable.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:_cacheLable];
    }
    
    else if (indexPath.section == 2)
    {
        label.text = @"接收新消息通知";
        UISwitch *sw = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 50 - 13, 10, 50, 24)];
//        BOOL swithIsOn = [[NSUserDefaults standardUserDefaults]boolForKey:@"NeedOrAutoWhenAccept"];
//        [sw setOn:swithIsOn animated:YES];
        [sw addTarget:self action:@selector(acceptAction:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:sw];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 46)];
        view.backgroundColor = TABLE_BG_COLOR;
        [cell.contentView addSubview:view];
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, kScreenWidth - 28, 44)];
//        label2.backgroundColor = TABLE_BG_COLOR;
        label2.numberOfLines = 0;
        label2.text = @"若关闭，当收到消息时，通知提示将不显示发信人和内容摘要";
        label2.textColor = HGColor(153, 153, 153);
        label2.font = HGfont(12);
        [view addSubview:label2];
    }
    else if (indexPath.section == 3)
    {
        label.text = @"关于我们";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [cell.contentView addSubview:label];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        return 90;
    }
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 8;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0)
        {
            PersonMaterialViewController *vc = [[PersonMaterialViewController alloc] init];
            vc.title = @"个人资料";
            [self.navigationController pushViewController:vc animated:YES];
        }
//        if (indexPath.row == 1) {
//            TelNumTableViewController * vc = [[UIStoryboard storyboardWithName:@"Mine" bundle:nil]instantiateViewControllerWithIdentifier:@"TelNumTableViewControllerID"];
//            vc.title = @"绑定手机";
//            [self.navigationController pushViewController:vc animated:YES];
//        }
        if (indexPath.row == 1) {
            TureNameTableViewController * vc = [[UIStoryboard storyboardWithName:@"Mine" bundle:nil]instantiateViewControllerWithIdentifier:@"TureNameTableViewControllerID"];
            vc.title = @"实名认证";
            [self.navigationController pushViewController:vc animated:YES];
        }
        if (indexPath.row == 2) {
            IdeaViewController * vc = [[IdeaViewController alloc] init];
            vc.title = @"反馈与建议";
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    if (indexPath.section == 1)
    {
        
            UIAlertView *alret = [[UIAlertView alloc]initWithTitle:@"警告" message:@"是否清除缓存" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
            alret.tag = 56;
            [alret show];
    }
    if (indexPath.section == 3) {
        AboutViewController *vc = [[AboutViewController alloc] init];
        vc.title = @"关于我们";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 56)
    {
        if (buttonIndex == 1) {
            //清理缓存
            [self cleanCacheFile];
        }
    }
}

-(void)cleanCacheFile
{
    _cacheLable.text = @"清理中...";
    //获取缓存文件的路径
    NSString *homePath = NSHomeDirectory();
    //2.删除文件
    NSArray *pathArray = @[@"/tmp/",@"/Library/Caches/",@"/Documents/"];
    
    for (NSString *string in pathArray) {
        //拼接路径
        NSString *filePath = [NSString stringWithFormat:@"%@%@",homePath,string];
        
        //文件管理
        NSFileManager *manager = [NSFileManager defaultManager];
        //获取子文件夹中的文件名
        NSArray *fileNames = [manager subpathsOfDirectoryAtPath:filePath error:nil];
        //遍历文件夹 删除文件
        for (NSString *fileName in fileNames) {
            //拼接子文件路径
            NSString *subFilePath = [NSString stringWithFormat:@"%@%@",filePath,fileName];
            //删除文件
            [manager removeItemAtPath:subFilePath error:nil];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _cacheLable.text = [NSString stringWithFormat:@"%.2fMB",[self countCacheFileSize]];
    });
}

-(CGFloat)countCacheFileSize{
    NSString *homePath = NSHomeDirectory();
    /*
     1)  子文件夹1： /tmp/
     2)  子文件夹2：  /Library/Caches/HLStudyLearn/
     3)  子文件夹3：/Documents/
     */
    NSArray *pathArray = @[@"/tmp/",@"/Library/Caches/",@"/Documents/"];
    
    CGFloat fileSize = 0;
    for (NSString *string in pathArray)
     {
        //拼接路径
        NSString *filePath = [NSString stringWithFormat:@"%@%@",homePath,string];
        fileSize += [self getFileSize:filePath];
    }
    return fileSize;
}

-(CGFloat)getFileSize:(NSString *)filePath
{
    
    //文件管理器 单例
    NSFileManager *manager = [NSFileManager defaultManager];
    //数组 储存文件夹中所有的子文件夹以及文件的名字
    NSArray *fileNames = [manager subpathsOfDirectoryAtPath:filePath error:nil];
    //遍历数组
    long long size = 0;
    for (NSString *fileName in fileNames) {
        //拼接获取文件的路径
        NSString *subFliePath = [NSString stringWithFormat:@"%@%@",filePath,fileName];
        //获取文件信息
        NSDictionary *dic = [manager attributesOfItemAtPath:subFliePath error:nil];
        NSNumber *sizeNumber = dic[NSFileSize];
        long long subFileSize = [sizeNumber longLongValue];
        size += subFileSize;
    }
    return size / 1024.0 /1024;
}
//接受新消息通知时实现的方法
-(void)acceptAction:(UISwitch *)sw
{
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
}

-(void)exitAction
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userInfo"];
    [SVProgressHUD showSuccessWithStatus:@"成功退出登录"];
    [self.navigationController popViewControllerAnimated:YES];
    [JPUSHService clearAllLocalNotifications];
}



@end
