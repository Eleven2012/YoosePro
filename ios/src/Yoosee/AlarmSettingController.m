//
//  AlarmSettingController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "AlarmSettingController.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "TopBar.h"
#import "P2PSwitchCell.h"
#import "P2PBuzzerCell.h"
#import "P2PEmailSettingCell.h"
#import "BindAlarmEmailController.h"
#import "RadioButton.h"
#import "MBProgressHUD.h"
#import "AddBindAccountController.h"
#import "Toast+UIView.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "AlarmAccountController.h"
@interface AlarmSettingController ()

@end

@implementation AlarmSettingController

-(void)dealloc{
    
    [self.tableView release];
    [self.contact release];
    [self.alarmSwitch release];
    [self.buzzerSwitch release];
    [self.motionSwitch release];
    [self.humanInfraredSwitch release];
    [self.wiredAlarmInputSwitch release];
    [self.wiredAlarmOutputSwitch release];
    [self.radio1 release];
    [self.radio2 release];
    [self.radio3 release];
    [self.bindIds release];
    [self.bindEmail release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init{
    self = [super init];
    if(self){
        self.bindIds = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    if(!self.isFirstLoadingCompolete){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
        self.isLoadingAlarmState = YES;
        self.isLoadingBindEmail = YES;
        self.isLoadingBindId = YES;
        self.isLoadingBuzzer = YES;
        self.isLoadingMotionDetect = YES;
        self.isLoadingHumanInfrared = YES;
        self.isLoadingWiredAlarmInput = YES;
        self.isLoadingWiredAlarmOutput = YES;
        self.alarmState = SETTING_VALUE_ALARM_STATE_OFF;
        self.buzzerState = SETTING_VALUE_BUZZER_STATE_OFF;
        self.motionState = SETTING_VALUE_MOTION_STATE_OFF;
        self.humanInfraredState = SETTING_VALUE_HUMAN_INFRARED_STATE_OFF;
        self.wiredAlarmInputState = SETTING_VALUE_WIRED_ALARM_INPUT_STATE_OFF;
        self.wiredAlarmOutputState = SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_OFF;
        
        [[P2PClient sharedClient] getAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword];
        [[P2PClient sharedClient] getBindAccountWithId:self.contact.contactId password:self.contact.contactPassword];
        [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
        self.isFirstLoadingCompolete = !self.isFirstLoadingCompolete;
    }
    
}



-(void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}


- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
            
        case RET_GET_NPCSETTINGS_MOTION:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];

            self.motionState = state;
            self.lastMotionState = state;
            self.isLoadingMotionDetect = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"motion state:%i",state);
            
        }
            break;
        case RET_SET_NPCSETTINGS_MOTION:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingMotionDetect = NO;
            if(result==0){
                self.lastMotionState = self.motionState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastMotionState==SETTING_VALUE_MOTION_STATE_ON){
                        self.motionState = self.lastMotionState;
                        self.motionSwitch.on = YES;
                        
                    }else if(self.lastMotionState==SETTING_VALUE_MOTION_STATE_OFF){
                        self.motionState = self.lastMotionState;
                        self.motionSwitch.on = NO;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_NPCSETTINGS_BUZZER:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            
            self.buzzerState = state;
            self.lastBuzzerState = state;
            self.isLoadingBuzzer = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
 
                [self.tableView reloadData];
            });
            DLog(@"buzzer state:%i",state);
            
        }
            break;
        
        case RET_SET_NPCSETTINGS_BUZZER:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingBuzzer = NO;
            if(result==0){
                self.lastBuzzerState = self.buzzerState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastBuzzerState==SETTING_VALUE_BUZZER_STATE_OFF){
                        self.buzzerState = self.lastBuzzerState;
                        self.buzzerSwitch.on = NO;
                        
                    }else if(self.lastMotionState!=SETTING_VALUE_MOTION_STATE_OFF){
                        self.motionState = self.lastMotionState;
                        self.motionSwitch.on = YES;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_ALARM_EMAIL:
        {
            NSString *email = [parameter valueForKey:@"email"];
            
            if ([email isEqualToString:@"0"]) {
                self.bindEmail = nil;
            }else{
                self.bindEmail = email;
            }
            self.isLoadingBindEmail = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            DLog(@"alarm email:%@",email);
        }
            break;
        case RET_GET_BIND_ACCOUNT:
        {
            LoginResult *loginResult = [UDManager getLoginInfo];
            //NSInteger count = [[parameter valueForKey:@"count"] integerValue];
            NSInteger maxCount = [[parameter valueForKey:@"maxCount"] integerValue];
            NSArray *datas = [parameter valueForKey:@"datas"];
            
            self.maxBindIdCount = maxCount;
            self.bindIds = [NSMutableArray arrayWithArray:datas];
            
            if (self.bindIds.count==0) {
                self.alarmState = SETTING_VALUE_ALARM_STATE_OFF;
            }else if (self.bindIds.count>0){
                if ([self.bindIds containsObject:[NSNumber numberWithInt:loginResult.contactId.intValue]]) {
                    self.alarmState = SETTING_VALUE_ALARM_STATE_ON;
                }else{
                    self.alarmState = SETTING_VALUE_ALARM_STATE_OFF;
                }
            }
            
            self.isLoadingAlarmState = NO;
            self.isLoadingBindId = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }
            break;
        case RET_SET_BIND_ACCOUNT:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
           
            if(result==0){
                self.bindIds = [NSMutableArray arrayWithArray:self.lastSetBindIds];
                self.lastAlarmState = self.alarmState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.isLoadingAlarmState = NO;
                    
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_NPCSETTINGS_HUMAN_INFRARED:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            self.isSupportHI_WI_WO = YES;
            self.humanInfraredState = state;
            self.lastHumanInfraredState = state;
            self.isLoadingHumanInfrared = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"human infrared state:%i",state);
            
        }
            break;
        case RET_SET_NPCSETTINGS_HUMAN_INFRARED:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingHumanInfrared = NO;
            if(result==0){
                self.lastHumanInfraredState = self.humanInfraredState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastHumanInfraredState==SETTING_VALUE_HUMAN_INFRARED_STATE_ON){
                        self.humanInfraredState = self.lastHumanInfraredState;
                        self.humanInfraredSwitch.on = YES;
                        
                    }else if(self.lastHumanInfraredState==SETTING_VALUE_HUMAN_INFRARED_STATE_OFF){
                        self.humanInfraredState = self.lastHumanInfraredState;
                        self.humanInfraredSwitch.on = NO;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_NPCSETTINGS_WIRED_ALARM_INPUT:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            
            self.wiredAlarmInputState = state;
            self.lastWiredAlarmInputState = state;
            self.isLoadingWiredAlarmInput = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"wired alarm input state:%i",state);
            
        }
            break;
        case RET_SET_NPCSETTINGS_WIRED_ALARM_INPUT:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingWiredAlarmInput = NO;
            if(result==0){
                self.lastWiredAlarmInputState = self.wiredAlarmInputState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastWiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_ON){
                        self.wiredAlarmInputState = self.lastWiredAlarmInputState;
                        self.wiredAlarmInputSwitch.on = YES;
                        
                    }else if(self.lastWiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_OFF){
                        self.wiredAlarmInputState = self.lastWiredAlarmInputState;
                        self.wiredAlarmInputSwitch.on = NO;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_NPCSETTINGS_WIRED_ALARM_OUTPUT:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            
            self.wiredAlarmOutputState = state;
            self.lastWiredAlarmOutputState = state;
            self.isLoadingWiredAlarmOutput = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"wired alarm output state:%i",state);
            
        }
            break;
        case RET_SET_NPCSETTINGS_WIRED_ALARM_OUTPUT:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingWiredAlarmOutput = NO;
            if(result==0){
                self.lastWiredAlarmOutputState = self.wiredAlarmOutputState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastWiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_ON){
                        self.wiredAlarmOutputState = self.lastWiredAlarmOutputState;
                        self.wiredAlarmOutputSwitch.on = YES;
                        
                    }else if(self.lastWiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_OFF){
                        self.wiredAlarmOutputState = self.lastWiredAlarmOutputState;
                        self.wiredAlarmOutputSwitch.on = NO;
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
        case ACK_RET_GET_NPC_SETTINGS:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend get npc settings");
                    [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_GET_NPC_SETTINGS:%i",result);
        }
            break;
            
        case ACK_RET_SET_NPCSETTINGS_MOTION:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set motion state");
                    [[P2PClient sharedClient] setMotionWithId:self.contact.contactId password:self.contact.contactPassword state:self.motionState];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_MOTION:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_BUZZER:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set buzzer state");
                    [[P2PClient sharedClient] setBuzzerWithId:self.contact.contactId password:self.contact.contactPassword state:self.buzzerState];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_BUZZER:%i",result);
        }
            break;
        case ACK_RET_GET_ALARM_EMAIL:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend get alarm email");
                    [[P2PClient sharedClient] getAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_GET_ALARM_EMAIL:%i",result);
        }
            break;
        case ACK_RET_GET_BIND_ACCOUNT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend get bind account");
                    [[P2PClient sharedClient] getBindAccountWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_GET_BIND_ACCOUNT:%i",result);
        }
            break;
        case ACK_RET_SET_BIND_ACCOUNT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set bind account");
                    [[P2PClient sharedClient] setBindAccountWithId:self.contact.contactId password:self.contact.contactPassword datas:self.lastSetBindIds];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_SET_BIND_ACCOUNT:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_HUMAN_INFRARED:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set human infrared state");
                    [[P2PClient sharedClient] setHumanInfraredWithId:self.contact.contactId password:self.contact.contactPassword state:self.humanInfraredState];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_MOTION:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_INPUT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set wired alarm input state");
                    [[P2PClient sharedClient] setWiredAlarmInputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmInputState];
                }
                
                
            });

            DLog(@"ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_INPUT:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_OUTPUT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend set wired alarm output state");
                    [[P2PClient sharedClient] setWiredAlarmOutputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmOutputState];
                }
                
                
            });
 
            DLog(@"ACK_RET_SET_NPCSETTINGS_WIRED_ALARM_OUTPUT:%i",result);
        }
            break;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initComponent];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initComponent{
    [self.view setBackgroundColor:XBgColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"alarm_set",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [contentView addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [contentView addSubview:self.progressAlert];
    [self.view addSubview:contentView];
}

-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.isSupportHI_WI_WO){
        return 8;
    }else{
        return 5;
    }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch(section){
        case 0:
        {
            return 1;
        }
            break;
        case 1:
        {
//            if(self.isLoadingBindId){
//                return 1;
//            }else{
//                return [self.bindIds count]+1;
//            }
            return 1;
        }
            break;
        case 2:
        {
            return 1;
        }
            break;
        case 3:
        {
            return 1;
        }
            break;
        case 4:
        {
            if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_OFF){
                return 1;
            }else{
                return 2;
            }
        }
            break;
        case 5:
        {
            return 1;
        }
            break;
        case 6:
        {
            return 1;
        }
            break;
        case 7:
        {
            return 1;
        }
            break;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
    if(indexPath.section==4&&indexPath.row==1){
        return BAR_BUTTON_HEIGHT*2;
    }else{
        return BAR_BUTTON_HEIGHT;
    }
    
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==4){
        return NO;
    }else if(indexPath.section==3){
        return NO;
    }else if(indexPath.section==5){
        return NO;
    }else if(indexPath.section==6){
        return NO;
    }else if(indexPath.section==7){
        return NO;
    }else{
        return YES;
    }
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PSwitchCell";
    static NSString *identifier2 = @"P2PBuzzerCell";
    static NSString *identifier3 = @"P2PEmailSettingCell";
    //CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    UITableViewCell *cell = nil;
    
    
    int section = indexPath.section;
    int row = indexPath.row;
    UIImage *backImg;
    UIImage *backImg_p;
    
    
    if (section==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }else if(section==1){
//        cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
//        if(cell==nil){
//            cell = [[[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
//            [cell setBackgroundColor:XBGAlpha];
//        }
        cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
        if(cell==nil){
            cell = [[[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }else if(section==2){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
        if(cell==nil){
            cell = [[[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }else if(section==3){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }else if(section==4){
        if(indexPath.row==0){
            cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
            if(cell==nil){
                cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
                [cell setBackgroundColor:XBGAlpha];
            }
        }else if(indexPath.row==1){
            cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
            if(cell==nil){
                cell = [[[P2PBuzzerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
                [cell setBackgroundColor:XBGAlpha];
            }
        }
    }else if(section==5){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }else if(section==6){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }else if(section==7){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }
    
    
    
    switch (section) {
        case 0:
        {
            backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
            
            P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
            [cell2 setLeftLabelText:NSLocalizedString(@"accept_alarm", nil)];
            cell2.delegate = self;
            cell2.indexPath = indexPath;
            
            self.alarmSwitch = cell2.switchView;
            if(self.isLoadingAlarmState){
                [cell2 setProgressViewHidden:NO];
                [cell2 setSwitchViewHidden:YES];
            }else{
                [cell2 setProgressViewHidden:YES];
                [cell2 setSwitchViewHidden:NO];
                if(self.alarmState==SETTING_VALUE_ALARM_STATE_ON){
                    cell2.on = YES;
                }else{
                    cell2.on = NO;
                }
                
            }
        }
            break;
        case 1:
        {
//            if(self.isLoadingBindId){
//                if(row==0){
//                    backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
//                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
//                }
//            }else{
//                
//                
//                
//                if([self.bindIds count]>0){
//                    if(row==0){
//                        backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
//                        backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
//                    }else if(row<[self.bindIds count]){
//                        backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
//                        backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];
//                    }else{
//                        backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
//                        backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
//                    }
//                    
//                }else{
//                    backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
//                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
//                }
//                
//            }
//            
//            P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
//            if(row==0){
//                [emailCell setLeftLabelText:NSLocalizedString(@"bind_account", nil)];
//                [emailCell setRightIcon:@"ic_add_alarm_id.png"];
//                if(self.isLoadingBindId){
//                    [emailCell setLeftLabelHidden:NO];
//                    [emailCell setLeftIconHidden:YES];
//                    [emailCell setRightIconHidden:YES];
//                    [emailCell setRightLabelHidden:YES];
//                    [emailCell setProgressViewHidden:NO];
//                }else{
//                    [emailCell setLeftLabelHidden:NO];
//                    [emailCell setLeftIconHidden:YES];
//                    [emailCell setRightIconHidden:NO];
//                    [emailCell setRightLabelHidden:YES];
//                    [emailCell setProgressViewHidden:YES];
//                }
//            }
//            
//            if(row>0){
//                [emailCell setLeftIcon:@"ic_delete_alarm_id.png"];
//                [emailCell setLeftIconHidden:NO];
//                [emailCell setLeftLabelHidden:YES];
//                [emailCell setRightIconHidden:YES];
//                [emailCell setRightLabelHidden:NO];
//                [emailCell setProgressViewHidden:YES];
//                NSNumber *bindId = [self.bindIds objectAtIndex:row-1];
//                [emailCell setRightLabelText:[NSString stringWithFormat:@"0%i",[bindId intValue]]];
//            }
            
            
            backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
            P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
            [emailCell setRightIcon:@"ic_arrow.png"];
            [emailCell setLeftIconHidden:YES];
            [emailCell setLeftLabelHidden:NO];
            [emailCell setRightIconHidden:NO];
            [emailCell setRightLabelHidden:NO];
            [emailCell setProgressViewHidden:YES];
            [emailCell setLeftLabelText:NSLocalizedString(@"alarm_push", nil)];
            
        }
            break;
        case 2:
        {
            backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
            P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
            [emailCell setRightIcon:@"ic_arrow.png"];
            if(self.isLoadingBindEmail){
                [emailCell setLeftIconHidden:YES];
                [emailCell setLeftLabelHidden:NO];
                [emailCell setRightIconHidden:YES];
                [emailCell setRightLabelHidden:YES];
                [emailCell setProgressViewHidden:NO];
            }else{
                [emailCell setLeftIconHidden:YES];
                [emailCell setLeftLabelHidden:NO];
                [emailCell setRightIconHidden:NO];
                [emailCell setRightLabelHidden:NO];
                [emailCell setProgressViewHidden:YES];
                if(self.bindEmail&&self.bindEmail.length>0){
                    [emailCell setRightLabelText:self.bindEmail];
                }else{
                    [emailCell setRightLabelText:NSLocalizedString(@"unbind", nil)];
                }
            }
            [emailCell setLeftLabelText:NSLocalizedString(@"alarm_email", nil)];
            
        }
            break;
        case 3:
        {
            backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
            
            P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
            [cell2 setLeftLabelText:NSLocalizedString(@"motion", nil)];
            cell2.delegate = self;
            cell2.indexPath = indexPath;
            
            self.motionSwitch = cell2.switchView;
            if(self.isLoadingMotionDetect){
                [cell2 setProgressViewHidden:NO];
                [cell2 setSwitchViewHidden:YES];
            }else{
                [cell2 setProgressViewHidden:YES];
                [cell2 setSwitchViewHidden:NO];
                if(self.motionState==SETTING_VALUE_MOTION_STATE_ON){
                    cell2.on = YES;
                }else{
                    cell2.on = NO;
                }
                
            }
        }
            break;
        case 4:
        {

            if(row==0){
                
                if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_OFF){
                    backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                }else{
                    backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                }
                P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
                [cell2 setLeftLabelText:NSLocalizedString(@"buzzer", nil)];
                cell2.delegate = self;
                cell2.indexPath = indexPath;
                self.buzzerSwitch = cell2.switchView;
                if(self.isLoadingBuzzer){
                    [cell2 setProgressViewHidden:NO];
                    [cell2 setSwitchViewHidden:YES];
                }else{
                    [cell2 setProgressViewHidden:YES];
                    [cell2 setSwitchViewHidden:NO];
                    if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_OFF){
                        cell2.on = NO;
                    }else{
                        cell2.on = YES;
                    }
                
                }
            }else{
                backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
                P2PBuzzerCell *buzzerCell = (P2PBuzzerCell*)cell;
                [buzzerCell setLeftLabelText:NSLocalizedString(@"buzzer_time", nil)];
                [buzzerCell.radio1 addTarget:self action:@selector(onRadio1Press:) forControlEvents:UIControlEventTouchUpInside];
                [buzzerCell.radio2 addTarget:self action:@selector(onRadio2Press:) forControlEvents:UIControlEventTouchUpInside];
                [buzzerCell.radio3 addTarget:self action:@selector(onRadio3Press:) forControlEvents:UIControlEventTouchUpInside];
                
                self.radio1 = buzzerCell.radio1;
                self.radio2 = buzzerCell.radio2;
                self.radio3 = buzzerCell.radio3;
                if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_ON_ONE){
                    [buzzerCell setSelectedIndex:0];
                }else if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_ON_TWO){
                    [buzzerCell setSelectedIndex:1];
                }else if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_ON_THREE){
                    [buzzerCell setSelectedIndex:2];
                }
            }
        }
            break;
        case 5:
        {
            backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
            
            P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
            [cell2 setLeftLabelText:NSLocalizedString(@"human_infrared", nil)];
            cell2.delegate = self;
            cell2.indexPath = indexPath;
            self.humanInfraredSwitch = cell2.switchView;
            if(self.isLoadingHumanInfrared){
                [cell2 setProgressViewHidden:NO];
                [cell2 setSwitchViewHidden:YES];
            }else{
                [cell2 setProgressViewHidden:YES];
                [cell2 setSwitchViewHidden:NO];
                if(self.humanInfraredState==SETTING_VALUE_HUMAN_INFRARED_STATE_ON){
                    cell2.on = YES;
                }else{
                    cell2.on = NO;
                }
                
            }
        }
            break;
        case 6:
        {
            backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
            
            P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
            [cell2 setLeftLabelText:NSLocalizedString(@"wired_alarm_input", nil)];
            cell2.delegate = self;
            cell2.indexPath = indexPath;
            self.wiredAlarmInputSwitch = cell2.switchView;
            if(self.isLoadingWiredAlarmInput){
                [cell2 setProgressViewHidden:NO];
                [cell2 setSwitchViewHidden:YES];
            }else{
                [cell2 setProgressViewHidden:YES];
                [cell2 setSwitchViewHidden:NO];
                if(self.wiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_ON){
                    cell2.on = YES;
                }else{
                    cell2.on = NO;
                }
                
            }
        }
            break;
        case 7:
        {
            backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
            
            P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
            [cell2 setLeftLabelText:NSLocalizedString(@"wired_alarm_output", nil)];
            cell2.delegate = self;
            cell2.indexPath = indexPath;
            self.wiredAlarmOutputSwitch = cell2.switchView;
            if(self.isLoadingWiredAlarmOutput){
                [cell2 setProgressViewHidden:NO];
                [cell2 setSwitchViewHidden:YES];
            }else{
                [cell2 setProgressViewHidden:YES];
                [cell2 setSwitchViewHidden:NO];
                if(self.wiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_ON){
                    cell2.on = YES;
                }else{
                    cell2.on = NO;
                }
                
            }
        }
            break;
    }
    
    
    
    UIImageView *backImageView = [[UIImageView alloc] init];
    
    
    
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backImageView.image = backImg;
    [cell setBackgroundView:backImageView];
    [backImageView release];
    
    UIImageView *backImageView_p = [[UIImageView alloc] init];
    
    backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.5 topCapHeight:backImg_p.size.height*0.5];
    backImageView_p.image = backImg_p;
    [cell setSelectedBackgroundView:backImageView_p];
    [backImageView_p release];
    
    
    
    
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section==1){
//        if(indexPath.row==0){
//            if([self.bindIds count]<self.maxBindIdCount){
//                AddBindAccountController *addBindAccountController = [[AddBindAccountController alloc] init];
//                addBindAccountController.contact = self.contact;
//                addBindAccountController.alarmSettingController = self;
//                [self.navigationController pushViewController:addBindAccountController animated:YES];
//                [addBindAccountController release];
//            }else{
//                [self.view makeToast:[NSString stringWithFormat:@"%@ %i %@",NSLocalizedString(@"add_bind_account_prompt1", nil),self.maxBindIdCount,NSLocalizedString(@"add_bind_account_prompt2", nil)]];
//            }
//        }else{
//            UIAlertView *unBindAccountAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sure_to_unbind_account", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
//            unBindAccountAlert.tag = ALERT_TAG_UNBIND_ALARM_ID;
//            self.selectedUnbindAccountIndex = indexPath.row - 1;
//            [unBindAccountAlert show];
//            [unBindAccountAlert release];
//        }
        
        if (self.bindIds.count > 0) {//无报警推送账号
            AlarmAccountController * alarmAccountController = [[AlarmAccountController alloc]init];
            //        alarmAccountController.bindIds = self.bindIds;
            alarmAccountController.alarmSettingController = self;//刷新报警设置界面
            alarmAccountController.contact = self.contact;
            [self.navigationController  pushViewController:alarmAccountController animated:YES];
            [alarmAccountController release];
        }else{
            [self.view makeToast:NSLocalizedString(@"no_alarm_push_id", nil)];
        }
        
    }else if(indexPath.section==2&&!self.isLoadingBindEmail){
//        if(self.bindEmail&&self.bindEmail.length>0){
//            UIAlertView *unBindEmailAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sure_to_unbind_email", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
//            unBindEmailAlert.tag = ALERT_TAG_UNBIND_EMAIL;
//            [unBindEmailAlert show];
//            [unBindEmailAlert release];
//        }
        BindAlarmEmailController *bindAlarmEmailController = [[BindAlarmEmailController alloc] init];
        bindAlarmEmailController.contact = self.contact;
        bindAlarmEmailController.alarmSettingController = self;
        [self.navigationController pushViewController:bindAlarmEmailController animated:YES];
        [bindAlarmEmailController release];
    }
}

/*
 *删除绑定帐号
 */
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    switch(alertView.tag){
//        case ALERT_TAG_UNBIND_ALARM_ID:
//        {
//            if(buttonIndex==1){
//                
//                NSMutableArray *datas = [NSMutableArray arrayWithArray:self.bindIds];
//                [datas removeObjectAtIndex:self.selectedUnbindAccountIndex];
//                self.lastSetBindIds = [NSMutableArray arrayWithArray:datas];
//                self.progressAlert.dimBackground = YES;
//                [self.progressAlert show:YES];
//                [[P2PClient sharedClient] setBindAccountWithId:self.contact.contactId password:self.contact.contactPassword datas:self.lastSetBindIds];
//            }
//        }
//            break;
//        
//    }
//}

-(void)onSwitchValueChange:(UISwitch *)sender indexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            if (self.bindIds.count<self.maxBindIdCount) {
                if(self.alarmState==SETTING_VALUE_ALARM_STATE_OFF&&sender.on){
                    self.isLoadingAlarmState = YES;
                    
                    self.lastAlarmState = self.alarmState;
                    self.alarmState = SETTING_VALUE_ALARM_STATE_ON;
                    [self.tableView reloadData];
                    LoginResult *loginResult = [UDManager getLoginInfo];
                    [self.bindIds addObject:[NSNumber numberWithInt:loginResult.contactId.intValue]];
                    self.lastSetBindIds = [NSMutableArray arrayWithArray:self.bindIds];
                    
                    [[P2PClient sharedClient] setBindAccountWithId:self.contact.contactId password:self.contact.contactPassword datas:self.lastSetBindIds];
                    
                }else if(self.alarmState==SETTING_VALUE_ALARM_STATE_ON&&!sender.on){
                    self.isLoadingAlarmState = YES;
                    
                    self.lastAlarmState = self.alarmState;
                    self.alarmState = SETTING_VALUE_ALARM_STATE_OFF;
                    [self.tableView reloadData];
                    NSMutableArray *datas = [NSMutableArray arrayWithArray:self.bindIds];
                    LoginResult *loginResult = [UDManager getLoginInfo];
                    [datas removeObject:[NSNumber numberWithInt:loginResult.contactId.intValue]];
                    self.lastSetBindIds = [NSMutableArray arrayWithArray:datas];
                    [[P2PClient sharedClient] setBindAccountWithId:self.contact.contactId password:self.contact.contactPassword datas:self.lastSetBindIds];
                }
                
            }else{
                
                if(self.alarmState==SETTING_VALUE_ALARM_STATE_OFF&&sender.on){
                    self.alarmState = SETTING_VALUE_ALARM_STATE_OFF;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        [self.view makeToast:[NSString stringWithFormat:@"%@ %i %@",NSLocalizedString(@"add_bind_account_prompt1", nil),self.maxBindIdCount,NSLocalizedString(@"add_bind_account_prompt2", nil)]];
                    });
                    
                    
                }else if(self.alarmState==SETTING_VALUE_ALARM_STATE_ON&&!sender.on){
                    self.isLoadingAlarmState = YES;
                    
                    self.lastAlarmState = self.alarmState;
                    self.alarmState = SETTING_VALUE_ALARM_STATE_OFF;
                    [self.tableView reloadData];
                    NSMutableArray *datas = [NSMutableArray arrayWithArray:self.bindIds];
                    LoginResult *loginResult = [UDManager getLoginInfo];
                    [datas removeObject:[NSNumber numberWithInt:loginResult.contactId.intValue]];
                    self.lastSetBindIds = [NSMutableArray arrayWithArray:datas];
                    [[P2PClient sharedClient] setBindAccountWithId:self.contact.contactId password:self.contact.contactPassword datas:self.lastSetBindIds];
                }
                
            }
            
        }
            break;
        case 3:
        {
            if(self.motionState==SETTING_VALUE_MOTION_STATE_OFF&&sender.on){
                self.isLoadingMotionDetect = YES;
                
                self.lastMotionState = self.motionState;
                self.motionState = SETTING_VALUE_MOTION_STATE_ON;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setMotionWithId:self.contact.contactId password:self.contact.contactPassword state:self.motionState];
            }else if(self.motionState==SETTING_VALUE_MOTION_STATE_ON&&!sender.on){
                self.isLoadingMotionDetect = YES;
                
                self.lastMotionState = self.motionState;
                self.motionState = SETTING_VALUE_MOTION_STATE_OFF;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setMotionWithId:self.contact.contactId password:self.contact.contactPassword state:self.motionState];
            }
        }
            break;
        case 4:
        {
            if(indexPath.row==0){
                if(self.buzzerState==SETTING_VALUE_BUZZER_STATE_OFF&&sender.on){
                    self.isLoadingBuzzer = YES;
                    
                    self.lastBuzzerState = self.buzzerState;
                    self.buzzerState = SETTING_VALUE_BUZZER_STATE_ON_ONE;
                    [self.tableView reloadData];
                    [[P2PClient sharedClient] setBuzzerWithId:self.contact.contactId password:self.contact.contactPassword state:self.buzzerState];
                }else if(self.buzzerState!=SETTING_VALUE_BUZZER_STATE_OFF&&!sender.on){
                    self.isLoadingBuzzer = YES;
                    
                    self.lastBuzzerState = self.buzzerState;
                    self.buzzerState = SETTING_VALUE_BUZZER_STATE_OFF;
                    [self.tableView reloadData];
                    [[P2PClient sharedClient] setBuzzerWithId:self.contact.contactId password:self.contact.contactPassword state:self.buzzerState];
                }
            }
        }
            break;
        case 5:
        {
            if(self.humanInfraredState==SETTING_VALUE_HUMAN_INFRARED_STATE_OFF&&sender.on){
                self.isLoadingHumanInfrared = YES;
                
                self.lastHumanInfraredState = self.humanInfraredState;
                self.humanInfraredState = SETTING_VALUE_HUMAN_INFRARED_STATE_ON;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setHumanInfraredWithId:self.contact.contactId password:self.contact.contactPassword state:self.humanInfraredState];
            }else if(self.humanInfraredState==SETTING_VALUE_HUMAN_INFRARED_STATE_ON&&!sender.on){
                self.isLoadingHumanInfrared = YES;
                
                self.lastHumanInfraredState = self.humanInfraredState;
                self.humanInfraredState = SETTING_VALUE_HUMAN_INFRARED_STATE_OFF;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setHumanInfraredWithId:self.contact.contactId password:self.contact.contactPassword state:self.humanInfraredState];
            }
        }
            break;
        case 6:
        {
            if(self.wiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_OFF&&sender.on){
                self.isLoadingWiredAlarmInput = YES;
                
                self.lastWiredAlarmInputState = self.wiredAlarmInputState;
                self.wiredAlarmInputState = SETTING_VALUE_WIRED_ALARM_INPUT_STATE_ON;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setWiredAlarmInputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmInputState];
            }else if(self.wiredAlarmInputState==SETTING_VALUE_WIRED_ALARM_INPUT_STATE_ON&&!sender.on){
                self.isLoadingWiredAlarmInput = YES;
                
                self.lastWiredAlarmInputState = self.wiredAlarmInputState;
                self.wiredAlarmInputState = SETTING_VALUE_WIRED_ALARM_INPUT_STATE_OFF;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setWiredAlarmInputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmInputState];
            }
        }
            break;
        case 7:
        {
            if(self.wiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_OFF&&sender.on){
                self.isLoadingWiredAlarmOutput = YES;
                
                self.lastWiredAlarmOutputState = self.wiredAlarmOutputState;
                self.wiredAlarmOutputState = SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_ON;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setWiredAlarmOutputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmOutputState];
            }else if(self.wiredAlarmOutputState==SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_ON&&!sender.on){
                self.isLoadingWiredAlarmOutput = YES;
                
                self.lastWiredAlarmOutputState = self.wiredAlarmOutputState;
                self.wiredAlarmOutputState = SETTING_VALUE_WIRED_ALARM_OUTPUT_STATE_OFF;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setWiredAlarmOutputWithId:self.contact.contactId password:self.contact.contactPassword state:self.wiredAlarmOutputState];
            }
        }
            break;
            
        default:
            break;
    }
}

-(void)onMotionChange:(UISwitch*)sender{
    if(self.motionState==SETTING_VALUE_MOTION_STATE_OFF&&sender.on){
        self.isLoadingMotionDetect = YES;
        
        self.lastMotionState = self.motionState;
        self.motionState = SETTING_VALUE_MOTION_STATE_ON;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setMotionWithId:self.contact.contactId password:self.contact.contactPassword state:self.motionState];
    }else if(self.motionState==SETTING_VALUE_MOTION_STATE_ON&&!sender.on){
        self.isLoadingMotionDetect = YES;
        
        self.lastMotionState = self.motionState;
        self.motionState = SETTING_VALUE_MOTION_STATE_OFF;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setMotionWithId:self.contact.contactId password:self.contact.contactPassword state:self.motionState];
    }

}


-(void)onRadio1Press:(id)sender{
    if(!self.isLoadingBuzzer&&!self.radio1.isSelected){
        [self.radio1 setSelected:YES];
        [self.radio2 setSelected:NO];
        [self.radio3 setSelected:NO];
        self.isLoadingBuzzer = YES;
        [self.tableView reloadData];
        self.lastBuzzerState = self.buzzerState;
        self.buzzerState = SETTING_VALUE_BUZZER_STATE_ON_ONE;
        [[P2PClient sharedClient] setBuzzerWithId:self.contact.contactId password:self.contact.contactPassword state:self.buzzerState];
        
    }
}

-(void)onRadio2Press:(id)sender{
    if(!self.isLoadingBuzzer&&!self.radio2.isSelected){
        [self.radio1 setSelected:NO];
        [self.radio2 setSelected:YES];
        [self.radio3 setSelected:NO];
        self.isLoadingBuzzer = YES;
        [self.tableView reloadData];
        self.lastBuzzerState = self.buzzerState;
        self.buzzerState = SETTING_VALUE_BUZZER_STATE_ON_TWO;
        [[P2PClient sharedClient] setBuzzerWithId:self.contact.contactId password:self.contact.contactPassword state:self.buzzerState];
        
    }
}
-(void)onRadio3Press:(id)sender{
    if(!self.isLoadingBuzzer&&!self.radio3.isSelected){
        [self.radio1 setSelected:NO];
        [self.radio2 setSelected:NO];
        [self.radio3 setSelected:YES];
        self.isLoadingBuzzer = YES;
        [self.tableView reloadData];
        self.lastBuzzerState = self.buzzerState;
        self.buzzerState = SETTING_VALUE_BUZZER_STATE_ON_THREE;
        [[P2PClient sharedClient] setBuzzerWithId:self.contact.contactId password:self.contact.contactPassword state:self.buzzerState];
        
    }
}



-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
    return (interface == UIInterfaceOrientationPortrait );
}

#ifdef IOS6

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
@end
