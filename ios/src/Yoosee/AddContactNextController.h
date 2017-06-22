//
//  AddContactNextController.h
//  Yoosee
//
//  Created by guojunyi on 14-4-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  Contact;
@interface AddContactNextController : UIViewController<UITextFieldDelegate>//password strength
@property (strong, nonatomic) UITextField *contactNameField;//device name
@property (strong, nonatomic) UITextField *contactPasswordField;//device password
//多出的
@property (strong, nonatomic) UITextField *contactIdField;//device ID

@property (retain, nonatomic) NSString *contactId;

@property(strong, nonatomic) Contact *modifyContact;
@property (nonatomic) BOOL isModifyContact;
@property (nonatomic) BOOL isInFromLocalDeviceList;
@property (nonatomic) BOOL isInFromManuallAdd;
@property (nonatomic) BOOL isInFromQRCodeNextController;
@property (nonatomic) BOOL isPopRoot;

@property (nonatomic,assign) int inType;//多出的

@property(strong, nonatomic) UIView *pwdStrengthView;//password strength

@end
