//
//  DefenceAreaSettingController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "DefenceAreaSettingController.h"
#import "Constants.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "DefenceCell.h"
#import "P2PClient.h"
#import "Contact.h"
#import "MBProgressHUD.h"
#import "Toast+UIView.h"
#import "GroupHead.h"

@interface DefenceAreaSettingController ()

@end

@implementation DefenceAreaSettingController
-(void)dealloc{
    [self.progressAlert release];
    [self.contact release];
    [self.tableView release];
    [self.dataArray release];
    [self.statusData release];
    [self.switchStatusData release];
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
    
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
}
-(void)viewDidAppear:(BOOL)animated{
    
    self.isLoadDefenceArea = YES;
    [[P2PClient sharedClient] getDefenceAreaState:self.contact.contactId password:self.contact.contactPassword];
    
//    self.isLoadDefenceSwitch = YES;
//    [[P2PClient sharedClient] getDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword];

}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_DEVICE_NOT_SUPPORT://不支持禁用、启用开关
        {
            self.isLoadDefenceSwitch = NO;
            self.isNotSurportDefenceSwitch = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.isNotRightPWD) {
                    [self.view makeToast:NSLocalizedString(@"device_not_support_sensor_switch", nil)];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.tableView reloadData];
                });
                
            });
        }
            break;
        case RET_GET_DEFENCE_SWITCH_STATE:
        {
            
            NSMutableArray *switchStatus = [parameter valueForKey:@"switchStatus"];

//            NSArray *tempArr = [switchStatus objectAtIndex:1];
//            [switchStatus removeObjectAtIndex:1];
//            [switchStatus insertObject:tempArr atIndex:7];
            
            self.switchStatusData = [NSMutableArray arrayWithArray:switchStatus];
            for (int i = 0; i < 9; i++) {
                [self.dataArray[i] setObject:self.switchStatusData[i] forKey:@"switchStatusData"];
            }
            self.isLoadDefenceSwitch = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(self.isSetting){
                    self.isSetting = NO;
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                }
                
                [self.tableView reloadData];
            });
            
            
        }
            break;
        case RET_SET_DEFENCE_SWITCH_STATE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0){
                self.isSetting = YES;
                [[P2PClient sharedClient] getDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword];
                
            }else if(result==41){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!self.isNotRightPWD) {
                        [self.view makeToast:NSLocalizedString(@"device_not_support_sensor_switch", nil)];
                    }
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    self.isLoadDefenceSwitch = NO;
                    [self.tableView reloadData];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
        case RET_GET_DEFENCE_AREA_STATE:
        {
            
            NSMutableArray *status = [parameter valueForKey:@"status"];
            self.statusData = [NSMutableArray arrayWithArray:status];
            for (int i = 0; i < 9; i++) {
                [self.dataArray[i] setObject:self.statusData[i] forKey:@"statusData"];
            }
            self.isLoadDefenceArea = NO;
            
            if (!self.isSetting) {
                self.isLoadDefenceSwitch = YES;
                [[P2PClient sharedClient] getDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(self.isSetting){
                    self.isSetting = NO;
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                }
                [self.progressAlert hide:YES];
                [self.tableView reloadData];
            });
            
            
        }
            break;
        case RET_SET_DEFENCE_AREA_STATE:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0){
                self.isSetting = YES;
               [[P2PClient sharedClient] getDefenceAreaState:self.contact.contactId password:self.contact.contactPassword];
      
            }else if(result==32){
                int group = [[parameter valueForKey:@"group"] intValue];
                int item = [[parameter valueForKey:@"item"] intValue];
                
                DLog(@"%i %i->already learned!",group,item);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    self.isLoadDefenceArea = NO;
                    [self.tableView reloadData];
                    NSString *promptString = [NSString stringWithFormat:@"%@:%@ %i %@",[self getDefenceGroupNameWithIndex:group],NSLocalizedString(@"defence_item",nil),item+1,NSLocalizedString(@"already_learn",nil)];
                    [self.view makeToast:promptString];
                });
            }else if(result==41){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:NSLocalizedString(@"device_not_support_defence_area", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                });
                
            }else{
                
                DLog(@"%i",result);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    self.isLoadDefenceArea = NO;
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
            
        case ACK_RET_GET_DEFENCE_AREA_STATE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    self.isNotRightPWD = YES;
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                }else if(result==2){
                    DLog(@"resend get defence area state");
                    [[P2PClient sharedClient] getDefenceAreaState:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
    
            DLog(@"ACK_RET_GET_DEFENCE_AREA_STATE:%i",result);
        }
            break;
        case ACK_RET_SET_DEFENCE_AREA_STATE:
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
                    DLog(@"resend set defence area state");
                    
                    [[P2PClient sharedClient] setDefenceAreaState:self.contact.contactId password:self.contact.contactPassword group:self.lastSetGroup item:self.lastSetItem type:self.lastSetType];
                }
            });
            DLog(@"ACK_RET_SET_DEFENCE_AREA_STATE:%i",result);
        }
            break;
        case ACK_RET_GET_DEFENCE_SWITCH_STATE:{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend do device update");
                    [[P2PClient sharedClient] getDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword];
                }
                
                
            });
            
            DLog(@"ACK_RET_GET_DEVICE_INFO:%i",result);
        }
            break;
        case ACK_RET_SET_DEFENCE_SWITCH_STATE:{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend do device update");
                    [[P2PClient sharedClient] setDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword switchId:self.lastSetSwitchType alarmCodeId:self.lastSetSwitchGroup alarmCodeIndex:self.lastSetSwitchItem];
                }
                
                
            });
            
            DLog(@"ACK_RET_GET_DEVICE_INFO:%i",result);
        }
            break;
            
    }
    
}

-(NSString*)getDefenceGroupNameWithIndex:(NSInteger)index{
    switch (index) {
        case 0:
            return NSLocalizedString(@"remote", nil);
            break;
        case 1:
            return NSLocalizedString(@"hall", nil);
            break;
        case 2:
            return NSLocalizedString(@"window", nil);
            break;
        case 3:
            return NSLocalizedString(@"balcony", nil);
            break;
        case 4:
            return NSLocalizedString(@"bedroom", nil);
            break;
        case 5:
            return NSLocalizedString(@"kitchen", nil);
            break;
        case 6:
            return NSLocalizedString(@"courtyard", nil);
            break;
        case 7:
            return NSLocalizedString(@"door_lock", nil);
            break;
        case 8:
            return NSLocalizedString(@"other", nil);
            break;
            
        default:
            return @"";
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initDataSource];
    [self initComponent];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#define LEFT_LABEL_WIDTH 120
#define GROUP_HEAD_WIDTH ([UIScreen mainScreen].bounds.size.width)

-(void)initDataSource{
    NSMutableArray *dataArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < 9; i++) {
        NSMutableDictionary *groupDic = [NSMutableDictionary dictionaryWithCapacity:0];
        
        switch (i) {
            case 0:
                [groupDic setObject:NSLocalizedString(@"remote", nil) forKey:@"groupName"];
                break;
            case 1:
                [groupDic setObject:NSLocalizedString(@"hall", nil) forKey:@"groupName"];
                break;
            case 2:
                [groupDic setObject:NSLocalizedString(@"window", nil) forKey:@"groupName"];
                break;
            case 3:
                [groupDic setObject:NSLocalizedString(@"balcony", nil) forKey:@"groupName"];
                break;
            case 4:
                [groupDic setObject:NSLocalizedString(@"bedroom", nil) forKey:@"groupName"];
                break;
            case 5:
                [groupDic setObject:NSLocalizedString(@"kitchen", nil) forKey:@"groupName"];
                break;
            case 6:
                [groupDic setObject:NSLocalizedString(@"courtyard", nil) forKey:@"groupName"];
                break;
            case 7:
                [groupDic setObject:NSLocalizedString(@"door_lock", nil) forKey:@"groupName"];
                break;
            case 8:
                [groupDic setObject:NSLocalizedString(@"other", nil) forKey:@"groupName"];
                break;
            default:
                break;
        }
        
        [groupDic setValue:@"1" forKey:@"isHidden"];
        [dataArr addObject:groupDic];
    }
    self.dataArray = dataArr;
}

-(void)initComponent{
    [self.view setBackgroundColor:XBgColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"defenceArea_set",nil)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    
    UIView *maskLayerView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];//UITableViewStyleGrouped,headView随cell一起滚动
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [maskLayerView addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:maskLayerView] autorelease];
    [maskLayerView addSubview:self.progressAlert];
    
    [self.view addSubview:maskLayerView];
    [maskLayerView release];
    
    
}

-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return BAR_BUTTON_HEIGHT;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BAR_BUTTON_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    GroupHead * headView = [[[GroupHead alloc] initWithFrame:CGRectMake(10, 0, GROUP_HEAD_WIDTH, BAR_BUTTON_HEIGHT)] autorelease];
//    [headView setBackgroundColor:XWhite];
//    headView.layer.borderColor = XBgColor.CGColor;
//    headView.layer.borderWidth = 2;
//    headView.layer.cornerRadius = 10;
    headView.layer.masksToBounds = YES;
    [headView addTarget:self action:@selector(onHeadClicked:) forControlEvents:UIControlEventTouchUpInside];
    headView.tag = section;
    
    NSDictionary *dic = self.dataArray[section];
    [headView refreshUIWithDictionary:dic];
    
    
    return headView;
}

- (void)onHeadClicked:(UIView *)headView{
    NSDictionary *dic = _dataArray[headView.tag];
    NSArray *statusArr = [dic valueForKey:@"statusData"];
    if (statusArr.count > 0) {
        GroupHead *head = (GroupHead *)headView;
        NSString *isHidden = dic[@"isHidden"];
        if ([isHidden intValue] == 0) {
            [dic setValue:@"1" forKey:@"isHidden"];
            head.statusLabel.text = @">";
        }else{
            [dic setValue:@"0" forKey:@"isHidden"];
            head.statusLabel.text = @"v";
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:headView.tag] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dic = self.dataArray[section];
    NSArray *statusData = [dic valueForKey:@"statusData"];
    NSString *isHidden = [dic valueForKey:@"isHidden"];
    if ([isHidden intValue] == 1) {
        return 0;
    }else if (statusData.count > 0) {
        return statusData.count;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * reuseID = @"DefenceCell";
    DefenceCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[[DefenceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID] autorelease];
        [cell setBackgroundColor:XBGAlpha];
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int section = indexPath.section;
    int row = indexPath.row;
    if (section == 0) {
        NSDictionary *dic = self.dataArray[section];
        NSArray *statusData = [dic valueForKey:@"statusData"];
        
        [cell setLeftButtonHidden:YES];
        [cell setProgressViewHidden:YES];
        cell.index = [NSString stringWithFormat:@"%d",row + 1];
        //显示学习对码状态
        if ([statusData[row] intValue] == 1) {
            //显示learnCodeLabel并且隐藏delImageView
            [cell setDelImageViewHidden:YES];
            if (self.isLoadDefenceArea) {
                [cell setProgressViewHidden2:NO];
                [cell setLearnCodeLabelHidden:YES];
            }else{
                [cell setProgressViewHidden2:YES];
                [cell setLearnCodeLabelHidden:NO];
            }
        }else if ([statusData[row] intValue] == 0){
            //显示delImageView并且隐藏learnCodeLabel
            [cell setLearnCodeLabelHidden:YES];
            if (self.isLoadDefenceArea) {
                [cell setProgressViewHidden2:NO];
                [cell setDelImageViewHidden:YES];
            }else{
                [cell setProgressViewHidden2:YES];
                [cell setDelImageViewHidden:NO];
            }
        }
    }else{
        cell.section = section;
        cell.row = row;
        cell.delegate = self;
        
        
        NSDictionary *dic = self.dataArray[section];
        NSArray *statusData = [dic valueForKey:@"statusData"];
        NSArray *switchStatusData = [dic valueForKey:@"switchStatusData"];
        //显示学习对码状态、启用禁用开关状态
        if ([statusData[row] intValue] == 1) {
            //隐藏leftButton、delImageView、progressView
            [cell setLeftButtonHidden:YES];
            [cell setDelImageViewHidden:YES];
            [cell setProgressViewHidden:YES];
            if (self.isLoadDefenceArea) {
                [cell setProgressViewHidden2:NO];
                [cell setLearnCodeLabelHidden:YES];
            }else{
                [cell setProgressViewHidden2:YES];
                [cell setLearnCodeLabelHidden:NO];
            }
        }else if ([statusData[row] intValue] == 0){
            //显示leftButton、delImageView并且隐藏learnCodeLabel
            [cell setLearnCodeLabelHidden:YES];
            if (!self.isNotSurportDefenceSwitch) {
                if (self.isLoadDefenceSwitch) {
                    [cell setProgressViewHidden:NO];
                    [cell setLeftButtonHidden:YES];
                }else{
                    [cell setProgressViewHidden:YES];
                    [cell setLeftButtonHidden:NO];
                }
            }else{
                [cell setLeftButtonHidden:YES];
                [cell setProgressViewHidden:YES];
            }
            
            if (self.isLoadDefenceArea) {
                [cell setProgressViewHidden2:NO];
                [cell setDelImageViewHidden:YES];
            }else{
                [cell setProgressViewHidden2:YES];
                [cell setDelImageViewHidden:NO];
            }
            
            if ([switchStatusData[row] intValue] == 0) {
                //显示禁用状态的按钮
                cell.isSelectedButton = NO;
            }else{
                //显示启用状态的按钮
                cell.isSelectedButton = YES;
            }
        }
        cell.index = [NSString stringWithFormat:@"%d",row + 1];
    }
    
    
    UIImage *backImg;
    UIImage *backImg_p;
    if(row == 0){
        backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
        backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
    }else if (row == 7){
        backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
        backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
    }else{
        backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
        backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];
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
    
    int section = indexPath.section;
    self.lastSetGroup = section;
    int row = indexPath.row;
    self.lastSetItem = row;
    NSDictionary *dic = self.dataArray[section];
    NSArray *statusData = [dic valueForKey:@"statusData"];
    
    if ([statusData[row] intValue] == 1) {//开学习
        self.lastSetType = 0;
        
        UIAlertView *learnAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"learn_defence_prompt", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
        learnAlert.tag = ALERT_TAG_LEARN;
        [learnAlert show];
        [learnAlert release];
    }else{//关学习
        self.lastSetType = 1;
        
        UIAlertView *clearAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"clear_defence_prompt", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
        clearAlert.tag = ALERT_TAG_CLEAR;
        [clearAlert show];
        [clearAlert release];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_CLEAR:
        {
            if(buttonIndex==0){
                
            }else if(buttonIndex==1){
                self.progressAlert.dimBackground = YES;
                self.progressAlert.labelText = NSLocalizedString(@"clearing", nil);
                [self.progressAlert show:YES];
                
                self.isLoadDefenceArea = YES;
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:self.lastSetItem inSection:self.lastSetGroup], nil] withRowAnimation:UITableViewRowAnimationNone];
                
                [[P2PClient sharedClient] setDefenceAreaState:self.contact.contactId password:self.contact.contactPassword group:self.lastSetGroup item:self.lastSetItem type:self.lastSetType];
            }
        }
            break;
        case ALERT_TAG_LEARN:
        {
            if(buttonIndex==0){
                
            }else if(buttonIndex==1){
                self.progressAlert.dimBackground = YES;
                self.progressAlert.labelText = NSLocalizedString(@"learning", nil);
                [self.progressAlert show:YES];
                
                self.isLoadDefenceArea = YES;
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:self.lastSetItem inSection:self.lastSetGroup], nil] withRowAnimation:UITableViewRowAnimationNone];
                
                [[P2PClient sharedClient] setDefenceAreaState:self.contact.contactId password:self.contact.contactPassword group:self.lastSetGroup item:self.lastSetItem type:self.lastSetType];
            }
        }
            break;
            
    }
}

-(void)defenceCell:(DefenceCell *)defenceCell section:(NSInteger)section row:(NSInteger)row{
    NSDictionary *dic = self.dataArray[section];
    NSArray *switchStatusData = [dic valueForKey:@"switchStatusData"];
    
    if (section > 0) {
        if ([switchStatusData[row] intValue] == 0) {//启用
            self.isLoadDefenceSwitch = YES;
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row inSection:section], nil] withRowAnimation:UITableViewRowAnimationNone];
            
            self.lastSetSwitchGroup = section-1;
            self.lastSetSwitchItem = row;
            self.lastSetSwitchType = 1;
            [[P2PClient sharedClient] setDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword switchId:1 alarmCodeId:section-1 alarmCodeIndex:row];
        }else{//禁用
            self.isLoadDefenceSwitch = YES;
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row inSection:section], nil] withRowAnimation:UITableViewRowAnimationNone];
        
            self.lastSetSwitchGroup = section-1;
            self.lastSetSwitchItem = row;
            self.lastSetSwitchType = 0;
            [[P2PClient sharedClient] setDefenceSwitchStateWithId:self.contact.contactId password:self.contact.contactPassword switchId:0 alarmCodeId:section-1 alarmCodeIndex:row];
        }
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
