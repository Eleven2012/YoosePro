//
//  PhoneRegisterController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-23.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ALERT_TAG_REGISTER_SUCCESS 0
@class MBProgressHUD;
@class LoginController;
@interface PhoneRegisterController : UIViewController
@property (nonatomic, strong) UITextField *field1;
@property (nonatomic, strong) UITextField *field2;

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *phoneCode;

@property (nonatomic, strong) LoginController *loginController;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@end
