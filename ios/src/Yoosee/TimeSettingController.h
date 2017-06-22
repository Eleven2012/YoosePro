//
//  TimeSettingController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
@class Contact;
@class MyPickerView;
@class TimezoneView;
@interface TimeSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong, nonatomic) Contact *contact;
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) MyPickerView *picker;
@property(assign) BOOL isInitTime;
@property(strong, nonatomic) NSString *time;
@property(nonatomic) DeviceDate lastSetDate;



@property (nonatomic) NSInteger timezone;
@property (nonatomic) NSInteger lastSetTimezone;
@property (nonatomic) BOOL isInitTimezone;
@property (nonatomic) BOOL isSupportTimezone;

@property (nonatomic) NSInteger tempTimezone;
@end
