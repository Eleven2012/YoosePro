//
//  BindEmailController.h
//  Yoosee
//
//  Created by guojunyi on 14-4-26.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ALERT_TAG_BIND_EMAIL_AFTER_INPUT_PASSWORD 0
@class  MBProgressHUD;
@interface BindEmailController : UIViewController<UIAlertViewDelegate>
@property (nonatomic, strong) UITextField *field1;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@end
