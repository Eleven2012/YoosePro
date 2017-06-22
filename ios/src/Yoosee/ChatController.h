//
//  ChatController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-29.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;
#define ALERT_TAG_CLEAR 0
@interface ChatController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) Contact *contact;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) UIButton *hideKeyBoardButton;
@property (strong, nonatomic) UITextField *messageField;
@end
