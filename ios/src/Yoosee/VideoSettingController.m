//
//  VideoSettingController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "VideoSettingController.h"
#import "P2PClient.h"
#import "Constants.h"
#import "Toast+UIView.h"
#import "Contact.h"
#import "AppDelegate.h"
#import "P2PVideoFormatSettingCell.h"
#import "P2PVideoVolumeSettingCell.h"
#import "TopBar.h"
#import "RadioButton.h"
#import "P2PSwitchCell.h"
@interface VideoSettingController ()

@end

@implementation VideoSettingController
-(void)dealloc{
    [self.radio1 release];
    [self.radio2 release];
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
    self.isVideoVolumeLoading = YES;
    self.isVideoFormatLoading = YES;
    self.isLoadingImageInversion = YES;
    self.imageInversionState = SETTING_VALUE_IMAGE_INVERSION_STATE_OFF;
    [[P2PClient sharedClient] getNpcSettingsWithId:self.contact.contactId password:self.contact.contactPassword];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_GET_NPCSETTINGS_VIDEO_FORMAT:
        {
            
            NSInteger type = [[parameter valueForKey:@"type"] intValue];
            self.isInitNpcSettings = YES;
            self.isVideoFormatLoading = NO;
            self.videoType = type;
            self.lastSetVideoType = type;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"video type:%i",type);
            
        }
            break;
        case RET_GET_NPCSETTINGS_VIDEO_VOLUME:
        {
            NSInteger value = [[parameter valueForKey:@"value"] intValue];
            self.isInitNpcSettings = YES;
            self.isVideoVolumeLoading = NO;
            self.videoVolume = value;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"video volume:%i",value);
        }
            break;
        case RET_SET_NPCSETTINGS_VIDEO_FORMAT:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isVideoFormatLoading = NO;
            if(result==0){
                self.lastSetVideoType = self.videoType;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastSetVideoType==SETTING_VALUE_VIDEO_FORMAT_TYPE_NTSC){
                        self.videoType = self.lastSetVideoType;
                        [self.radio1 setSelected:NO];
                        [self.radio2 setSelected:YES];
                    }else if(self.lastSetVideoType==SETTING_VALUE_VIDEO_FORMAT_TYPE_PAL){
                        self.videoType = self.lastSetVideoType;
                        [self.radio1 setSelected:YES];
                        [self.radio2 setSelected:NO];
                    }
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_SET_NPCSETTINGS_VIDEO_VOLUME:
        {
            
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isVideoVolumeLoading = NO;
            if(result==0){
                self.lastSetVideoVolume = self.videoVolume;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.videoVolume = self.lastSetVideoVolume;
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_NPCSETTINGS_IMAGE_INVERSION:
        {
            NSInteger state = [[parameter valueForKey:@"state"] intValue];
            self.isSupportImageInversion = YES;
            self.imageInversionState = state;
            self.lastImageInversionState = state;
            self.isLoadingImageInversion = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //usleep(500000);
                [self.tableView reloadData];
            });
            DLog(@"image inversion state:%i",state);
            
        }
            break;
            
        case RET_SET_NPCSETTINGS_IMAGE_INVERSION:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            self.isLoadingImageInversion = NO;
            if(result==0){
                self.lastImageInversionState = self.imageInversionState;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
                
            }else{
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.lastImageInversionState==SETTING_VALUE_IMAGE_INVERSION_STATE_ON){
                        self.imageInversionState = self.lastImageInversionState;
                        self.imageInversionSwitch.on = YES;
                        
                    }else if(self.lastImageInversionState==SETTING_VALUE_IMAGE_INVERSION_STATE_OFF){
                        self.imageInversionState = self.lastImageInversionState;
                        self.imageInversionSwitch.on = NO;
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
        case ACK_RET_SET_NPCSETTINGS_VIDEO_FORMAT:
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
                    DLog(@"resend set video format");
                    [[P2PClient sharedClient] setVideoFormatWithId:self.contact.contactId password:self.contact.contactPassword type:self.lastSetVideoType];
                }
                
                
            });
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_VIDEO_FORMAT:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_VIDEO_VOLUME:
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
                    DLog(@"resend set video volume");
                    [[P2PClient sharedClient] setVideoVolumeWithId:self.contact.contactId password:self.contact.contactPassword value:self.videoVolume];
                }
                
                
            });
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_VIDEO_VOLUME:%i",result);
        }
            break;
        case ACK_RET_SET_NPCSETTINGS_IMAGE_INVERSION:
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
                    DLog(@"resend set image inversion state");
                    [[P2PClient sharedClient] setImageInversionWithId:self.contact.contactId password:self.contact.contactPassword state:self.imageInversionState];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_SET_NPCSETTINGS_IMAGE_INVERSION:%i",result);
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
    [topBar setTitle:NSLocalizedString(@"media_set",nil)];
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
    if(self.isSupportImageInversion){
        return 3;
    }else{
        return 2;
    }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch(section){
        case 0:
        {
            if(self.isInitNpcSettings){
                return 2;
            }else{
                return 1;
            }
        }
            break;
        case 1:
        {
            if(self.isInitNpcSettings){
                return 2;
            }else{
                return 1;
            }
        }
            break;
        case 2:
        {
            return 1;
        }
            break;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row==1){
        return BAR_BUTTON_HEIGHT*2;
    }else{
        return BAR_BUTTON_HEIGHT;
    }
    
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier1 = @"P2PSettingCell1";
    static NSString *identifier2 = @"P2PSettingCell2";
    static NSString *identifier3 = @"P2PSwitchCell";
    //CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    UITableViewCell *cell = nil;
    
    
    int section = indexPath.section;
    int row = indexPath.row;
    UIImage *backImg;
    UIImage *backImg_p;
    
    
    if(section==0){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[[P2PVideoFormatSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }else if(section==1){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        if(cell==nil){
            cell = [[[P2PVideoVolumeSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }else if(section==2){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
        if(cell==nil){
            cell = [[[P2PSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
            [cell setBackgroundColor:XBGAlpha];
        }
    }
    
    
    
    switch (section) {
        case 0:
        {
            P2PVideoFormatSettingCell *cell1 = (P2PVideoFormatSettingCell*)cell;
            
            if(row==0){
                
                [cell1 setLeftLabelHidden:NO];
                [cell1 setRightLabelHidden:YES];
                [cell1 setCustomViewHidden:YES];
                if(self.isInitNpcSettings){
                    backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                }else{
                    backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                }
                
                if(!self.isVideoFormatLoading){
                    [cell1 setProgressViewHidden:YES];
                }else{
                    [cell1 setProgressViewHidden:NO];
                }
                
                [cell1 setLeftLabelText:NSLocalizedString(@"video_format", nil)];
                
            }else if(row==1){
                backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
                
                [cell1 setLeftLabelHidden:YES];
                [cell1 setRightLabelHidden:YES];
                [cell1 setCustomViewHidden:NO];
                [cell1 setProgressViewHidden:YES];
                [cell1.radio1 addTarget:self action:@selector(onRadio1Press) forControlEvents:UIControlEventTouchUpInside];
                [cell1.radio2 addTarget:self action:@selector(onRadio2Press) forControlEvents:UIControlEventTouchUpInside];
                if(self.videoType==SETTING_VALUE_VIDEO_FORMAT_TYPE_NTSC){
                    [cell1 setSelectedIndex:1];
                }else if(self.videoType==SETTING_VALUE_VIDEO_FORMAT_TYPE_PAL){
                    [cell1 setSelectedIndex:0];
                }
                self.radio1 = cell1.radio1;
                self.radio2 = cell1.radio2;
            }
            
        }
            break;
        case 1:
        {
            P2PVideoVolumeSettingCell *cell2 = (P2PVideoVolumeSettingCell*)cell;
            if(row==0){
                
                [cell2 setLeftLabelHidden:NO];
                [cell2 setRightLabelHidden:YES];
                [cell2 setCustomViewHidden:YES];
                if(self.isInitNpcSettings){
                    backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                }else{
                    backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                }
                
                if(!self.isVideoVolumeLoading){
                    [cell2 setProgressViewHidden:YES];
                }else{
                    [cell2 setProgressViewHidden:NO];
                }
                
                [cell2 setLeftLabelText:NSLocalizedString(@"volume", nil)];
                
            }else if(row==1){
                backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
                
                [cell2 setLeftLabelHidden:YES];
                [cell2 setRightLabelHidden:YES];
                [cell2 setCustomViewHidden:NO];
                [cell2 setProgressViewHidden:YES];
                [cell2 setVolumeValue:self.videoVolume];
                [cell2.slider addTarget:self action:@selector(onSlider:) forControlEvents:UIControlEventValueChanged];
                [cell2.slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchUpOutside];
                [cell2.slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchUpInside];
                [cell2.slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchCancel];
            }
            
        }
            break;
        case 2:
        {
            if(row==0){
                backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                
                P2PSwitchCell *cell2 = (P2PSwitchCell*)cell;
                [cell2 setLeftLabelText:NSLocalizedString(@"image_inversion", nil)];
                cell2.delegate = self;
                cell2.indexPath = indexPath;
                self.imageInversionSwitch = cell2.switchView;
                if(self.isLoadingImageInversion){
                    [cell2 setProgressViewHidden:NO];
                    [cell2 setSwitchViewHidden:YES];
                }else{
                    [cell2 setProgressViewHidden:YES];
                    [cell2 setSwitchViewHidden:NO];
                    if(self.imageInversionState==SETTING_VALUE_IMAGE_INVERSION_STATE_ON){
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)onSwitchValueChange:(UISwitch *)sender indexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 2:
        {
            if(self.imageInversionState==SETTING_VALUE_IMAGE_INVERSION_STATE_OFF&&sender.on){
                self.isLoadingImageInversion = YES;
                
                self.lastImageInversionState = self.imageInversionState;
                self.imageInversionState = SETTING_VALUE_IMAGE_INVERSION_STATE_ON;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setImageInversionWithId:self.contact.contactId password:self.contact.contactPassword state:self.imageInversionState];
            }else if(self.imageInversionState==SETTING_VALUE_IMAGE_INVERSION_STATE_ON&&!sender.on){
                self.isLoadingImageInversion = YES;
                
                self.lastImageInversionState = self.imageInversionState;
                self.imageInversionState = SETTING_VALUE_IMAGE_INVERSION_STATE_OFF;
                [self.tableView reloadData];
                [[P2PClient sharedClient] setImageInversionWithId:self.contact.contactId password:self.contact.contactPassword state:self.imageInversionState];
            }
        }
            break;
    }
}

-(void)onRadio1Press{
    if(!self.isVideoFormatLoading&&!self.radio1.isSelected){
        [self.radio1 setSelected:YES];
        [self.radio2 setSelected:NO];
        self.isVideoFormatLoading = YES;
        [self.tableView reloadData];
        self.lastSetVideoType = self.videoType;
        self.videoType = SETTING_VALUE_VIDEO_FORMAT_TYPE_PAL;
        [[P2PClient sharedClient] setVideoFormatWithId:self.contact.contactId password:self.contact.contactPassword type:SETTING_VALUE_VIDEO_FORMAT_TYPE_PAL];
        
    }
}

-(void)onRadio2Press{
    if(!self.isVideoFormatLoading&&!self.radio2.isSelected){
        [self.radio1 setSelected:NO];
        [self.radio2 setSelected:YES];
        self.isVideoFormatLoading = YES;
        [self.tableView reloadData];
        self.lastSetVideoType = self.videoType;
        self.videoType = SETTING_VALUE_VIDEO_FORMAT_TYPE_NTSC;
        [[P2PClient sharedClient] setVideoFormatWithId:self.contact.contactId password:self.contact.contactPassword type:SETTING_VALUE_VIDEO_FORMAT_TYPE_NTSC];
    }
}

-(void)onSlider:(id)sender{
    
}

-(void)onSliderEnd:(id)sender{
    
    UISlider *slider = (UISlider*)sender;
    int iValue = (int)slider.value;
    [slider setValue:iValue];
    self.isVideoVolumeLoading = YES;
    self.lastSetVideoVolume = self.videoVolume;
    self.videoVolume = iValue;
    [self.tableView reloadData];
    [[P2PClient sharedClient] setVideoVolumeWithId:self.contact.contactId password:self.contact.contactPassword value:iValue];
    DLog(@"%i",iValue);
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
