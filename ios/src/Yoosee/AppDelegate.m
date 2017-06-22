//
//  AppDelegate.m
//  Yoosee
//
//  Created by guojunyi on 14-3-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "AppDelegate.h"
#import "MainController.h"
#import "UDManager.h"
#import "LoginController.h"
#import "Constants.h"
#import "AutoNavigation.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "NetManager.h"
#import "AccountResult.h"
#import "Reachability.h"
#import "Message.h"
#import "Utils.h"
#import "MessageDAO.h"
#import "FListManager.h"
#import "CheckNewMessageResult.h"
#import "GetContactMessageResult.h"
#import "CheckAlarmMessageResult.h"
#import "ContactDAO.h"
#import "GlobalThread.h"
#import "Contact.h"
#import "Toast+UIView.h"
#import "UncaughtExceptionHandler.h"
#import "Alarm.h"
#import "AlarmDAO.h"
#import "MPNotificationView.h"
#import "LaunchImageTransition.h"
#import "AlarmPushController.h"//door ring push



@implementation AppDelegate{
    UIAlertView *_alarmAlertView;
}

#pragma mark - 返回三种类型的rect，分别是水平、7.0和其他情况
+(CGRect)getScreenSize:(BOOL)isNavigation isHorizontal:(BOOL)isHorizontal{
    CGRect rect = [UIScreen mainScreen].bounds;
    
    if(isHorizontal){
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
    }
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0){
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-20);
    }
    return rect;
}

+ (AppDelegate*)sharedDefault
{
    
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

+(NSString*)getAppVersion{
    return [NSString stringWithFormat:APP_VERSION];
}

-(void)dealloc{
    //{{--kongyulu at 20150920
    self.window = nil;
    self.mainController = nil;
    //{{--kongyulu at 20150920
    [super dealloc];
}

- (void) reachabilityChanged:(NSNotification *)note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    self.networkStatus = [curReach currentReachabilityStatus];
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithCapacity:0];
    [parameter setObject:[NSNumber numberWithInt:self.networkStatus] forKey:@"status"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NET_WORK_CHANGE
                                                        object:self
                                                      userInfo:parameter];
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return UIInterfaceOrientationMaskAll;
}

- (void)tapReceivedNotificationHandler:(NSNotification *)notice
{
    MPNotificationView *notificationView = (MPNotificationView *)notice.object;
    if ([notificationView isKindOfClass:[MPNotificationView class]])
    {
        //NSLog( @"Received touch for notification with text: %@", ((MPNotificationView *)notice.object).textLabel.text );
        [self.mainController setSelectedIndex:1];
        [self.mainController setBottomBarHidden:NO];
        self.isNotificationBeClicked = YES;
        self.window.rootViewController = self.mainController;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //app 启动时，检查更新
    //[self checkAppToUpdate];
    
    if(CURRENT_VERSION>=8.0){//8.0以后使用这种方法来注册推送通知
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    }
    
    //InstallUncaughtExceptionHandler();
    //[application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tapReceivedNotificationHandler:)
                                                 name:kMPNotificationViewTapReceivedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSessionIdError:) name:NOTIFICATION_ON_SESSION_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveAlarmMessage:) name:RECEIVE_ALARM_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveDoorbellAlarmMessage:) name:RECEIVE_DOORBELL_ALARM_MESSAGE object:nil];
    [AppDelegate getAppVersion];
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.networkStatus = ReachableViaWWAN;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    NSString *remoteHostName = @"www.baidu.com";
    
    
	[[Reachability reachabilityWithHostName:remoteHostName] startNotifier];
    

    
    if([UDManager isLogin]){
        
        MainController *mainController = [[MainController alloc] init];
        self.mainController = mainController;
        
//        NSString *lacalFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppStartInfoFlag"];
//        if (!lacalFlag) {//first launching app(其实没必要判断，第一次只在进入登录界面时发生)
            self.window.rootViewController = self.mainController;
//        }else{
//            self.window.rootViewController = [[[LaunchImageTransition alloc] initWithViewController:self.mainController animation:UIModalTransitionStyleCrossDissolve] autorelease];
//        }
        [mainController release];
        
        LoginResult *loginResult = [UDManager getLoginInfo];
        [[NetManager sharedManager] getAccountInfo:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
            
            AccountResult *accountResult = (AccountResult*)JSON;
            if(accountResult.error_code==NET_RET_GET_ACCOUNT_SUCCESS){
                loginResult.email = accountResult.email;
                loginResult.phone = accountResult.phone;
                loginResult.countryCode = accountResult.countryCode;
                [UDManager setLoginInfo:loginResult];
            }
            
        }];
    }else{
        LoginController *loginController = [[LoginController alloc] init];
        AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
        
//        NSString *lacalFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppStartInfoFlag"];
//        if (!lacalFlag) {//first launching app
            self.window.rootViewController = mainController;
//        }else{
//            self.window.rootViewController = [[[LaunchImageTransition alloc] initWithViewController:mainController animation:UIModalTransitionStyleCrossDissolve] autorelease];
//        }
        
        [loginController release];
        [mainController release];
    }

    [self.window makeKeyAndVisible];
    return YES;
}

-(void)onSessionIdError:(id)sender{
    [UDManager setIsLogin:NO];
    
    [[GlobalThread sharedThread:NO] kill];
    [[FListManager sharedFList] setIsReloadData:YES];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    LoginController *loginController = [[LoginController alloc] init];
    loginController.isSessionIdError = YES;
    AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
    
    [AppDelegate sharedDefault].window.rootViewController = mainController;
    [loginController release];
    [mainController release];
    
    dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
    dispatch_async(queue, ^{
        [[P2PClient sharedClient] p2pDisconnect];
        DLog(@"p2pDisconnect.");
    });
}

-(NSString *)groupName:(int)group{//addgroupItem
    NSString *groupName = @"";
    switch(group){
        case 1:
        {
            groupName = NSLocalizedString(@"hall", nil);
        }
            break;
        case 2:
        {
            groupName = NSLocalizedString(@"window", nil);
        }
            break;
        case 3:
        {
            groupName = NSLocalizedString(@"balcony", nil);
        }
            break;
        case 4:
        {
            groupName = NSLocalizedString(@"bedroom", nil);
        }
            break;
        case 5:
        {
            groupName = NSLocalizedString(@"kitchen", nil);
        }
            break;
        case 6:
        {
            groupName = NSLocalizedString(@"courtyard", nil);
        }
            break;
        case 7:
        {
            groupName = NSLocalizedString(@"door_lock", nil);
        }
            break;
        case 8:
        {
            groupName = NSLocalizedString(@"other", nil);
        }
            break;
    }
    return groupName;
}

- (void)onReceiveAlarmMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    
    //contact name
    NSString *contactId   = [parameter valueForKey:@"contactId"];
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    Contact *contact = [contactDAO isContact:contactId];
    NSString *contactName = contact.contactName;
    [contactDAO release];
    
    //contact type
    int type   = [[parameter valueForKey:@"type"] intValue];
    
    //防区、通道
    int group   = [[parameter valueForKey:@"group"] intValue];
    int item   = [[parameter valueForKey:@"item"] intValue];
    
    //推送提示消息
    NSString *message2 = @"";//addgroupItem
    NSString *leftSpace = @"";
    if ([UIDevice currentDevice].systemVersion.floatValue < 8.0 && [UIDevice currentDevice].systemVersion.floatValue >= 7.0){
        leftSpace = @"";//
    }else{
        leftSpace = @"                ";//16
    }
    
    
    //根据报警类型显示文字
    NSString *typeStr = @"";
    switch(type){
        case 1:
        {
            typeStr = NSLocalizedString(@"extern_alarm", nil);
            if (group>=1 && group<=8) {//addgroupItem
                message2 = [NSString stringWithFormat:@"%@%@ :%@\n%@%@ :%d",leftSpace,NSLocalizedString(@"defence_group", nil),[self groupName:group],leftSpace,NSLocalizedString(@"defence_item", nil),item+1];
            }
        }
            break;
        case 2:
        {
            typeStr = NSLocalizedString(@"motion_dect_alarm", nil);
        }
            break;
        case 3:
        {
            typeStr = NSLocalizedString(@"emergency_alarm", nil);
        }
            break;
        case 5:
        {
            typeStr = NSLocalizedString(@"ext_line_alarm", nil);
        }
            break;
        case 6:
        {
            typeStr = NSLocalizedString(@"low_vol_alarm", nil);
        }
            break;
        case 7:
        {
            typeStr = NSLocalizedString(@"pir_alarm", nil);
        }
            break;
        case 13://门铃报警类型
        {
            typeStr = NSLocalizedString(@"somebody_visit", nil);
        }
            break;
    }
    
    
    //isCanShow = NO表示监控中
    P2PCallState p2pCallState = [[P2PClient sharedClient] p2pCallState];
    BOOL isCanShow = NO;
    if(p2pCallState==P2PCALL_STATE_NONE){
        isCanShow = YES;
    }else{
        isCanShow = NO;
    }
    
    //APP在后台
    if(self.isGoBack){
        UILocalNotification *alarmNotify = [[[UILocalNotification alloc] init] autorelease];
        alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
        alarmNotify.soundName = @"default";
        if ([contactId isEqualToString:contactName] || contactName == nil) {
            alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactId,typeStr];
        }else{
            alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactName,typeStr];
        }
        alarmNotify.applicationIconBadgeNumber = 1;
        alarmNotify.alertAction = NSLocalizedString(@"open", nil);
        [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
    }
    
    //上一次与当前推送的时间间隔
    BOOL isTimeAfter = NO;
    DLog(@"%li",[Utils getCurrentTimeInterval]);
    if(([Utils getCurrentTimeInterval]-self.lastShowAlarmTimeInterval)>3){
        isTimeAfter = YES;
        
    }else{
        isTimeAfter = NO;
    }
    
    
    //alarmContactId是否正处于被监控
    if ([self.monitoredContactId isEqualToString:contactId]) {
        //正处于被监控,不作推送
        return;
    }
    
    
    //弹出推送提示框，一是门铃推送，二是其他
    if(isTimeAfter){//alarmAlertview   isCanShow&&
        self.alarmContactId = contactId;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (type == 13 && isCanShow) {//为门铃推送,isCanShow为YES表示不在监控中...
                self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
                self.isShowingDoorBellAlarm = YES;//表示正显示门铃推送界面
                
                //_alarmAlertView存在时，在弹出门铃推送界面前，先收起当前的提示
                if (_alarmAlertView) {
                    [_alarmAlertView dismissWithClickedButtonIndex:0 animated:NO];
                    _alarmAlertView = nil;//alarmAlertview
                }
                
                //显示门铃推送界面
                [self.mainController dismissP2PView];//在"报警设置"进入AlarmPushController前执行,若不执行，则会导致从AlarmPushController返回时，无法再进入"报警设置"
                AlarmPushController * alarmpushcontroller = [[AlarmPushController alloc] init];//door ring push
                alarmpushcontroller.contactId = contactId;
                alarmpushcontroller.contactName = contactName;
                self.window.rootViewController = alarmpushcontroller;
                [alarmpushcontroller release];
                //second incoming call play ring wait
                [[RingPlayer defaultRingPlayer] ringPlay:E_RING_RING
                                            numberofLoop:2];       //test on 7.19
                
            }else{//为其他推送
                if (type == 13 && !isCanShow) {//为门铃推送,isCanShow为NO表示在监控中...
                    self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
                }else{
                   self.isDoorBellAlarm = NO;//在监控界面使用,区分门铃推送，其他推送
                }
                
                
                //AlarmPushController正在显示时，在弹出其他推送提示前，先收起当前的门铃推送界面
                //觉得不应该收起,但是不收起，弹出其他推送时，又监控不了，因为rootViewController
                if (self.isShowingDoorBellAlarm) {
                    self.isShowingDoorBellAlarm = NO;
                    self.window.rootViewController = self.mainController;
                }
                
                //_alarmAlertView存在时，在弹出下一个提示前，先收起当前的提示
                if (_alarmAlertView) {
                    [_alarmAlertView dismissWithClickedButtonIndex:0 animated:NO];
                }
                //显示其他推送提示
                NSString* title = @"";
                NSString *message = @"";
                message = [NSString stringWithFormat:@"%@%@%@\n%@\n",leftSpace,NSLocalizedString(@"alarm_type", nil),typeStr,message2];
                if ([contactId isEqualToString:contactName] || contactName == nil) {

                    title = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"device", nil),contactId] ;
                    
                }else {

                    title = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"device", nil),contactName];
                    
                }
                
                _alarmAlertView = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"view", nil) otherButtonTitles:NSLocalizedString(@"cancel", nil),nil] autorelease];
                _alarmAlertView.tag = ALERT_TAG_ALARMING;
                
                //UIAlertView 左对齐 iOS7及iOS6不同处理
                if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0){
                    CGSize size = [_alarmAlertView.message sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(240,400) lineBreakMode:NSLineBreakByTruncatingTail];
                    
                    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, -120,size.width, size.height)];
                    textLabel.font = [UIFont systemFontOfSize:15];
                    textLabel.textColor = [UIColor blackColor];
                    textLabel.backgroundColor = [UIColor clearColor];
                    textLabel.lineBreakMode =NSLineBreakByWordWrapping;
                    textLabel.numberOfLines =0;
                    textLabel.textAlignment =NSTextAlignmentLeft;
                    textLabel.text = _alarmAlertView.message;
                    [_alarmAlertView setValue:textLabel forKey:@"accessoryView"];
                    [textLabel release];
                    
                    _alarmAlertView.message =@"";
                }
                [_alarmAlertView show];
            }
        });//alarmAlertview
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView{
    //UIAlertView 左对齐 iOS7及iOS6不同处理
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) {
        NSInteger count = 0;
        for( UIView * view in _alarmAlertView.subviews )
        {
            if( [view isKindOfClass:[UILabel class]] )
            {
                count ++;
                if ( count == 2 ) { //仅对message左对齐
                    UILabel* label = (UILabel*) view;
                    label.textAlignment =NSTextAlignmentLeft;
                }
            }
        }
    }
}

#pragma mark - 透传门铃（安尔发...）
-(void)onReceiveDoorbellAlarmMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    
    NSString *cmd = [parameter valueForKey:@"cmd"];
    
    if ([cmd isEqualToString:@"anerfa:disconnect"]) {
        NSString *contactId = [parameter valueForKey:@"contactId"];
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:contactId];
        [contactDAO release];
        [[P2PClient sharedClient] sendCustomCmdWithId:contactId password:contact.contactPassword cmd:@"IPC1anerfa:disconnect"];
        
    }else if ([[cmd substringToIndex:11] isEqualToString:@"anerfa:call"]) {
        NSString *contactId = [parameter valueForKey:@"contactId"];
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:contactId];
        NSString *contactName = contact.contactName;
        [contactDAO release];
        
        NSString *typeStr = NSLocalizedString(@"somebody_visit", nil);
        
        //后台推送
        if(self.isGoBack){
            UILocalNotification *alarmNotify = [[[UILocalNotification alloc] init] autorelease];
            alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
            alarmNotify.soundName = @"default";
            if ([contactId isEqualToString:contactName] || contactName == nil) {
                alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactId,typeStr];
            }else{
                alarmNotify.alertBody = [NSString stringWithFormat:@"%@:%@",contactName,typeStr];
            }
            alarmNotify.applicationIconBadgeNumber = 1;
            alarmNotify.alertAction = NSLocalizedString(@"open", nil);
            [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
        }
        
        //前台推送
        P2PCallState p2pCallState = [[P2PClient sharedClient] p2pCallState];
        BOOL isCanShow = NO;
        if(p2pCallState==P2PCALL_STATE_NONE){
            isCanShow = YES;
        }else{
            isCanShow = NO;
        }
        
        BOOL isTimeAfter = NO;
        if(([Utils getCurrentTimeInterval]-self.lastShowAlarmTimeInterval)>3){
            isTimeAfter = YES;
            
        }else{
            isTimeAfter = NO;
        }
        
        if(isTimeAfter){//alarmAlertview
            self.alarmContactId = contactId;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCanShow) {//为门铃推送,isCanShow为YES表示不在监控中...
                    self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
                    self.isShowingDoorBellAlarm = YES;//表示正显示门铃推送界面
                    
                    //_alarmAlertView存在时，在弹出门铃推送界面前，先收起当前的提示
                    if (_alarmAlertView) {
                        [_alarmAlertView dismissWithClickedButtonIndex:0 animated:NO];
                        _alarmAlertView = nil;//alarmAlertview
                    }
                    
                    //显示门铃推送界面
                    AlarmPushController * alarmpushcontroller = [[AlarmPushController alloc] init];//door ring push
                    alarmpushcontroller.contactId = contactId;
                    alarmpushcontroller.contactName = contactName;
                    self.window.rootViewController = alarmpushcontroller;
                    [alarmpushcontroller release];
                    
                }else{//为门铃推送,isCanShow为NO表示在监控中...
                    self.isDoorBellAlarm = YES;//在监控界面使用,区分门铃推送，其他推送
                    
                    //_alarmAlertView存在时，在弹出下一个提示前，先收起当前的提示
                    if (_alarmAlertView) {
                        [_alarmAlertView dismissWithClickedButtonIndex:0 animated:NO];
                    }
                    //显示其他推送提示
                    if ([contactId isEqualToString:contactName] || contactName == nil) {
                        NSString* title = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"device", nil),contactId] ;
                        NSString *message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"alarm_type", nil),typeStr];
                        _alarmAlertView = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"view", nil) otherButtonTitles:NSLocalizedString(@"cancel", nil),nil] autorelease];
                        _alarmAlertView.tag = ALERT_TAG_ALARMING;
                        [_alarmAlertView show];
                    }else {
                        NSString* title = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"device", nil),contactName] ;
                        NSString *message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"alarm_type", nil),typeStr];
                        _alarmAlertView = [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"view", nil) otherButtonTitles:NSLocalizedString(@"cancel", nil),nil] autorelease];
                        _alarmAlertView.tag = ALERT_TAG_ALARMING;
                        [_alarmAlertView show];
                    }
                }
                
            });
        }//alarmAlertview
    }else{
        //unknown error
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_ALARMING:
        {
            _alarmAlertView = nil;//alarmAlertview
            if(buttonIndex==0){
                ContactDAO *contactDAO = [[ContactDAO alloc] init];
                Contact *contact = [contactDAO isContact:self.alarmContactId];
                [contactDAO release];
                
                if(nil!=contact){
                    [[P2PClient sharedClient] p2pHungUp];
                    self.mainController.contactName = contact.contactName;//昵称显示不对
                    [AppDelegate sharedDefault].contact = nil;
                    [self.mainController dismissP2PView:^{
                        [self.mainController setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
                        self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
                    }];
                    
                }else{
                    UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_device_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                    inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
                    UITextField *passwordField = [inputAlert textFieldAtIndex:0];
                    passwordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    inputAlert.tag = ALERT_TAG_MONITOR;
                    [inputAlert show];
                    [inputAlert release];
                }
            }else{//取消
                self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
            }
        }
            break;
        case ALERT_TAG_MONITOR:
        {
            _alarmAlertView = nil;//alarmAlertview
            if(buttonIndex==1){
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                
                NSString *inputPwd = passwordField.text;
                if(!inputPwd||inputPwd.length==0){
                    [self.mainController.view makeToast:NSLocalizedString(@"input_device_password", nil)];
                    self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
                    return;
                }
                [[P2PClient sharedClient] p2pHungUp];
                
                MainController *mainController = [AppDelegate sharedDefault].mainController;
                mainController.contactName = self.alarmContactId;
                
                Contact *contact = [[Contact alloc] init];//重新调整监控画面
                contact.contactId = self.alarmContactId;
                contact.contactName = self.alarmContactId;
                contact.contactPassword = inputPwd;
                [AppDelegate sharedDefault].contact = contact;
                [AppDelegate sharedDefault].mainController.contact = nil;
                [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
                [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];//在这为了获取设备类型,在监控界面区分门铃设备与其他设备
                [contact release];//重新调整监控画面
                
                [self.mainController dismissP2PView:^{
                    [self.mainController setUpCallWithId:self.alarmContactId password:inputPwd callType:P2PCALL_TYPE_MONITOR];
                    self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
                }];
                
                
            }else{
                self.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
            }
            
        }
            break;
        case ALERT_TAG_APP_UPDATE://app检查更新
        {
            if(buttonIndex == 1){
                //app的数字ID
                NSString * plist = [[NSBundle mainBundle] pathForResource:@"Common-Configuration" ofType:@"plist"];
                NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
                NSString *appleID = dic[@"AppleID"];
                
                //已经上架的APP的URL
                NSString *trackViewUrl = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", appleID];
                NSURL *url= [NSURL URLWithString:trackViewUrl];
                [[UIApplication sharedApplication] openURL:url];
            }
        }
            break;
    }
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_RECEIVE_MESSAGE:
        {
            NSString *contactId = [parameter valueForKey:@"contactId"];
            NSString *messageStr = [parameter valueForKey:@"message"];
            LoginResult *loginResult = [UDManager getLoginInfo];
            MessageDAO *messageDAO = [[MessageDAO alloc] init];
            Message *message = [[Message alloc] init];
            
            message.fromId = contactId;
            message.toId = loginResult.contactId;
            message.message = [NSString stringWithFormat:@"%@",messageStr];
            message.state = MESSAGE_STATE_NO_READ;
            message.time = [NSString stringWithFormat:@"%ld",[Utils getCurrentTimeInterval]];
            message.flag = -1;
            [messageDAO insert:message];
            [message release];
            [messageDAO release];
            NSInteger lastCount = [[FListManager sharedFList] getMessageCount:contactId];
            [[FListManager sharedFList] setMessageCountWithId:contactId count:lastCount+1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                    object:self
                                                                  userInfo:nil];
            });
            
            UILocalNotification *notification = [[[UILocalNotification alloc] init] autorelease];
            notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.soundName = @"message.mp3";
            notification.alertBody = [NSString stringWithFormat:@"%@:%@",contactId,messageStr];
            notification.applicationIconBadgeNumber = 1;
            notification.alertAction = NSLocalizedString(@"open", nil);
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
            break;
        case RET_GET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            NSString *contactId = [parameter valueForKey:@"contactId"];
            if(state==SETTING_VALUE_REMOTE_DEFENCE_STATE_ON){
                [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_ON];
            }else{
                [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_OFF];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                    object:self
                                                                  userInfo:nil];
            });
            DLog(@"RET_GET_NPCSETTINGS_REMOTE_DEFENCE");
            
        }
            break;
            
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    NSString *contactId = [parameter valueForKey:@"contactId"];
    switch(key){
        case ACK_RET_SEND_MESSAGE:
        {
            
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                int flag = [[parameter valueForKey:@"flag"] intValue];
                MessageDAO *messageDAO = [[MessageDAO alloc] init];
                if(result==0){
                    [messageDAO updateMessageStateWithFlag:flag state:MESSAGE_STATE_NO_READ];
                }else{
                    [messageDAO updateMessageStateWithFlag:flag state:MESSAGE_STATE_SEND_FAILURE];
                }
                [messageDAO release];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                    object:self
                                                                  userInfo:nil];
                });
            });
            
            
            DLog(@"ACK_RET_GET_DEVICE_TIME:%i",result);
        }
            break;
        case ACK_RET_GET_DEFENCE_STATE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
//                NSString *contactId = @"10000";
                if(result==1){
                    
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_PWD];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:NSLocalizedString(@"device_password_error", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else if(result==2){
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_NET];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:NSLocalizedString(@"net_exception", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else if (result==4){
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_NO_PERMISSION];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:NSLocalizedString(@"no_permission", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }
                
                [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:contactId isClick:NO];
                
            });
            
            DLog(@"ACK_RET_GET_DEFENCE_STATE:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_PWD];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:NSLocalizedString(@"device_password_error", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else if(result==2){
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_WARNING_NET];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:NSLocalizedString(@"net_exception", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else if (result==4){
                    [[FListManager sharedFList] setDefenceStateWithId:contactId type:DEFENCE_STATE_NO_PERMISSION];
                    if([[FListManager sharedFList] getIsClickDefenceStateBtn:contactId]){
                        [self.window makeToast:NSLocalizedString(@"no_permission", nil)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
                                                                            object:self
                                                                          userInfo:nil];
                    });
                }else{
                    ContactDAO *contactDAO = [[ContactDAO alloc] init];
                    Contact *contact = [contactDAO isContact:contactId];
                    [contactDAO release];
                    if(nil!=contact){
                        [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
                    }
                    
                }
                
                [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:contactId isClick:NO];
                
            });
            DLog(@"ACK_RET_GET_DEFENCE_STATE:%i",result);
        }
            break;
    
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken
{
    
    
    DLog(@"%@",pToken);
    NSString *deviceToken = [[pToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    //注册成功，将deviceToken保存到应用服务器数据库中
    DLog(@"%@",deviceToken);
    
    self.token = [NSString stringWithFormat:@"%@",deviceToken];
    
}


-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    DLog(@"%@%@",@"didFailToRegisterForRemoteNotificationsWithError:",[error localizedDescription]);
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    DLog(@"userInfo %@", userInfo);
    // 处理推送消息
//    NSLog(@"userinfo:%@",userInfo);
//    NSArray *allKeys = [userInfo allKeys];
//    for (NSString *aString in allKeys) {
//        DLog(@"id %@ content is %@", aString, userInfo[aString]);
//    }
//    NSLog(@"收到推送消息:%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    
}

#pragma mark - 前台收到本地通知、后台点击本地通知时，调用
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    DLog(@"%@",notification.alertBody);
    //[Utils playMusicWithName:@"message" type:@"mp3"];
    
    //can delete
//    [self.mainController setSelectedIndex:1];
//    [self.mainController setBottomBarHidden:NO];
//    self.isNotificationBeClicked = YES;
//    self.window.rootViewController = self.mainController;
}

UIBackgroundTaskIdentifier backgroundTask;
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DLog(@"applicationDidEnterBackground");
    
    
    [[P2PClient sharedClient] p2pHungUp];
    [self.mainController dismissP2PView];
    
    
    
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier taskID;
    taskID = [app beginBackgroundTaskWithExpirationHandler:^{
        [[P2PClient sharedClient] p2pDisconnect];
        [app endBackgroundTask:taskID];
    }];
    
    if (taskID == UIBackgroundTaskInvalid) {
        [[P2PClient sharedClient] p2pDisconnect];
        NSLog(@"Failed to start background task!");
        return;
    }
    
    self.isGoBack = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (self.isGoBack) {
            DLog(@"run background");
            sleep(1.0);
            
        }
    });

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DLog(@"applicationWillEnterForeground");
    self.isGoBack = NO;
    if([UDManager isLogin]){
        application.applicationIconBadgeNumber = 0;
        LoginResult *loginResult = [UDManager getLoginInfo];
        BOOL result = [[P2PClient sharedClient] p2pConnectWithId:loginResult.contactId codeStr1:loginResult.rCode1 codeStr2:loginResult.rCode2];
        if(result){
            DLog(@"p2pConnect success.");
        }else{
            DLog(@"p2pConnect failure.");
            
        }
        
        [[NetManager sharedManager] getAccountInfo:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
            AccountResult *accountResult = (AccountResult*)JSON;
            loginResult.email = accountResult.email;
            loginResult.phone = accountResult.phone;
            loginResult.countryCode = accountResult.countryCode;
            [UDManager setLoginInfo:loginResult];
        }];
        
        //关闭此功能
        /*
//        [[NetManager sharedManager] checkNewMessage:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
//            CheckNewMessageResult *checkNewMessageResult = (CheckNewMessageResult*)JSON;
//            if(checkNewMessageResult.error_code==NET_RET_CHECK_NEW_MESSAGE_SUCCESS){
//                if(checkNewMessageResult.isNewContactMessage){
//                    DLog(@"have new");
//                    [[NetManager sharedManager] getContactMessageWithUsername:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
//                        NSArray *datas = [NSArray arrayWithArray:JSON];
//                        if([datas count]<=0){
//                            return;
//                        }
//                        BOOL haveContact = NO;
//                        for(GetContactMessageResult *result in datas){
//                            DLog(@"%@",result.message);
//                            
//                            ContactDAO *contactDAO = [[ContactDAO alloc] init];
//                            Contact *contact = [contactDAO isContact:result.contactId];
//                            if(nil!=contact){
//                                haveContact = YES;
//                            }
//                            [contactDAO release];
//                            MessageDAO *messageDAO = [[MessageDAO alloc] init];
//                            Message *message = [[Message alloc] init];
//                            
//                            message.fromId = result.contactId;
//                            message.toId = loginResult.contactId;
//                            message.message = [NSString stringWithFormat:@"%@",result.message];
//                            message.state = MESSAGE_STATE_NO_READ;
//                            message.time = [NSString stringWithFormat:@"%@",result.time];
//                            message.flag = result.flag;
//                            [messageDAO insert:message];
//                            [message release];
//                            [messageDAO release];
//                            int lastCount = [[FListManager sharedFList] getMessageCount:result.contactId];
//                            [[FListManager sharedFList] setMessageCountWithId:result.contactId count:lastCount+1];
//                            
//                        }
//                        if(haveContact){
//                            [Utils playMusicWithName:@"message" type:@"mp3"];
//                        }
//                        
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMessage"
//                                                                            object:self
//                                                                          userInfo:nil];
//                    }];
//                }
//            }else{
//                
//            }
//        }];
        */
        
        //关闭此功能
        /*
        [[NetManager sharedManager] checkAlarmMessage:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
            CheckAlarmMessageResult *checkAlarmMessageResult = (CheckAlarmMessageResult*)JSON;
            if(checkAlarmMessageResult.error_code==NET_RET_CHECK_ALARM_MESSAGE_SUCCESS){
                if(checkAlarmMessageResult.isNewAlarmMessage){
                    DLog(@"have new");
                    
                }
            }else{
                
            }
        }];
         */
    }
    
    
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

#pragma mark - 方法1(异步请求)，APP检查更新
-(void)checkAppToUpdate{
    //app的数字ID
    NSString * plist = [[NSBundle mainBundle] pathForResource:@"Common-Configuration" ofType:@"plist"];
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
    NSString *appleID = dic[@"AppleID"];
    
    //获取当前APP的版本号
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *nowVersion = [infoDict objectForKey:@"CFBundleVersion"];
    
    
    //已经上架的APP的版本号
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appleID]];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPMethod:@"GET"];
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if ( [data length] > 0 && !error ) { // Success
            
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // All versions that have been uploaded to the AppStore
                NSArray *versionsInAppStore = [[appData valueForKey:@"results"] valueForKey:@"version"];
                
                if ( ![versionsInAppStore count] ) { // No versions of app in AppStore
                    
                    return;
                    
                } else {
                    //已经上架的APP的版本号
                    NSString *versionInAppStore = [versionsInAppStore objectAtIndex:0];
                    
                    //不相等，说明有可更新的APP
                    if([nowVersion isEqualToString:versionInAppStore]==NO){
                        NSString *message=[[NSString alloc] initWithFormat:@"%@%@%@",NSLocalizedString(@"can_update_to", nil),versionInAppStore,NSLocalizedString(@"version", nil)];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"update", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"next_time", nil)  otherButtonTitles:NSLocalizedString(@"update_now", nil), nil];
                        [message release];
                        alert.tag = ALERT_TAG_APP_UPDATE;
                        [alert show];
                        [alert release];
                    }
                }
                
            });
        }
        
    }];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
