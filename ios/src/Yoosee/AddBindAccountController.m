//
//  AddBindAccountController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-16.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "AddBindAccountController.h"
#import "Constants.h"
#import "Contact.h"
#import "TopBar.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "AlarmSettingController.h"
@interface AddBindAccountController ()

@end

@implementation AddBindAccountController

-(void)dealloc{
    [self.contact release];
    [self.lastSetBindIds release];
    [self.field1 release];
    [self.progressAlert release];
    [self.alarmSettingController release];
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
}
    
- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        
        case RET_SET_BIND_ACCOUNT:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0){
                
                self.alarmSettingController.bindIds = [NSMutableArray arrayWithArray:self.lastSetBindIds];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
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
    
    
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lastSetBindIds = [NSMutableArray arrayWithCapacity:0];
    [self initComponent];
        // Do any additional setup after loading the view.
}
    
- (void)didReceiveMemoryWarning
    {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }
    
    
-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    //CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:NO];
    [topBar setRightButtonText:NSLocalizedString(@"save", nil)];
    [topBar.rightButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"bind_account",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"input_alarm_id", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.field1 = field1;
    [self.view addSubview:field1];
    [field1 release];
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.progressAlert];
}
    
-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}
    
-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
    
-(void)onSavePress{
    NSString *alarmId = self.field1.text;
    
    if(!alarmId||!alarmId.length>0){
        [self.view makeToast:NSLocalizedString(@"input_alarm_id", nil)];
        return;
    }
    
    if([alarmId characterAtIndex:0]!='0'){
        [self.view makeToast:NSLocalizedString(@"alarm_id_must_zero_begin", nil)];
        return;
    }
    
    if(alarmId.length>9){
        [self.view makeToast:NSLocalizedString(@"id_too_long", nil)];
        return;
    }
    
    
    
    self.lastSetBindIds = [NSMutableArray arrayWithArray:self.alarmSettingController.bindIds];
    [self.lastSetBindIds addObject:[NSNumber numberWithInt:alarmId.intValue]];
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    [[P2PClient sharedClient] setBindAccountWithId:self.contact.contactId password:self.contact.contactPassword datas:self.lastSetBindIds];
 
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
