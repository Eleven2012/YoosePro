//
//  AlarmSettingController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P2PSwitchCell.h"
@class Contact;
@class RadioButton;
@class MBProgressHUD;
#define ALERT_TAG_UNBIND_ALARM_ID 0
@interface AlarmSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,SwitchCellDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;

@property(strong, nonatomic) UISwitch *alarmSwitch;
@property(strong, nonatomic) UISwitch *motionSwitch;
@property(strong, nonatomic) UISwitch *buzzerSwitch;
@property(strong, nonatomic) UISwitch *humanInfraredSwitch;
@property(strong, nonatomic) UISwitch *wiredAlarmInputSwitch;
@property(strong, nonatomic) UISwitch *wiredAlarmOutputSwitch;

@property (strong, nonatomic) RadioButton *radio1;
@property (strong, nonatomic) RadioButton *radio2;
@property (strong, nonatomic) RadioButton *radio3;

@property(assign) BOOL isFirstLoadingCompolete;
@property(assign) BOOL isLoadingAlarmState;
@property(assign) BOOL isLoadingBindId;
@property(assign) BOOL isLoadingBindEmail;
@property(assign) BOOL isLoadingMotionDetect;
@property(assign) BOOL isLoadingBuzzer;
@property(assign) BOOL isLoadingHumanInfrared;
@property(assign) BOOL isLoadingWiredAlarmInput;
@property(assign) BOOL isLoadingWiredAlarmOutput;

@property(assign) NSInteger alarmState;
@property(assign) NSInteger lastAlarmState;
@property(assign) NSInteger buzzerState;
@property(assign) NSInteger lastBuzzerState;
@property(assign) NSInteger motionState;
@property(assign) NSInteger lastMotionState;
@property(assign) NSInteger humanInfraredState;
@property(assign) NSInteger lastHumanInfraredState;
@property(assign) NSInteger wiredAlarmInputState;
@property(assign) NSInteger lastWiredAlarmInputState;
@property(assign) NSInteger wiredAlarmOutputState;
@property(assign) NSInteger lastWiredAlarmOutputState;

@property(strong, nonatomic) NSString *bindEmail;

@property(strong, nonatomic) NSMutableArray *bindIds;
@property(strong, nonatomic) NSMutableArray *lastSetBindIds;
@property(assign) NSInteger selectedUnbindAccountIndex;
@property(assign) NSInteger maxBindIdCount;
    
@property (strong, nonatomic) MBProgressHUD *progressAlert;

@property (nonatomic) BOOL isSupportHI_WI_WO;
@end
