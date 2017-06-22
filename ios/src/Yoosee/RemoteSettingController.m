//
//  RemoteSettingController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-16.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "RemoteSettingController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "TopBar.h"
#import "Toast+UIView.h"
#import "Contact.h"
#import "P2PClient.h"
#import "P2PSwitchCell.h"
@interface RemoteSettingController ()

@end

@implementation RemoteSettingController
-(void)dealloc{

    [self.tableView release];
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
    
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    self.isLoadingRemoteDefence = YES;
    self.isLoadingRemoteRecord = YES;
    self.remoteDefenceState = SETTING_VALUE_REMOTE_DEFENCE_STATE_OFF;
    self.remoteRecordState = SETTING_VALUE_REMOTE_RECORD_STATE_OFF;
    [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
}
    
-(void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}
    
- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_GET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            
            self.remoteDefenceState = state;
            self.isLoadingRemoteDefence = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"remote defence state:%i",state);
            
        }
        break;
        case RET_GET_NPCSETTINGS_REMOTE_RECORD:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            
            self.remoteRecordState = state;
            self.isLoadingRemoteRecord = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"remote record state:%i",state);
            
        }
        break;
        case RET_SET_NPCSETTINGS_REMOTE_DEFENCE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingRemoteDefence = NO;
            DLog(@"defence result:%i",result);
            if(result==0){
                self.lastRemoteDefenceState = self.remoteDefenceState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.remoteDefenceState = self.lastRemoteDefenceState;
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
        break;
        case RET_SET_NPCSETTINGS_REMOTE_RECORD:
        {
            //NSInteger result = [[parameter valueForKey:@"result"] intValue];
            [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
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
        case ACK_RET_SET_NPCSETTINGS_REMOTE_DEFENCE:
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
                    DLog(@"resend set remote defence state");
                    [[P2PClient sharedClient] setRemoteDefenceWithId:self.contact.contactId password:self.contact.contactPassword state:self.remoteDefenceState];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_REMOTE_DEFENCE:%i",result);
        }
        break;
        case ACK_RET_SET_NPCSETTINGS_REMOTE_RECORD:
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
                    DLog(@"resend set remote record state");
                    [[P2PClient sharedClient] setRemoteRecordWithId:self.contact.contactId password:self.contact.contactPassword state:self.remoteRecordState];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_REMOTE_RECORD:%i",result);
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
        [topBar setTitle:NSLocalizedString(@"remote_set",nil)];
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
    return 1;
}
    
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}
    
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return BAR_BUTTON_HEIGHT;
    
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
        
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PSwitchCell";
    
    //CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    UITableViewCell *cell = nil;
    
    
    int section = indexPath.section;
    int row = indexPath.row;
    UIImage *backImg;
    UIImage *backImg_p;
    
    
    if(section==0){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
        
    }
    
    
    
    switch (section) {
        case 0:
        {
            P2PSwitchCell *switchCell = (P2PSwitchCell*)cell;
            if(row==0){
                backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                [switchCell setLeftLabelText:NSLocalizedString(@"remote_defence", nil)];
                if(self.isLoadingRemoteDefence){
                    [switchCell setProgressViewHidden:NO];
                    [switchCell setSwitchViewHidden:YES];
                }else{
                    [switchCell setProgressViewHidden:YES];
                    [switchCell setSwitchViewHidden:NO];
                    [switchCell.switchView addTarget:self action:@selector(onRemoteDefenceChange:) forControlEvents:UIControlEventValueChanged];
                    if(self.remoteDefenceState==SETTING_VALUE_REMOTE_DEFENCE_STATE_OFF){
                        switchCell.switchView.on = NO;
                    }else{
                        switchCell.switchView.on = YES;
                    }
                }
            }else if(row==1){
                backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
                [switchCell setLeftLabelText:NSLocalizedString(@"remote_record", nil)];
                if(self.isLoadingRemoteRecord){
                    [switchCell setProgressViewHidden:NO];
                    [switchCell setSwitchViewHidden:YES];
                }else{
                    [switchCell setProgressViewHidden:YES];
                    [switchCell setSwitchViewHidden:NO];
                    [switchCell.switchView addTarget:self action:@selector(onRemoteRecordChange:) forControlEvents:UIControlEventValueChanged];
                    if(self.remoteRecordState==SETTING_VALUE_REMOTE_RECORD_STATE_OFF){
                        switchCell.switchView.on = NO;
                    }else{
                        switchCell.switchView.on = YES;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)onRemoteDefenceChange:(UISwitch*)sender{
    if(self.remoteDefenceState==SETTING_VALUE_REMOTE_DEFENCE_STATE_OFF&&sender.on){
        self.isLoadingRemoteDefence = YES;
        
        self.lastRemoteDefenceState = self.remoteDefenceState;
        self.remoteDefenceState = SETTING_VALUE_REMOTE_DEFENCE_STATE_ON;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setRemoteDefenceWithId:self.contact.contactId password:self.contact.contactPassword state:self.remoteDefenceState];
    }else if(self.remoteDefenceState!=SETTING_VALUE_REMOTE_DEFENCE_STATE_OFF&&!sender.on){
        self.isLoadingRemoteDefence = YES;
        
        self.lastRemoteDefenceState = self.remoteDefenceState;
        self.remoteDefenceState = SETTING_VALUE_REMOTE_DEFENCE_STATE_OFF;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setRemoteDefenceWithId:self.contact.contactId password:self.contact.contactPassword state:self.remoteDefenceState];
    }
}
    
-(void)onRemoteRecordChange:(UISwitch*)sender{
    if(self.remoteRecordState==SETTING_VALUE_REMOTE_RECORD_STATE_OFF&&sender.on){
        self.isLoadingRemoteRecord = YES;
        
        self.lastRemoteRecordState = self.remoteRecordState;
        self.remoteRecordState = SETTING_VALUE_REMOTE_RECORD_STATE_ON;
        [self.tableView reloadData];
        
        [[P2PClient sharedClient] setRemoteRecordWithId:self.contact.contactId password:self.contact.contactPassword state:self.remoteRecordState];
    }else if(self.remoteRecordState!=SETTING_VALUE_REMOTE_RECORD_STATE_OFF&&!sender.on){
        self.isLoadingRemoteRecord = YES;
        
        self.lastRemoteRecordState = self.remoteRecordState;
        self.remoteRecordState = SETTING_VALUE_REMOTE_RECORD_STATE_OFF;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setRemoteRecordWithId:self.contact.contactId password:self.contact.contactPassword state:self.remoteRecordState];
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
