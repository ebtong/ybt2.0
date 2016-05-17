//
//  UserService.h
//  MobileSheild
//
//  Created by HuangXiuJie on 15/3/28.
//  Copyright (c) 2015年 瑞安市灵犀网络技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "Global.h"

typedef void (^successBlock)(void);
typedef void (^success)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^unLogin)(void);
typedef void (^failure)(AFHTTPRequestOperation *operation, NSError *error);
@interface HttpService : NSObject
@property (nonatomic,strong) AFHTTPRequestOperationManager *manager;
+ (instancetype)getInstance;
- (void)POST:(NSString *)actionStr parameters:(NSDictionary *)parameters success:(success)success failure:(failure)failure;
@end
