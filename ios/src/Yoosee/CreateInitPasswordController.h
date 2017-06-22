//
//  CreateInitPasswordController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-26.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;
@class MBProgressHUD;
@interface CreateInitPasswordController : UIViewController<UITextFieldDelegate>//password strength1
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UITextField *contactNameField;
@property (strong, nonatomic) UITextField *contactPasswordField;
@property (strong, nonatomic) UITextField *confirmPasswordField;

@property (retain, nonatomic) NSString *contactId;

@property (strong, nonatomic) NSString *lastSetPassword;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property (strong, nonatomic) NSString *address;
@property (nonatomic) BOOL isPopRoot;
@property (strong,nonatomic) NSString *contactIp;//added a code here

@property(strong, nonatomic) UIView *pwdStrengthView;//password strength1

@end
