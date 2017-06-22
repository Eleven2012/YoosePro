//
//  PhoneRegisterController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-23.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "PhoneRegisterController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "Toast+UIView.h"
#import "RegisterResult.h"
#import "NetManager.h"
#import "Toast+UIView.h"
#import "LoginController.h"
@interface PhoneRegisterController ()

@end

@implementation PhoneRegisterController
-(void)dealloc{
    [self.field1 release];
    [self.field2 release];
    [self.countryCode release];
    [self.progressAlert release];
    [self.loginController release];
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

-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    //CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:NO];
    [topBar setRightButtonText:NSLocalizedString(@"next", nil)];
    [topBar.rightButton addTarget:self action:@selector(onNextPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"register_account",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"input_password", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.secureTextEntry = YES;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.field1 = field1;
    [self.view addSubview:field1];
    [field1 release];
    
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20*2+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field2.layer.borderWidth = 1;
        field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field2.layer.cornerRadius = 5.0;
    }
    field2.textAlignment = NSTextAlignmentLeft;
    field2.placeholder = NSLocalizedString(@"confirm_input", nil);
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field2.secureTextEntry = YES;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field2 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.field2 = field2;
    [self.view addSubview:field2];
    [field2 release];
    
    
    
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.progressAlert];
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

-(void)onBackPress{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)onNextPress{

    NSString *password = self.field1.text;
    NSString *confirmPassword = self.field2.text;
    

    
    if(!password||!password.length>0){
        [self.view makeToast:NSLocalizedString(@"input_password", nil)];
        return;
    }
    
    if(password.length>30){
        [self.view makeToast:NSLocalizedString(@"password_too_long", nil)];
        return;
    }
    
    if(!confirmPassword||!confirmPassword.length>0){
        [self.view makeToast:NSLocalizedString(@"confirm_input", nil)];
        return;
    }
    
    if(![password isEqualToString:confirmPassword]){
        [self.view makeToast:NSLocalizedString(@"two_passwords_not_match", nil)];
        return;
    }
    
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    
    [[NetManager sharedManager] registerWithVersionFlag:@"1" email:@"" countryCode:self.countryCode phone:self.phone password:password repassword:confirmPassword phoneCode:self.phoneCode callBack:^(id JSON) {
        
        [self.progressAlert hide:YES];
        RegisterResult *registerResult = (RegisterResult*)JSON;
        
        
        switch(registerResult.error_code){
            case NET_RET_REGISTER_SUCCESS:
            {
                
                if(self.loginController){
                    self.loginController.lastRegisterId = [NSString stringWithFormat:@"%@",registerResult.contactId];
                }
                UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"register_success_prompt", nil) message:[NSString stringWithFormat:@"ID:%@",registerResult.contactId] delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
                promptAlert.tag = ALERT_TAG_REGISTER_SUCCESS;
                [promptAlert show];
                [promptAlert release];
            }
                break;
            case NET_RET_REGISTER_EMAIL_FORMAT_ERROR:
            {
                [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
            }
                break;
            case NET_RET_REGISTER_EMAIL_USED:
            {
                [self.view makeToast:NSLocalizedString(@"email_used", nil)];
            }
                break;
                
            default:
            {
                [self.view makeToast:[NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"unknown_error", nil),registerResult.error_code]];
            }
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_REGISTER_SUCCESS:
        {
            if(buttonIndex==0){
                
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
            break;
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
