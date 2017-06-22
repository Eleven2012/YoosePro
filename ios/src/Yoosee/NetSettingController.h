//
//  NetSettingController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-19.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ALERT_TAG_NET_TYPE1 0
#define ALERT_TAG_NET_TYPE2 1
#define ALERT_TAG_CHANGE_WIFI 2
#define ALERT_TAG_INPUT_WIFI_PASSWORD 3
@class Contact;
@class RadioButton;
@class  MBProgressHUD;
@interface NetSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;

@property(assign) NSInteger netType;
@property(assign) NSInteger lastNetType;



@property(assign) BOOL isLoadingNetType;
@property(assign) BOOL isLoadingWifiList;

@property (strong,nonatomic) RadioButton *radioNetType1;
@property (strong,nonatomic) RadioButton *radioNetType2;


@property (assign) NSInteger currentWifiIndex;
@property (assign) NSInteger wifiCount;
@property (strong,nonatomic) NSMutableArray *names;
@property (strong,nonatomic) NSMutableArray *types;
@property (strong,nonatomic) NSMutableArray *strengths;

@property (assign) NSInteger selectWifiIndex;
@property (retain,nonatomic) NSString *lastSetWifiPassword;
@property (strong, nonatomic) MBProgressHUD *progressAlert;
@end
