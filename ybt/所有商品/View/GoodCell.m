//
//  goodCollectionViewCell.m
//  一币通购
//
//  Created by mac on 16/4/12.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "GoodCell.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"

@implementation GoodCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _allCountImageView.layer.cornerRadius = 3;

    
    NSString *urlStr = [NSString stringWithFormat:@"%@statics/uploads/%@",HOST_PATH,_dic[@"thumb"]];
    NSURL *url = [NSURL URLWithString:urlStr];
    [_goodImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Default diagram_Small"]];
    if ([_dic[@"cateid"] integerValue] == 147) {
        _smallImageView.image = [UIImage imageNamed:@"biaoqian"];
    }
    else
    {
        _smallImageView.image = [UIImage imageNamed:@"renqi"];
    }
    
    _titleLabel.text = _dic[@"title"];
    _contentLabel.text = _dic[@"title2"];
    if (_dic[@"canyurenshu"] != nil) {
        for (id view in [_allCountImageView subviews]) {
            [view removeFromSuperview];
        }
        CGFloat width = [_dic[@"canyurenshu"] floatValue] / [_dic[@"zongrenshu"]floatValue] * _allCountImageView.width;
        UIImageView *countImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 6)];
        
        [countImageView setBackgroundColor:HGColor(31, 189, 166)];
        countImageView.layer.cornerRadius = 3;
        [_allCountImageView addSubview:countImageView];
    }
    
    _allcountLabel.text =[NSString stringWithFormat:@"总需:%@",_dic[@"zongrenshu"]] ;
    
    _subCountLabel.text = [NSString stringWithFormat:@"剩余:%@",_dic[@"shenyurenshu"]];
    
}



- (IBAction)addCarAction:(UIButton *)sender
{
        if (!_dic) {
            [SVProgressHUD showErrorWithStatus:@"请等待数据加载后，再试！"];
            return;
        }
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"goodsInfo"] = _dic;
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addCartNotification" object:nil userInfo:userInfo];
}




@end
