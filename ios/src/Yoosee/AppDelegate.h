//
//  AppDelegate.h
//  Yoosee
//
//  Created by guojunyi on 14-3-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainController.h"
#import "Reachability.h"
#import "Contact.h"//重新调整监控画面
#import "RingPlayer.h"

#define NET_WORK_CHANGE @"NET_WORK_CHANGE"
#define ALERT_TAG_ALARMING 0
#define ALERT_TAG_MONITOR 1
#define ALERT_TAG_APP_UPDATE 2
@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainController *mainController;
@property (strong, nonatomic) Contact *contact;//重新调整监控画面
@property (nonatomic) NetworkStatus networkStatus;
+(CGRect)getScreenSize:(BOOL)isNavigation isHorizontal:(BOOL)isHorizontal;
+(AppDelegate*)sharedDefault;

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *alarmContactId;
@property (strong, nonatomic) NSString *monitoredContactId;
@property (nonatomic) long lastShowAlarmTimeInterval;
@property (nonatomic) BOOL isDoorBellAlarm;//在监控界面使用,区分门铃推送，其他推送
@property (nonatomic) BOOL isShowingDoorBellAlarm;//表示正显示门铃推送界面

+(NSString*)getAppVersion;
@property (nonatomic) BOOL isGoBack;
@property (nonatomic) BOOL isNotificationBeClicked;//YES表示点击系统消息推送通知，将显示系统消息表

@end
