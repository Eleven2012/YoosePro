//
//  ModifyLoginPasswordController.h
//  Yoosee
//
//  Created by guojunyi on 14-4-26.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBProgressHUD;

@interface ModifyLoginPasswordController : UIViewController
@property (nonatomic, strong) UITextField *field1;
@property (nonatomic, strong) UITextField *field2;
@property (nonatomic, strong) UITextField *field3;


@property (strong, nonatomic) MBProgressHUD *progressAlert;
@end
