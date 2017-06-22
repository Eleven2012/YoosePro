//
//  BindAlarmEmailController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;
@class  MBProgressHUD;
@class AlarmSettingController;
@class TableViewWithBlock;
@interface BindAlarmEmailController : UIViewController{
    BOOL isOpened;
}

@property (strong, nonatomic) AlarmSettingController *alarmSettingController;
@property (strong, nonatomic) NSString *lastSetBindEmail;
@property (strong, nonatomic) Contact *contact;
@property (strong, nonatomic) MBProgressHUD *progressAlert;

@property (nonatomic, strong) UITextField *field1;//delete
@property (nonatomic, strong) UITextField *smtpTextField;
@property (nonatomic, strong) UITextField *senderTextField;
@property (nonatomic, strong) UITextField *reciTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UIButton *dropDownBtn;
@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) TableViewWithBlock *tableView;
@property (nonatomic) BOOL isSystemDefaultEmail;
@property (nonatomic) BOOL isSelectEmailState;

@property (strong,nonatomic) NSArray *emailArray;

@end
