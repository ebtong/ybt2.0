//
//  UploadImageView.h
//  Beauty
//
//  Created by HuangXiuJie on 15/3/18.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerHeader.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "ZImageBrowser.h"
@interface UploadImageView : UIView<UIActionSheetDelegate,ELCImagePickerControllerDelegate,UIImagePickerControllerDelegate,ZImageBrowserDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *desciptLabel;
@property (nonatomic, strong) NSMutableArray *chosenImages;
@property (nonatomic, strong) NSMutableArray *allImages;

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) NSMutableArray *fileUrlArray;
@property (nonatomic, strong) UIViewController *vc;
@property (nonatomic, assign) NSInteger existChosenImagesCount;

@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) NSInteger imageCol;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addBtnTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addBtnLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addBtnWidth;


-(void)createChosenImagesArray;
@end
