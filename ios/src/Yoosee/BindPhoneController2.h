//
//  BindPhoneController2.h
//  Yoosee
//
//  Created by guojunyi on 14-5-22.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ALERT_TAG_BIND_PHONEs_AFTER_INPUT_PASSWORD 0
@class  MBProgressHUD;
@class AccountController;
@class LoginController;
@interface BindPhoneController2 : UIViewController<UIAlertViewDelegate>
@property (strong,nonatomic) NSString *countryCode;
@property (strong,nonatomic) NSString *phoneNumber;

@property (nonatomic, strong) UITextField *field1;
@property (strong, nonatomic) MBProgressHUD *progressAlert;

@property (assign) BOOL isCanResend;

@property (strong,nonatomic) UILabel *resendLabel;
@property (strong,nonatomic) AccountController *accountController;
@property (strong,nonatomic) LoginController *loginController;
@property (assign) BOOL isRegister;
@end
