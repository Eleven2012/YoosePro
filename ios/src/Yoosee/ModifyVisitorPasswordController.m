//
//  ModifyVisitorPasswordController.m
//  Yoosee
//
//  Created by guojunyi on 14-9-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ModifyVisitorPasswordController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Constants.h"
#import "Contact.h"
#import "TopBar.h"
#import "Toast+UIView.h"
#import "MBProgressHUD.h"

#import "FListManager.h"
@interface ModifyVisitorPasswordController ()

@end

@implementation ModifyVisitorPasswordController
-(void)dealloc{
    [self.contact release];
    [self.field1 release];
    [self.lastSetNewPassowrd release];
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
            
        case RET_SET_VISITOR_PASSWORD:
        {
            
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0){
                
                //self.contact.contactPassword = self.lastSetNewPassowrd;
                //[[FListManager sharedFList] update:self.contact];
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
        case RET_DEVICE_NOT_SUPPORT://IP添加设备
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.progressAlert hide:YES];
                [self.view makeToast:NSLocalizedString(@"device_not_support", nil)];
            });
        }
            break;
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
        case ACK_RET_SET_VISITOR_PASSWORD:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend set visitor password");
                    [[P2PClient sharedClient] setVisitorPasswordWithId:self.contact.contactId password:self.contact.contactPassword newPassword:self.lastSetNewPassowrd];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_SET_VISITOR_PASSWORD:%i",result);
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
    [topBar setTitle:NSLocalizedString(@"modify_visitor_password", nil)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:NO];
    [topBar setRightButtonText:NSLocalizedString(@"save", nil)];
    [topBar.rightButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"input_new_visitor_password", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.secureTextEntry = YES;
    field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.field1 = field1;
    [contentView addSubview:field1];
    [field1 release];
    
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [contentView addSubview:self.progressAlert];
    [self.view addSubview:contentView];
    [contentView release];
    
}

-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}


-(void)onSavePress{
    NSString *newPassword = self.field1.text;

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]*$"];

    if(!newPassword||!newPassword.length>0){
        [self.view makeToast:NSLocalizedString(@"input_new_visitor_password", nil)];
        return;
    }
    
    
    if([predicate evaluateWithObject:newPassword]==NO){
        [self.view makeToast:NSLocalizedString(@"password_number_format_error", nil)];
        return;
    }
    
    if([newPassword characterAtIndex:0]=='0'){
        [self.view makeToast:NSLocalizedString(@"password_zero_format_error", nil)];
        return;
    }
    
    if(newPassword.length>10){
        [self.view makeToast:NSLocalizedString(@"device_password_too_long", nil)];
        return;
    }
    

    
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    self.lastSetNewPassowrd = newPassword;

    [[P2PClient sharedClient] setVisitorPasswordWithId:self.contact.contactId password:self.contact.contactPassword newPassword:newPassword];
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
