//
//  AccountController.h
//  Yoosee
//
//  Created by guojunyi on 14-4-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ALERT_TAG_UNBIND_EMAIL 0
#define ALERT_TAG_UNBIND_EMAIL_AFTER_INPUT_PASSWORD 1

#define ALERT_TAG_UNBIND_PHONE 2
#define ALERT_TAG_UNBIND_PHONE_AFTER_INPUT_PASSWORD 3
@class MBProgressHUD;
@interface AccountController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property (strong, nonatomic) UITableView *tableView;
@end
