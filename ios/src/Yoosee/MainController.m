//
//  MainController.m
//  Yoosee
//
//  Created by guojunyi on 14-3-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "MainController.h"
#import "ContactController.h"
#import "MessageController.h"
#import "SDWebImageRootViewController.h"
#import "MoreController.h"
#import "P2PVideoController.h"
#import "Constants.h"
#import "P2PClient.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "P2PMonitorController.h"
#import "Toast+UIView.h"
#import "P2PCallController.h"
#import "AutoNavigation.h"
#import "GlobalThread.h"
#import "AccountResult.h"
#import "NetManager.h"
#import "AppDelegate.h"
#import "CameraManager.h"
#import "LoginController.h"
#import "FListManager.h"

@interface MainController ()

@end

@implementation MainController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    LoginResult *loginResult = [UDManager getLoginInfo];
    BOOL result = [[P2PClient sharedClient] p2pConnectWithId:loginResult.contactId codeStr1:loginResult.rCode1 codeStr2:loginResult.rCode2];
    if(result){
        DLog(@"p2pConnect success.");
    }else{//new added
        [UDManager setIsLogin:NO];
        
        //[[GlobalThread sharedThread:NO] kill];//在contactController里创建
        [[FListManager sharedFList] setIsReloadData:YES];
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        LoginController *loginController = [[LoginController alloc] init];
        loginController.isP2PVerifyCodeError = YES;
        AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
        
        [AppDelegate sharedDefault].window.rootViewController = mainController;
        [loginController release];
        [mainController release];
        DLog(@"p2pConnect failure.");
        return;
    }
    
    
    [[P2PClient sharedClient] setDelegate:self];
    [self initComponent];
    
	// Do any additional setup after loading the view.
   
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initComponent{
    
    //contact
    ContactController *contactController = [[ContactController alloc] init];
    AutoNavigation *controller1 = [[AutoNavigation alloc] initWithRootViewController:contactController];
    [contactController release];
    
    //message
    MessageController *messageController = [[MessageController alloc] init];
    AutoNavigation *controller2 = [[AutoNavigation alloc] initWithRootViewController:messageController];
    [messageController release];
    
    //Screenshot
    SDWebImageRootViewController *screenshotController = [[SDWebImageRootViewController alloc] init];
    
    UINavigationController *controller3 = [[UINavigationController alloc] initWithRootViewController:screenshotController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [controller3.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:XHeadBarTextColor,UITextAttributeTextColor,[UIFont boldSystemFontOfSize:XHeadBarTextSize],UITextAttributeFont,nil]];
        [controller3.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_navigation_bar.png"] forBarMetrics:UIBarMetricsDefault];
        if([UIDevice currentDevice].systemVersion.floatValue < 7.0){
            controller3.navigationBar.clipsToBounds = YES;//iPod
        }
        
    }else{
        [[controller3 navigationBar] setBarStyle:UIBarStyleBlack];
    }
//    [[controller3 navigationBar] setBarStyle:UIBarStyleBlack];
//    [[controller3 navigationBar] setTranslucent:YES];
//    AutoNavigation *controller3 = [[AutoNavigation alloc] initWithRootViewController:screenshotController];
    
    [screenshotController release];
    
    //more
    MoreController *moreController = [[MoreController alloc] init];
    AutoNavigation *controller5 = [[AutoNavigation alloc] initWithRootViewController:moreController];
    [moreController release];
    
    
    [self setViewControllers:@[controller1,controller2,controller3,controller5]];
    [controller1 release];
    [controller2 release];
    [controller3 release];
    [controller5 release];
    
    [self setSelectedIndex:0];
}

#pragma mark - 进入呼叫设备界面1
-(void)setUpCallWithId:(NSString *)contactId password:(NSString *)password callType:(P2PCallType)type{
    [[P2PClient sharedClient] setIsBCalled:NO];
    [[P2PClient sharedClient] setCallId:contactId];
    [[P2PClient sharedClient] setP2pCallType:type];
    [[P2PClient sharedClient] setCallPassword:password];

    if(!self.presentedViewController){
        
        P2PCallController *p2pCallController = [[P2PCallController alloc] init];
        p2pCallController.contactName = self.contactName;
        
        AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
        [self presentViewController:controller animated:YES completion:^{
            
        }];
        [p2pCallController release];
        [controller release];
        //[[P2PClient sharedClient] p2pCallWithId:contactId password:password callType:type];
    }
}

#pragma mark - 进入呼叫设备界面2
-(void)setUpCallWithId:(NSString *)contactId address:(NSString*)address password:(NSString *)password callType:(P2PCallType)type{
    [[P2PClient sharedClient] setIsBCalled:NO];
    [[P2PClient sharedClient] setCallId:contactId];
    [[P2PClient sharedClient] setP2pCallType:type];
    [[P2PClient sharedClient] setCallPassword:password];

    if(!self.presentedViewController){
        
        P2PCallController *p2pCallController = [[P2PCallController alloc] init];
        p2pCallController.contactName = self.contactName;
        [p2pCallController setAddress:address];
        AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
        [self presentViewController:controller animated:YES completion:^{
            
        }];
        [p2pCallController release];
        [controller release];
        //[[P2PClient sharedClient] p2pCallWithId:contactId password:password callType:type];
    }
}


-(void)P2PClientCalling:(NSDictionary*)info{
    DLog(@"P2PClientCalling");
    BOOL isBCalled = [[P2PClient sharedClient] isBCalled];
    NSString *callId = [[P2PClient sharedClient] callId];
    if(isBCalled){
        if([[AppDelegate sharedDefault] isGoBack]){
            UILocalNotification *alarmNotify = [[[UILocalNotification alloc] init] autorelease];
            alarmNotify.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            alarmNotify.timeZone = [NSTimeZone defaultTimeZone];
            alarmNotify.soundName = @"default";
            alarmNotify.alertBody = [NSString stringWithFormat:@"%@:Calling!",callId];
            alarmNotify.applicationIconBadgeNumber = 1;
            alarmNotify.alertAction = NSLocalizedString(@"open", nil);
            [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotify];
            return;
        }
        
        if(!self.isShowP2PView){
            self.isShowP2PView = YES;
            UIViewController *presentView1 = self.presentedViewController;
            UIViewController *presentView2 = self.presentedViewController.presentedViewController;
            if(presentView2){
                [self dismissViewControllerAnimated:YES completion:^{
                    P2PCallController *p2pCallController = [[P2PCallController alloc] init];
                    AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
                    
                    [self presentViewController:controller animated:YES completion:^{
                        
                    }];
                    
                    [p2pCallController release];
                    [controller release];
                }];
            }else if(presentView1){
                [presentView1 dismissViewControllerAnimated:YES completion:^{
                    P2PCallController *p2pCallController = [[P2PCallController alloc] init];
                    AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
                    
                    [self presentViewController:controller animated:YES completion:^{
                        
                    }];
                    
                    [p2pCallController release];
                    [controller release];
                }];
            }else{
                P2PCallController *p2pCallController = [[P2PCallController alloc] init];
                AutoNavigation *controller = [[AutoNavigation alloc] initWithRootViewController:p2pCallController];
                
                [self presentViewController:controller animated:YES completion:^{
                    
                }];
                
                [p2pCallController release];
                [controller release];
            }
            
            
        }
        
    }
}

-(void)dismissP2PView{
    UIViewController *presentView1 = self.presentedViewController;
    UIViewController *presentView2 = self.presentedViewController.presentedViewController;
    if(presentView2){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [presentView1 dismissViewControllerAnimated:YES completion:nil];
    }
    self.isShowP2PView = NO;
}

-(void)dismissP2PView:(void (^)())callBack{
    UIViewController *presentView1 = self.presentedViewController;
    UIViewController *presentView2 = self.presentedViewController.presentedViewController;
    if(presentView2){
        [self dismissViewControllerAnimated:NO completion:^{
            callBack();
        }];
    }else if(presentView1){
        [presentView1 dismissViewControllerAnimated:NO completion:^{
            callBack();
        }];
    }else{
        callBack();
    }
    self.isShowP2PView = NO;
}

#pragma mark - 挂断监控设备回调
-(void)P2PClientReject:(NSDictionary*)info{
    DLog("P2PClientReject");
    

    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATE_NONE];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        usleep(500000);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            //[self dismissP2PView];//delete dismiss
            
            
            int errorFlag = [[info objectForKey:@"errorFlag"] intValue];
            switch(errorFlag)
            {
                case CALL_ERROR_NONE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_unknown_error", nil)];
                    break;
                }
                case CALL_ERROR_DESID_NOT_ENABLE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_disabled", nil)];
                    break;
                }
                case CALL_ERROR_DESID_OVERDATE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_overdate", nil)];
                    break;
                }
                case CALL_ERROR_DESID_NOT_ACTIVE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_inactived", nil)];

                    break;
                }
                case CALL_ERROR_DESID_OFFLINE:
                {
                    [self.view makeToast:NSLocalizedString(@"id_offline", nil)];

                    break;
                }
                case CALL_ERROR_DESID_BUSY:
                {
                    [self.view makeToast:NSLocalizedString(@"id_busy", nil)];

                    break;
                }
                case CALL_ERROR_DESID_POWERDOWN:
                {
                    [self.view makeToast:NSLocalizedString(@"id_powerdown", nil)];

                    break;
                }
                case CALL_ERROR_NO_HELPER:
                {
                    [self.view makeToast:NSLocalizedString(@"id_connect_failed", nil)];

                    break;
                }
                case CALL_ERROR_HANGUP:
                {
                    [self.view makeToast:NSLocalizedString(@"id_hangup", nil)];

                    break;
                }
                case CALL_ERROR_TIMEOUT:
                {
                    [self.view makeToast:NSLocalizedString(@"id_timeout", nil)];

                    break;
                }
                case CALL_ERROR_INTER_ERROR:
                {
                    [self.view makeToast:NSLocalizedString(@"id_internal_error", nil)];

                    break;
                }
                case CALL_ERROR_RING_TIMEOUT:
                {
                    [self.view makeToast:NSLocalizedString(@"id_no_accept", nil)];

                    break;
                }
                case CALL_ERROR_PW_WRONG:
                {
                    [self.view makeToast:NSLocalizedString(@"id_password_error", nil)];

                    break;
                }
                case CALL_ERROR_CONN_FAIL:
                {
                    [self.view makeToast:NSLocalizedString(@"id_connect_failed", nil)];
                    break;
                }
                case CALL_ERROR_NOT_SUPPORT:
                {
                    [self.view makeToast:NSLocalizedString(@"id_not_support", nil)];
                    break;
                }
                default:
                    [self.view makeToast:NSLocalizedString(@"id_unknown_error", nil)];

                    break;
            }
        });
    });
    
    
    
    
}


-(void)P2PClientAccept:(NSDictionary*)info{
    DLog(@"P2PClientAccept");
}

#pragma mark - 连接设备就绪
-(void)P2PClientReady:(NSDictionary*)info{
    DLog(@"P2PClientReady");
    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STET_READY];
    
    if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_MONITOR){
        P2PMonitorController *monitorController = [[P2PMonitorController alloc] init];
        //在这之前，已经present一个视力控制器，就P2PCallController
        //所以self.presentedViewController == P2PCallController
        if (self.presentedViewController) {
            [self.presentedViewController presentViewController:monitorController animated:YES completion:nil];
        }else{
            [self presentViewController:monitorController animated:YES completion:nil];
        }
        
        [monitorController release];
    }else if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_VIDEO){
        P2PVideoController *videoController = [[P2PVideoController alloc] init];
        if (self.presentedViewController) {
            [self.presentedViewController presentViewController:videoController animated:YES completion:nil];
        }else{
            [self presentViewController:videoController animated:YES completion:nil];
        }
        
        [videoController release];
    }
    
    
}

@end
