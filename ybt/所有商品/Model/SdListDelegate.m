//
//  SdListDelegate.m
//  ybt
//
//  Created by 少蛟 周 on 16/5/16.
//  Copyright © 2016年 少蛟 周. All rights reserved.
//

#import "SdListDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "KGModal.h"
#import "SVProgressHUD.h"

@implementation SdListDelegate
- (instancetype)initWithViewController:(GoodsDetailsTableViewController *)vc {
    if ([self init]) {
        self.vc = vc;
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (kScreenWidth - 65 - 20) / 3;
    return (165 + width);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    NSDictionary *dic = self.listArray[indexPath.row];
    UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 45, 45)];
    [headView setImageWithURL:[CommonUtil getImageNsUrl:dic[@"q_user_image"]] placeholderImage:[UIImage imageNamed:@"Default diagram_Small"]];
    headView.layer.cornerRadius = 22.5;
    headView.clipsToBounds = YES;
    [cell.contentView addSubview:headView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UIFont *fnt1 = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    nameLabel.text = [NSString stringWithFormat:@"%@",dic[@"q_user"]];
    nameLabel.textColor = HGColor(100, 160, 255);
    nameLabel.font = fnt1;
    CGSize labelSize1 = [nameLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:fnt1,NSFontAttributeName, nil]];
    nameLabel.frame = CGRectMake(65, 17, labelSize1.width, 15);
    [cell.contentView addSubview:nameLabel];
    
    UIImageView *rankView = [[UIImageView alloc] initWithFrame:CGRectMake(nameLabel.right + 11, 15, 19, 19)];
    rankView.image = [UIImage imageNamed:@"tongpai_1"];
    [cell.contentView addSubview:rankView];
    
    UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, nameLabel.bottom + 13, kScreenWidth - 65, 14)];
    dataLabel.font = HGfont(14);
    dataLabel.textColor = GREY_LABEL_COLOR;
    dataLabel.text = [NSString stringWithFormat:@"[%@期] %@",dic[@"qishu"],dic[@"title"]];
    [cell.contentView addSubview:dataLabel];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, dataLabel.bottom + 10, kScreenWidth - 65, 47)];
    contentLabel.font = HGfont(13);
    contentLabel.text = [NSString stringWithFormat:@"%@",dic[@"sd_content"]];
    contentLabel.numberOfLines = 3;
    [cell.contentView addSubview:contentLabel];
    
    CGFloat width = (kScreenWidth - 65 - 20) / 3;
    NSArray *arr = dic[@"imageArr"];
    for (int i = 0; i < arr.count; i++) {
        if ([arr[i] length] != 0) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(65 + i * (width + 5), contentLabel.bottom + 14, width, width)];
            [imageView setImageWithURL:[CommonUtil getImageNsUrl:arr[i]] placeholderImage:[UIImage imageNamed:@"Default diagram_Small"]];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.borderColor = [CELL_BG_COLOR CGColor];
            imageView.layer.borderWidth = 1;
            imageView.clipsToBounds = YES;
            [cell.contentView addSubview:imageView];
        }
    }
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, contentLabel.bottom + width + 28, 100, 10)];
    timeLabel.textColor = TABLE_BG_COLOR;
    timeLabel.text = [NSString stringWithFormat:@"%@",dic[@"sd_time"]];
    timeLabel.font = HGfont(10);
    [cell.contentView addSubview:timeLabel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //向vc的Label赋值
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
