//
//  BuyGoodsView.m
//  一币通购
//
//  Created by 少蛟 周 on 16/4/19.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "BuyGoodsView.h"
#import "PayViewController.h"
#import "SVProgressHUD.h"


@implementation BuyGoodsView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self =[super initWithFrame:frame]) {
        [self loadView];
    }
    
    return self;
}

-(void)loadDataById:(NSString *)goodsId{
    self.goodsId = goodsId;
    
    HttpService *service = [HttpService getInstance];
    NSDictionary *param = @{@"goods_id":self.goodsId};
    [service POST:goods_goodsDetail parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.goodsInfo = responseObject;
        [self reloadView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)reloadView{
    _count = [_numField.text integerValue];
    if (self.goodsInfo[@"jfenInfo"] && [self.goodsInfo[@"jfenInfo"][@"times"] integerValue] < _count) {
        _numField.text = [NSString stringWithFormat:@"%@",self.goodsInfo[@"jfenInfo"][@"times"]];
        _count = [_numField.text integerValue];
    }
    
    if ([self.goodsInfo[@"shenyurenshu"] integerValue] < _count) {
        _numField.text = [NSString stringWithFormat:@"%@",self.goodsInfo[@"shenyurenshu"]];
    }
    _count = [_numField.text integerValue];
    if (self.selectedBtn.tag != _count) {
        [self.selectedBtn setTitleColor:GREY_LABEL_COLOR forState:UIControlStateNormal];
        self.selectedBtn.backgroundColor = CELL_BG_COLOR;
    }else{
        self.selectedBtn.backgroundColor = [UIColor whiteColor];
        [self.selectedBtn setTitleColor:NORMAL_LABEL_COLOR forState:UIControlStateNormal];
    }
    
    if ([self.goodsInfo[@"cateid"] integerValue] == 147) {
        _numLabel.text = [NSString stringWithFormat:@"共%ld通豆",(long)_count * [self.goodsInfo[@"jfenInfo"][@"limit_num"]integerValue]];
    }else{
        _numLabel.text = [NSString stringWithFormat:@"共%.2f通币",_count * [self.goodsInfo[@"yunjiage"] floatValue]];
    }
    
}

-(void)loadView{
    self.backgroundColor = [UIColor whiteColor];
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 34)];
    titleView.backgroundColor = CELL_BG_COLOR;
    [self addSubview:titleView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:titleView.bounds];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = HGColor(102, 102, 102);
    titleLabel.text = @"请选择人次";
    [titleView addSubview:titleLabel];
    
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.width - 10 - 20, 7, 20, 20)];
    [closeBtn setImage:[UIImage imageNamed:@"lijigoumai_guanbi"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnPress) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:closeBtn];

    UIView *numView = [[UIView alloc]initWithFrame:CGRectMake(34, titleView.bottom + 20, self.width - 34 * 2, 40)];
    numView.clipsToBounds = YES;
    numView.layer.cornerRadius = 6;
    [self addSubview:numView];
    _numField = [[UITextField alloc]initWithFrame:CGRectMake(46, 0, numView.width - 46 * 2, numView.height)];
    
    _numField.text = @"5";
    _numField.textAlignment = NSTextAlignmentCenter;
    _numField.textColor = NORMAL_LABEL_COLOR;
//    _numField.keyboardType = UIKeyboardTypePhonePad;
    _numField.userInteractionEnabled = NO;
    [numView addSubview:_numField];
    
    UIButton *subtractBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 46, numView.height)];
    [subtractBtn setImage:[UIImage imageNamed:@"jian"] forState:UIControlStateNormal];
    [subtractBtn addTarget:self action:@selector(subtractButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    subtractBtn.backgroundColor = TABLE_BG_COLOR;
    [numView addSubview:subtractBtn];
    
    
    UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(numView.width - 46, 0, 46, numView.height)];
    addBtn.backgroundColor = TABLE_BG_COLOR;
    [addBtn setImage:[UIImage imageNamed:@"jia"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    numView.layer.borderColor = [TABLE_BG_COLOR CGColor];
    numView.layer.borderWidth = 1.0;
    [numView addSubview:addBtn];
    
    CGFloat btnWidth = (self.width - 34 * 2 + 10) / 4 - 10;
    for (int i = 0; i < 4; i++) {
        UIButton *numBtn = [[UIButton alloc]initWithFrame:CGRectMake(34 + i * (btnWidth + 10), numView.bottom + 15, btnWidth, 29)];
        NSInteger num = i * 10;
        
        if (i == 0) {
            num = 5;
            _selectedBtn = numBtn;
            numBtn.backgroundColor = [UIColor whiteColor];
            [numBtn setTitleColor:NORMAL_LABEL_COLOR forState:UIControlStateNormal];
        }else{
            [numBtn setTitleColor:GREY_LABEL_COLOR forState:UIControlStateNormal];
            numBtn.backgroundColor = CELL_BG_COLOR;
        }
        
        numBtn.layer.borderWidth = 1.0;
        numBtn.layer.borderColor = [TABLE_BG_COLOR CGColor];
        NSString *numStr = [NSString stringWithFormat:@"%ld",(long)num];
        numBtn.clipsToBounds = YES;
        numBtn.layer.cornerRadius = 14.5;
        numBtn.tag = num;
        numBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [numBtn addTarget:self action:@selector(numBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [numBtn setTitle:numStr forState:UIControlStateNormal];
        [self addSubview:numBtn];
    }
    
    UIButton *submitBtn = [[UIButton alloc]initWithFrame:CGRectMake(34, numView.bottom + 15 + 29 + 60, self.width - 34 * 2, 40)];
    submitBtn.backgroundColor = RED_BTN_COLOR;
    submitBtn.clipsToBounds = YES;
    submitBtn.layer.cornerRadius = 20;
    [submitBtn setTitle:@"确 定" forState:UIControlStateNormal];
    [submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:submitBtn];
    
    _numLabel = [[UILabel alloc]init];
    _numLabel.bounds = CGRectMake(0, 0,self.width - 34 * 2, 20);
    _numLabel.center = CGPointMake(self.width / 2,  submitBtn.top - 20);
    
    _numLabel.text = [NSString stringWithFormat:@"共%ld通币",(long)_count];
    _numLabel.font = [UIFont systemFontOfSize:14];
    _numLabel.textColor = HGColor(102, 102, 102);
    _numLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_numLabel];
    
    _BGView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_BGView];
    _BGView.backgroundColor = HGolorAlpha(0, 0, 0, 0.5);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBtnPress)];
    [_BGView addGestureRecognizer:tap];
    _BGView.hidden = NO;
}

-(void)closeBtnPress{
    [self removeFromSuperview];
    _BGView.hidden = YES;
    UIView *bottomView= [[UIApplication sharedApplication].keyWindow viewWithTag:9999];
    bottomView.hidden = NO;
}

-(void)hide{
    [self removeFromSuperview];
    _BGView.hidden = YES;
    UIView *bottomView= [[UIApplication sharedApplication].keyWindow viewWithTag:9999];
    [bottomView removeFromSuperview];
    bottomView = nil;
}

- (void)submitBtnAction:(UIButton *)sender {
    NSMutableArray *buyGoddsArray = [NSMutableArray array];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"info"] = self.goodsInfo;
    dict[@"num"] = [NSNumber numberWithInteger:_count];
    [buyGoddsArray addObject:dict];
    [self hide];
    PayViewController *vc = [[PayViewController alloc] init];
    vc.listArray = buyGoddsArray;
    vc.title = @"选择支付方式";
    [_Bvc.navigationController pushViewController:vc animated:YES];
}

- (void)numBtnAction:(UIButton *)sender {
    [self.selectedBtn setTitleColor:GREY_LABEL_COLOR forState:UIControlStateNormal];
    self.selectedBtn.backgroundColor = CELL_BG_COLOR;
    
    sender.backgroundColor = [UIColor whiteColor];
    [sender setTitleColor:NORMAL_LABEL_COLOR forState:UIControlStateNormal];
    _numField.text = [NSString stringWithFormat:@"%ld",(long)sender.tag];
    
    self.selectedBtn = sender;
    [self reloadView];
}

- (void)subtractButtonAction:(UIButton *)sender {
    NSInteger num = [_numField.text integerValue];
    num--;
    if (num < 1) {
        num = 1;
    }
    _numField.text = [NSString stringWithFormat:@"%ld",(long)num];
    [self reloadView];
}

- (void)addButtonAction:(UIButton *)sender {
    NSInteger num = [_numField.text integerValue];
    num++;
    _numField.text = [NSString stringWithFormat:@"%ld",(long)num];
    [self reloadView];
}


@end
