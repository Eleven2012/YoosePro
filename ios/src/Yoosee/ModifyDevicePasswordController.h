//
//  ModifyDevicePasswordController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;
@class MBProgressHUD;
@interface ModifyDevicePasswordController : UIViewController<UITextFieldDelegate>//password strength2
@property(strong, nonatomic) Contact *contact;
@property (nonatomic, strong) UITextField *field1;
@property (nonatomic, strong) UITextField *field2;
@property (nonatomic, strong) UITextField *field3;
@property (strong, nonatomic) NSString *lastSetOriginPassowrd;
@property (strong, nonatomic) NSString *lastSetNewPassowrd;
@property (strong, nonatomic) MBProgressHUD *progressAlert;

@property(strong, nonatomic) UIView *pwdStrengthView;//password strength2

@end
