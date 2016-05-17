//
//  UploadImageView.m
//  Beauty
//
//  Created by HuangXiuJie on 15/3/18.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import "UploadImageView.h"
#import "SVProgressHUD.h"
#import "HttpService.h"


@implementation UploadImageView

- (void)createImagesArray {
    
}

- (void)imageBroser:(ZImageBrowser *)broswer didTapImageAtIndex:(NSInteger)index {
    [broswer dismissViewControllerAnimated:YES completion:nil];
}

-(void)showImageBrower:(UIButton *)sender{
    
    ZImageBrowser *browser = [[ZImageBrowser alloc] init];
    [browser setCurrentIndex:sender.tag];
    browser.enableTapGesture = YES;
    browser.delegate = self;
    browser.doubleTapSclaeZoom = @(1.5);
    //    browser.maxDragScaleZoom = @(3.0);
    browser.images = self.allImages;
    [self.vc presentViewController:browser animated:YES completion:nil];
}

-(void)createChosenImagesArray{
    self.chosenImages = [NSMutableArray array];
    self.allImages = [NSMutableArray array];
    self.fileUrlArray = [NSMutableArray array];
    self.imageWidth = (SCREEN_WIDTH - 32)/4.0 - 10;
    self.addBtnWidth.constant = self.imageWidth;
    self.addBtnHeight.constant = self.imageWidth;
    self.addBtnTop.constant = 10;
    self.addBtnLeft.constant = 16;
}
- (IBAction)selectUploadSource:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [sheet showInView:self];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self selectFromAblum];
    } else if(buttonIndex == 0) {
        [self takePhoto];
    }
}

- (void)takePhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.vc presentViewController:picker animated:YES completion:NULL];
}

#pragma mark 选取照片操作之后的代理方法，即将图片置于ImageView中及赋值给image1等，并将回调的pid存于self.pidArray中。
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //    最原始的图
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //    先减半传到服务器
    CGFloat imageWidth = 800;
    CGFloat imageHeight = image.size.height / image.size.width * 800;
    UIImage *imageOriginal = [self shrinkImage:image toSize:CGSizeMake(imageWidth, imageHeight)];
    [self.allImages addObject:imageOriginal];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self reloadImagesList];
    }];
}

#pragma mark 从手机中选择
- (void)selectFromAblum {

       	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    
        elcPicker.maximumImagesCount = 6 - self.allImages.count; //Set the maximum number of images to select to 100
        elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
        elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
        elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
        elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types
        elcPicker.imagePickerDelegate = self;
        [self.vc presentViewController:elcPicker animated:YES completion:nil];
}


- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self.vc dismissViewControllerAnimated:YES completion:nil];

    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    int i = 0;

    for (NSDictionary *dict in info) {
        if(self.allImages.count + 1 > 6){
            [SVProgressHUD showErrorWithStatus:@"最多只能添加6张图片"];
            continue;
        }
        
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                CGFloat imageWidth = 800;
                CGFloat imageHeight = image.size.height / image.size.width * 800;
                UIImage *imageOriginal =[self shrinkImage:image toSize:CGSizeMake(imageWidth,imageHeight)];
                [images addObject:imageOriginal];
                [self.allImages addObject:imageOriginal];
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else {
            NSLog(@"Uknown asset type");
        }
        i++;
    }
    [self reloadImagesList];
    
    //                传完后，就自己清空，以免重复上传
//    [self.chosenImages removeAllObjects];
//    [self.chosenImages addObjectsFromArray:images];
//    self.imagesURL = imagesURL;
//    [self.containerView setPagingEnabled:YES];
//    [self.containerView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
//    [self uploadImages];
}

-(void)reloadImagesList{
    for (UIView *uv in [self.containerView subviews]) {
        [uv removeFromSuperview];
    }
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < self.allImages.count; i++) {
        UIImage *image= self.allImages[i];
        UIImage *imageOriginal = image;
        [images addObject:imageOriginal];
        
        UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
        [imageview setContentMode:UIViewContentModeScaleAspectFill];
        imageview.clipsToBounds = YES;
        
        NSInteger column = i % 4;
        NSInteger row = i / 4;
        CGRect frame = CGRectMake( (self.imageWidth + 10) * column + 16, (self.imageWidth + 10) * row + 10, self.imageWidth, self.imageWidth);
        imageview.frame = frame;
        [self.containerView addSubview:imageview];
        
        UIButton *showBtn = [[UIButton alloc]initWithFrame:frame];
        showBtn.tag = i;
        [showBtn addTarget:self action:@selector(showImageBrower:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:showBtn];
        
        UIButton *delBtn = [[UIButton alloc]initWithFrame:CGRectMake( (self.imageWidth + 10) * column + 16, (self.imageWidth + 10) * row + 10, 20, 20)];
        delBtn.tag = i;
        [delBtn setImage:[UIImage imageNamed:@"del.png"] forState:UIControlStateNormal];
        delBtn.backgroundColor = [UIColor clearColor];
        delBtn.layer.cornerRadius = 10.0;
        delBtn.clipsToBounds = YES;
        [delBtn addTarget:self action:@selector(delImage:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.containerView addSubview:delBtn];
    }
    self.existChosenImagesCount = self.allImages.count;
    
    NSInteger addx = self.allImages.count % 4;
    NSInteger addy = self.allImages.count / 4;
    self.addBtnTop.constant =  addy * (self.imageWidth + 10) + 10;
    self.addBtnLeft.constant = addx * (self.imageWidth + 10) + 16;
    [self.vc viewDidAppear:YES];
}

-(void)delImage:(UIButton *)sender{
    if (self.allImages[sender.tag]) {
        [self.allImages removeObjectAtIndex:sender.tag];
        [self reloadImagesList];
    }
    
}

- (void)uploadImages {
    [SVProgressHUD showWithStatus:@"正在上传..." maskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD dismiss];
//    for (int i = 0; i < self.chosenImages.count; i++) {
//        
//    }
}

#pragma mark 缩小图片
- (UIImage *)shrinkImage:(UIImage *)original toSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    CGFloat originalAspect = original.size.width / original.size.height;
    CGFloat targetAspect = size.width / size.height;
    CGRect targetRect;
    if (originalAspect > targetAspect) {
        // original is wider than target
        targetRect.size.width = size.width * originalAspect / targetAspect;
        targetRect.size.height = size.height;
        targetRect.origin.x = 0;
        targetRect.origin.y = (size.height - targetRect.size.height) * 0.5;
    } else if (originalAspect < targetAspect) {
        // original is narrower than target
        targetRect.size.width = size.width;
        targetRect.size.height = size.height * targetAspect / originalAspect;
        targetRect.origin.x = (size.width - targetRect.size.width) * 0.5;
        targetRect.origin.y = 0;
    } else {
        // original and target have same aspect ratio
        targetRect = CGRectMake(0, 0, size.width, size.height);
    }
    //    targetRect = CGRectMake(0, 0, .5*original.size.width, .5*original.size.height);
    [original drawInRect:targetRect];
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return final;
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self.vc dismissViewControllerAnimated:YES completion:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
