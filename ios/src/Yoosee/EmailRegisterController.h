//
//  EmailRegisterController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-23.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ALERT_TAG_REGISTER_SUCCESS 0
@class MBProgressHUD;
@class LoginController;
@interface EmailRegisterController : UIViewController<UIAlertViewDelegate>
@property (nonatomic, strong) UITextField *field1;
@property (nonatomic, strong) UITextField *field2;
@property (nonatomic, strong) UITextField *field3;
@property (nonatomic, strong) LoginController *loginController;

@property (strong, nonatomic) MBProgressHUD *progressAlert;
@end
