//
//  AlarmAccountController.m
//  Yoosee
//
//  Created by Jie on 14-10-17.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "AlarmAccountController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "P2PEmailSettingCell.h"
#import "Contact.h"
#import "Toast+UIView.h"
#import "AlarmSettingController.h"
#import "LoginResult.h"
#import "UDManager.h"


#define ALERT_TAG_UNBIND_ALARM_ID 0

@interface AlarmAccountController ()

@end

@implementation AlarmAccountController

-(void)dealloc{
    [self.contact release];
    [self.tableView release];
    [self.bindIds release];
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

-(void)viewWillAppear:(BOOL)animated{
    if(!self.isFirstLoadingCompolete){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
        self.isLoadingBindId = YES;
    
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
        case RET_GET_BIND_ACCOUNT:
        {
            //NSInteger count = [[parameter valueForKey:@"count"] integerValue];
            NSInteger maxCount = [[parameter valueForKey:@"maxCount"] integerValue];
            NSArray *datas = [parameter valueForKey:@"datas"];
            
            self.maxBindIdCount = maxCount;
            self.bindIds = [NSMutableArray arrayWithArray:datas];
            //NSLog(@"%@",self.bindIds);
            
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
                self.alarmSettingController.isFirstLoadingCompolete = NO;//刷新报警设置界面
                dispatch_async(dispatch_get_main_queue(), ^{
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

    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
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

 
    
    }
}
-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"alarm_push",nil)];
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
    
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.progressAlert];
}

-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self.navigationController popViewControllerAnimated:YES];

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if(self.isLoadingBindId){
        return 1;
    }else{
        return [self.bindIds count]+1;
    }
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BAR_BUTTON_HEIGHT;
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier3 = @"P2PEmailSettingCell";
    //CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    UITableViewCell *cell = nil;
    
    
    int section = indexPath.section;
    int row = indexPath.row;
    UIImage *backImg;
    UIImage *backImg_p;
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier3];
    if(cell==nil){
        cell = [[[P2PEmailSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier3] autorelease];
        [cell setBackgroundColor:XBGAlpha];
    }

    
        switch (section) {
            case 0:
            {
                if(self.isLoadingBindId){
                    if(row==0){
                        backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                        backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                    }
                }else{
                    
                    
                    
                    if([self.bindIds count]>0){
                        if(row==0){
                            backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                            backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                        }else if(row<[self.bindIds count]){
                            backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
                            backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];
                        }else{
                            backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                            backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
                        }
                        
                    }else{
                        backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                        backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                    }
                    
                }
                
                P2PEmailSettingCell *emailCell = (P2PEmailSettingCell*)cell;
                if(row==0){
                    [emailCell setLeftLabelText:NSLocalizedString(@"alarm_push", nil)];
                    if(self.isLoadingBindId){
                        [emailCell setLeftLabelHidden:NO];
                        [emailCell setLeftIconHidden:YES];
                        [emailCell setRightLabelHidden:YES];
                        [emailCell setProgressViewHidden:NO];
                    }else{
                        [emailCell setLeftLabelHidden:NO];
                        [emailCell setLeftIconHidden:YES];
                        [emailCell setRightLabelHidden:YES];
                        [emailCell setProgressViewHidden:YES];
                    }
                }
                
                if(row>0){
                    [emailCell setLeftIcon:@"ic_delete_alarm_id.png"];
                    [emailCell setLeftIconHidden:NO];
                    [emailCell setLeftLabelHidden:YES];
                    [emailCell setRightIconHidden:YES];
                    [emailCell setRightLabelHidden:NO];
                    [emailCell setProgressViewHidden:YES];
                    NSNumber *bindId = [self.bindIds objectAtIndex:row-1];
                    [emailCell setRightLabelText:[NSString stringWithFormat:@"0%i",[bindId intValue]]];
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
    
    if (indexPath.row>0) {
        UIAlertView *unBindAccountAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sure_to_unbind_account", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
        unBindAccountAlert.tag = ALERT_TAG_UNBIND_ALARM_ID;
        self.selectedUnbindAccountIndex = indexPath.row - 1;
        [unBindAccountAlert show];
        [unBindAccountAlert release];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_UNBIND_ALARM_ID:
        {
            if(buttonIndex==1){
                NSMutableArray *datas = [NSMutableArray arrayWithArray:self.bindIds];
                [datas removeObjectAtIndex:self.selectedUnbindAccountIndex];
                self.lastSetBindIds = [NSMutableArray arrayWithArray:datas];
                self.progressAlert.dimBackground = YES;
                [self.progressAlert show:YES];
                [[P2PClient sharedClient] setBindAccountWithId:self.contact.contactId password:self.contact.contactPassword datas:self.lastSetBindIds];
                
            }
        }
            break;
            
    }
}
@end
