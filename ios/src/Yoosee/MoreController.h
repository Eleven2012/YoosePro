//
//  MoreController.h
//  Yoosee
//
//  Created by gwelltime on 15-1-16.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#define ALERT_TAG_EXIT 0
#define ALERT_TAG_LOGOUT 1
#define ALERT_TAG_UPDATE 2

@interface MoreController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,MBProgressHUDDelegate>

@property (strong, nonatomic) UIImageView *ic_net_type_view;
@property (strong, nonatomic) UIView *aboutView;

@end
