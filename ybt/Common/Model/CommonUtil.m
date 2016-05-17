//
//  CommonUtil.m
//  0元夺宝
//
//
//  Copyright © 2016年 duobao. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil

/**
 * 手机版本约束差异 宽度
 * @return  YES/NO
 */
+ (CGFloat)getVersionWidth{
    CGFloat app_width = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        app_width = 16;
    }
    return app_width;
}

+(NSURL *)getImageNsUrl:(NSString *)url{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@statics/uploads/%@",HOST_PATH,url]];
}

// 将字典或者数组转化为JSON串
+ (NSString *)getJSONStr:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString * jsonString = nil;
    if ([jsonData length] > 0 && error == nil){
        jsonString = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
    
}

//图片缩放
+ (UIImage *)shrinkImage:(UIImage *)original toSize:(CGSize)size
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


/**
 *验证邮箱
 * @param NSString email
 * @return BOOL YES/NO
 */
+ (BOOL)isValidateEmail:(NSString *)email {
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *Regex = @"^(\\w)+(\\.\\w+)*@(\\w)+((\\.\\w+)+)$";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",Regex];
    if (![test evaluateWithObject:email]) {
        return NO;
    }
    return YES;
}

/**
 *验证手机
 * @param NSString mobile
 * @return BOOL YES/NO
 */
+ (BOOL)isValidateMobile:(NSString *)mobile {
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(17[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    if (![phoneTest evaluateWithObject:mobile]) {
        return NO;
    }
    return YES;
}

/**
 * 修改label颜色，@“<c>”分割
 * @param colorArray 颜色数组
 * @param fontArray 字体数组
 * @return TYAttributedLabel
 */
+(TYAttributedLabel *)getLabel:(TYAttributedLabel *)label1 str:(NSString *)text color:(NSArray *)colorArray  font:(NSArray *)fontArray{
    [label1 setText:@""];
    NSArray *textArray = [text componentsSeparatedByString:@"<c>"];
//    NSLog(@"textArray:%@",textArray);
    NSInteger index = 0;
    for (NSString *text in textArray) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
        // 设置当前文本字体
        [attributedString addAttributeTextColor:colorArray[index%[colorArray count]]];
        
        if ([fontArray count] > 0) {
            NSInteger fontSize = [fontArray[index % [fontArray count]] integerValue];
            // 设置当前文本字体大小
            [attributedString addAttributeFont:[UIFont systemFontOfSize:fontSize]];
        }
//        NSLog(@"attributedString:%@",attributedString);
        // 追加(添加到最后)属性文本
        [label1 appendTextAttributedString:attributedString];
        index++;
    }
    return label1;
}


@end
