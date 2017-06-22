//
//  TimeSettingController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "TimeSettingController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Constants.h"
#import "MyPickerView.h"
#import "P2PTimeSettingCell.h"
#import "Toast+UIView.h"
#import "Contact.h"
#import "Utils.h"
#import "TimezoneView.h"
#import "P2PTimezoneSettingCell.h"
@interface TimeSettingController ()

@end

@implementation TimeSettingController
-(void)dealloc{
    [self.time release];
    [self.picker release];

    [self.tableView release];
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
    self.tempTimezone = 0;
    [[P2PClient sharedClient] getDeviceTimeWithId:self.contact.contactId password:self.contact.contactPassword];
    
    [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
}


- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_GET_DEVICE_TIME:
        {
            
            NSString *time = [parameter valueForKey:@"time"];
            self.time = time;
            self.isInitTime = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            DLog(@"RET_GET_DEVICE_TIME");
        }
            break;
        case RET_SET_DEVICE_TIME:
        {
            NSInteger result = [[parameter valueForKey:@"result"] integerValue];
            if(result==0){
                NSString *time = [Utils getDeviceTimeByIntValue:self.lastSetDate.year month:self.lastSetDate.month day:self.lastSetDate.day hour:self.lastSetDate.hour minute:self.lastSetDate.minute];
                self.time = time;
                self.isInitTime = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                self.isInitTime = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_NPCSETTINGS_TIME_ZONE:
        {
            NSInteger value = [[parameter valueForKey:@"value"] intValue];
            
            self.isSupportTimezone = YES;
            self.isInitTimezone = YES;
            self.timezone = value;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"auto update state:%i",value);
            
        }
            break;
            
        case RET_SET_NPCSETTINGS_TIME_ZONE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] integerValue];
            if(result==0){
                self.timezone = self.lastSetTimezone;
                self.isInitTimezone = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                self.isInitTimezone = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{
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
        case ACK_RET_GET_DEVICE_TIME:
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
                    DLog(@"resend get device time");
                    [[P2PClient sharedClient] getDeviceTimeWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });

            DLog(@"ACK_RET_GET_DEVICE_TIME:%i",result);
        }
            break;
        case ACK_RET_SET_DEVICE_TIME:
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
                    DLog(@"resend set device time");
                    [[P2PClient sharedClient] setDeviceTimeWithId:self.contact.contactId password:self.contact.contactPassword year:self.lastSetDate.year month:self.lastSetDate.month day:self.lastSetDate.day hour:self.lastSetDate.hour minute:self.lastSetDate.minute];
                }
                
                
            });
        }
            break;
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
        case ACK_RET_SET_TIME_ZONE:
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
                    DLog(@"resend set time zone");
                    [[P2PClient sharedClient] setDeviceTimezoneWithId:self.contact.contactId password:self.contact.contactPassword value:self.lastSetTimezone];
                }
                
                
            });
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
    [topBar setTitle:NSLocalizedString(@"time_set",nil)];
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
    if(self.isSupportTimezone){
        return 2;
    }else{
        return 1;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PTimeSettingCell";
    static NSString *identifier2 = @"P2PTimezoneSettingCell";
    //CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    
    
    int section = indexPath.section;
    int row = indexPath.row;
    UIImage *backImg;
    UIImage *backImg_p;
    UITableViewCell *cell = nil;
    
    if(section==0){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PTimeSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
        
    }else if(section==1){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        if(cell==nil){
            cell = [[[P2PTimezoneSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }
    
    
    

    
    switch (section) {
        case 0:
        {
            P2PTimeSettingCell *timeCell = (P2PTimeSettingCell*)cell;
            if(row==0){
                backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                [timeCell setLeftLabelHidden:NO];
                [timeCell setRightLabelHidden:YES];
                [timeCell setCustomViewHidden:YES];
                [timeCell setProgressViewHidden:YES];
                [timeCell setLeftLabelText:NSLocalizedString(@"time_set", nil)];
                
            }else if(row==1){
                backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];
                
                [timeCell setLeftLabelHidden:YES];
                [timeCell setRightLabelHidden:YES];
                [timeCell setCustomViewHidden:NO];
                [timeCell setProgressViewHidden:YES];
                self.picker = timeCell.customView;
            }else if(row==2){
                backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
                [timeCell setLeftLabelHidden:NO];
                if(self.isInitTime){
                    [timeCell setRightLabelHidden:NO];
                    [timeCell setProgressViewHidden:YES];
                }else{
                    [timeCell setRightLabelHidden:YES];
                    [timeCell setProgressViewHidden:NO];
                }
                
                [timeCell setCustomViewHidden:YES];
                [timeCell setLeftLabelText:NSLocalizedString(@"apply", nil)];
                [timeCell setRightLabelText:self.time];
            }
            
        }
            break;
        case 1:
        {
            P2PTimezoneSettingCell *timezoneCell = (P2PTimezoneSettingCell*)cell;
            timezoneCell.OnTimezoneChange = ^(NSInteger timezone){
                self.tempTimezone = timezone;
            };
            if(row==0){
                backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                [timezoneCell setLeftLabelHidden:NO];
                [timezoneCell setRightLabelHidden:YES];
                [timezoneCell setCustomViewHidden:YES];
                [timezoneCell setProgressViewHidden:YES];
                [timezoneCell setLeftLabelText:NSLocalizedString(@"time_zone_set", nil)];
                
            }else if(row==1){
                backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];
                
                [timezoneCell setLeftLabelHidden:YES];
                [timezoneCell setRightLabelHidden:YES];
                [timezoneCell setCustomViewHidden:NO];
                [timezoneCell setProgressViewHidden:YES];
                
            }else if(row==2){
                backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
                [timezoneCell setLeftLabelHidden:NO];
                if(self.isInitTimezone){
                    [timezoneCell setRightLabelHidden:NO];
                    [timezoneCell setProgressViewHidden:YES];
                }else{
                    [timezoneCell setRightLabelHidden:YES];
                    [timezoneCell setProgressViewHidden:NO];
                }
                
                [timezoneCell setCustomViewHidden:YES];
                [timezoneCell setLeftLabelText:NSLocalizedString(@"apply", nil)];
                int value = self.timezone-11;
                if(value<0){
                    [timezoneCell setRightLabelText:[NSString stringWithFormat:@"UTC - %i",-value]];
                    
                }else{
                    [timezoneCell setRightLabelText:[NSString stringWithFormat:@"UTC + %i",value]];
                   
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row==1){
        return BAR_BUTTON_HEIGHT*3;
    }else{
        return BAR_BUTTON_HEIGHT;
    }
    
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==2){
        return YES;
    }else{
        return NO;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section==0&&indexPath.row==2&&self.isInitTime){
        _lastSetDate.year = self.picker.date.year;
        _lastSetDate.month = self.picker.date.month;
        _lastSetDate.day = self.picker.date.day;
        _lastSetDate.hour = self.picker.date.hour;
        _lastSetDate.minute = self.picker.date.minute;
        self.isInitTime = NO;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setDeviceTimeWithId:self.contact.contactId password:self.contact.contactPassword year:self.lastSetDate.year month:self.lastSetDate.month day:self.lastSetDate.day hour:self.lastSetDate.hour minute:self.lastSetDate.minute];
    }else if(indexPath.section==1&&indexPath.row==2&&self.isInitTimezone){
        
        self.lastSetTimezone = self.tempTimezone;
       
        self.isInitTimezone = NO;
        [self.tableView reloadData];
        [[P2PClient sharedClient] setDeviceTimezoneWithId:self.contact.contactId password:self.contact.contactPassword value:self.lastSetTimezone];
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
