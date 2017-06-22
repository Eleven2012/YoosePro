//
//  NewRegisterController.h
//  Yoosee
//
//  Created by Jie on 14/12/6.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBProgressHUD;
@class LoginController;

@interface NewRegisterController : UIViewController

@property (assign) NSInteger registerType;

@property (strong, nonatomic) UIView *mainView1;
@property (strong, nonatomic) UIView *mainView2;

@property (strong,nonatomic) UILabel *leftLabel;
@property (strong,nonatomic) UILabel *rightLabel;
@property (strong,nonatomic) LoginController *loginController;

@property (nonatomic, strong) UITextField *field1;
@property (nonatomic, strong) UITextField *emailField1;
@property (nonatomic, strong) UITextField *emailField2;
@property (nonatomic, strong) UITextField *emailField3;
@property (strong, nonatomic) MBProgressHUD *progressAlert;

@property (strong,nonatomic) NSString *countryCode;
@property (strong,nonatomic) NSString *countryName;

@end
