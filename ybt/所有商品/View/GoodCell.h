//
//  goodCollectionViewCell.h
//  一币通购
//
//  Created by mac on 16/4/12.
//  Copyright © 2016年 duobao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *allCountImageView;
@property (weak, nonatomic) IBOutlet UILabel *allcountLabel;
@property (weak, nonatomic) IBOutlet UILabel *subCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;
@property (weak, nonatomic) IBOutlet UIButton *carButton;

@property(strong, nonatomic)NSDictionary *dic;

- (IBAction)addCarAction:(UIButton *)sender;
@end
