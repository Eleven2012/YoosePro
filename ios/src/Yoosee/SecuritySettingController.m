//
//  SecuritySettingController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "SecuritySettingController.h"
#import "P2PClient.h"
#import "Constants.h"
#import "Toast+UIView.h"
#import "P2PSettingCell.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "ModifyDevicePasswordController.h"
#import "ModifyVisitorPasswordController.h"
#import "P2PSwitchCell.h"
@interface SecuritySettingController ()

@end

@implementation SecuritySettingController

-(void)dealloc{
    [self.tableView release];
    [self.autoUpdateSwitch release];
    [self.contact release];
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

-(void)viewDidAppear:(BOOL)animated{
    DLog(@"%@",self.contact.contactPassword);
    [self.tableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated{
    if(!self.isFirstLoadingCompolete){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
        self.isLoadingAutoUpdate = YES;
        self.autoUpdateState = SETTING_VALUE_AUTO_UPDATE_STATE_OFF;
        
        [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
        self.isFirstLoadingCompolete = !self.isFirstLoadingCompolete;
    }
    
}


- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
            
        case RET_GET_NPCSETTINGS_AUTO_UPDATE:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            self.isSupportAutoUpdate = YES;
            self.autoUpdateState = state;
            self.lastAutoUpdateState = state;
            self.isLoadingAutoUpdate = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"auto update state:%i",state);
            
        }
            break;
        
        case RET_SET_NPCSETTINGS_AUTO_UPDATE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingAutoUpdate = NO;
            if(result==0){
                self.lastAutoUpdateState = self.autoUpdateState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastAutoUpdateState==SETTING_VALUE_AUTO_UPDATE_STATE_ON){
                        self.autoUpdateState = self.lastAutoUpdateState;
                        self.autoUpdateSwitch.on = YES;
                        
                    }else if(self.lastAutoUpdateState==SETTING_VALUE_AUTO_UPDATE_STATE_OFF){
                        self.autoUpdateState = self.lastAutoUpdateState;
                        self.autoUpdateSwitch.on = NO;
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
            
        case ACK_RET_SET_NPCSETTINGS_AUTO_UPDATE:
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
                    DLog(@"resend set auto update state");
                    [[P2PClient sharedClient] setMotionWithId:self.contact.contactId password:self.contact.contactPassword state:self.autoUpdateState];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_AUTO_UPDATE:%i",result);
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
    [topBar setTitle:NSLocalizedString(@"security_set",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    
    
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    
}

-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.isSupportAutoUpdate){
        return 3;
    }else{
        if (self.contact.contactType==CONTACT_TYPE_IPC || self.contact.contactType==CONTACT_TYPE_DOORBELL || self.contact.contactId.intValue<256) {//IP添加设备
            return 2;
        }else{
           return 1;
        }
    }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BAR_BUTTON_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PSettingCell";
    static NSString *identifier3 = @"P2PSwitchCell";
    //CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    int section = indexPath.section;
    int row = indexPath.row;
    UITableViewCell *cell = nil;
    
    if(section==0){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
        
    }else if(section==1){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }else if(section==2){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
        if(cell==nil){
            cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }
    
    
   
    
    UIImage *backImg;
    UIImage *backImg_p;
    
    switch (section) {
        case 0:
        {
            if(row==0){
                P2PSettingCell *settingCell = (P2PSettingCell*)cell;
                backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                [settingCell setLeftLabelHidden:NO];
                [settingCell setRightLabelHidden:YES];
                [settingCell setCustomViewHidden:YES];
                [settingCell setProgressViewHidden:YES];
                [settingCell setLeftLabelText:NSLocalizedString(@"modify_manager_password", nil)];
            }
            
        }
            break;
        case 1:
        {
            if(row==0){
                P2PSettingCell *settingCell = (P2PSettingCell*)cell;
                backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                [settingCell setLeftLabelHidden:NO];
                [settingCell setRightLabelHidden:YES];
                [settingCell setCustomViewHidden:YES];
                [settingCell setProgressViewHidden:YES];
                [settingCell setLeftLabelText:NSLocalizedString(@"modify_visitor_password", nil)];
            }
            
        }
            break;
        case 2:
        {
            if(row==0){
                backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                
                P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
                [cell2 setLeftLabelText:NSLocalizedString(@"auto_update", nil)];
                [cell2.switchView addTarget:self action:@selector(onAutoUpdateChange:) forControlEvents:UIControlEventValueChanged];
                self.autoUpdateSwitch = cell2.switchView;
                if(self.isLoadingAutoUpdate){
                    [cell2 setProgressViewHidden:NO];
                    [cell2 setSwitchViewHidden:YES];
                }else{
                    [cell2 setProgressViewHidden:YES];
                    [cell2 setSwitchViewHidden:NO];
                    if(self.autoUpdateState==SETTING_VALUE_MOTION_STATE_ON){
                        cell2.on = YES;
                    }else{
                        cell2.on = NO;
                    }
                    
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

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==2){
        return NO;
    }else{
        return YES;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section==0&&indexPath.row==0){
        ModifyDevicePasswordController *modifyDevicePasswordController = [[ModifyDevicePasswordController alloc] init];
        modifyDevicePasswordController.contact = self.contact;
        [self.navigationController pushViewController:modifyDevicePasswordController animated:YES];
        [modifyDevicePasswordController release];
    }else if(indexPath.section==1&&indexPath.row==0){
        ModifyVisitorPasswordController *modifyVisitorPasswordController = [[ModifyVisitorPasswordController alloc] init];
        modifyVisitorPasswordController.contact = self.contact;
        [self.navigationController pushViewController:modifyVisitorPasswordController animated:YES];
        [modifyVisitorPasswordController release];
    }
}


-(void)onAutoUpdateChange:(UISwitch*)sender{
    if(self.autoUpdateState==SETTING_VALUE_AUTO_UPDATE_STATE_OFF&&sender.on){
        self.isLoadingAutoUpdate = YES;
        
        self.lastAutoUpdateState = self.autoUpdateState;
        self.autoUpdateState = SETTING_VALUE_AUTO_UPDATE_STATE_ON;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setAutoUpdateWithId:self.contact.contactId password:self.contact.contactPassword state:self.autoUpdateState];
    }else if(self.autoUpdateState==SETTING_VALUE_AUTO_UPDATE_STATE_ON&&!sender.on){
        self.isLoadingAutoUpdate = YES;
        
        self.lastAutoUpdateState = self.autoUpdateState;
        self.autoUpdateState = SETTING_VALUE_AUTO_UPDATE_STATE_OFF;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setAutoUpdateWithId:self.contact.contactId password:self.contact.contactPassword state:self.autoUpdateState];
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
