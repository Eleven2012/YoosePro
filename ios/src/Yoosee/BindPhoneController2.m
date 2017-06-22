//
//  BindPhoneController2.m
//  Yoosee
//
//  Created by guojunyi on 14-5-22.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "BindPhoneController2.h"
#import "Constants.h"
#import "TopBar.h"
#import "MBProgressHUD.h"
#import "Utils.h"
#import "NetManager.h"
#import "AppDelegate.h"
#import "ChooseCountryController.h"
#import "Toast+UIView.h"
#import "LoginResult.h"
#import "UDManager.h"
#import "AccountController.h"
#import "PhoneRegisterController.h"
#import "LoginController.h"
@interface BindPhoneController2 ()

@end

@implementation BindPhoneController2

-(void)dealloc{
    [self.field1 release];
    [self.progressAlert release];
    [self.countryCode release];
    [self.phoneNumber release];
    [self.resendLabel release];
    [self.accountController release];
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
    self.isCanResend = YES;
    [self countDownTime];
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
    if(self.isRegister){
        [topBar setTitle:NSLocalizedString(@"register_account",nil)];
    }else{
        [topBar setTitle:NSLocalizedString(@"bind_phone",nil)];
    }
    [self.view addSubview:topBar];
    [topBar release];
    
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    label1.textAlignment = NSTextAlignmentLeft;
    label1.backgroundColor = XBGAlpha;
    label1.textColor = XBlue;
    label1.font = XFontBold_16;
    label1.text = NSLocalizedString(@"phone_code_was_send_to", nil);
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+TEXT_FIELD_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    label2.textAlignment = NSTextAlignmentLeft;
    label2.backgroundColor = XBGAlpha;
    label2.textColor = XBlue;
    label2.font = XFontBold_16;
    label2.text = [NSString stringWithFormat:@"+%@-%@",self.countryCode,self.phoneNumber];
    
    [self.view addSubview:label1];
    [self.view addSubview:label2];
    [label1 release];
    [label2 release];
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20*2+TEXT_FIELD_HEIGHT*2, 150, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"phone_check_code", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.field1 = field1;
    [self.view addSubview:field1];
    [field1 release];
    
    
    UIButton *resend = [UIButton buttonWithType:UIButtonTypeCustom];
    resend.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT+150+10, NAVIGATION_BAR_HEIGHT+20*2+TEXT_FIELD_HEIGHT*2, 80, TEXT_FIELD_HEIGHT);
    [resend addTarget:self action:@selector(onResendPress:) forControlEvents:UIControlEventTouchUpInside];
    [resend addTarget:self action:@selector(lightButton:) forControlEvents:UIControlEventTouchDown];
    [resend addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchCancel];
    [resend addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
    [resend addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
    resend.layer.cornerRadius = 2.0;
    resend.layer.borderWidth = 1.0;
    resend.layer.borderColor = [[UIColor grayColor] CGColor];
    resend.backgroundColor = XWhite;
    UILabel *resendLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, resend.frame.size.width, resend.frame.size.height)];
    resendLabel.textAlignment = NSTextAlignmentCenter;
    resendLabel.backgroundColor = XBGAlpha;
    resendLabel.textColor = XBlack;
    resendLabel.font = XFontBold_16;
    resendLabel.text = NSLocalizedString(@"resend", nil);
    [resend addSubview:resendLabel];
    self.resendLabel = resendLabel;
    [resendLabel release];
    
    [self.view addSubview:resend];
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.progressAlert];
    
    
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)lightButton:(UIView*)view{
    view.backgroundColor = XBlue;
}

-(void)normalButton:(UIView*)view{
    view.backgroundColor = XWhite;
}

-(void)onNextPress{
    NSString *check_code = self.field1.text;
    
    if(!check_code||!check_code.length>0){
        [self.view makeToast:NSLocalizedString(@"input_phone", nil)];
        return;
    }
    
    if(self.isRegister){
        self.progressAlert.dimBackground = YES;
        [self.progressAlert show:YES];
        [[NetManager sharedManager] verifyPhoneCodeWithCode:check_code phone:self.phoneNumber countryCode:self.countryCode callBack:^(id JSON) {
            [self.progressAlert hide:YES];
            NSInteger error_code = (NSInteger)[JSON integerValue];
            switch (error_code) {
                case NET_RET_VERIFY_PHONE_CODE_SUCCESS:
                {
                    PhoneRegisterController *phoneRegisterController = [[PhoneRegisterController alloc] init];
                    phoneRegisterController.loginController = self.loginController;
                    phoneRegisterController.phone = self.phoneNumber;
                    phoneRegisterController.countryCode = self.countryCode;
                    phoneRegisterController.phoneCode = check_code;
                    [self.navigationController pushViewController:phoneRegisterController animated:YES];
                    [phoneRegisterController release];
                }
                    break;
                case NET_RET_VERIFY_PHONE_CODE_ERROR:
                {
                    [self.view makeToast:NSLocalizedString(@"phone_code_error", nil)];
                }
                    break;
                case NET_RET_VERIFY_PHONE_CODE_TIME_OUT:
                {
                    [self.view makeToast:NSLocalizedString(@"phone_code_time_out", nil)];
                }
                    break;
                default:
                {
                    [self.view makeToast:[NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"unknown_error", nil),error_code]];
                }
                    break;
            }
        }];
        
    }else{
        UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_login_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
        inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        inputAlert.tag = ALERT_TAG_BIND_PHONEs_AFTER_INPUT_PASSWORD;
        [inputAlert show];
        [inputAlert release];
    }
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_BIND_PHONEs_AFTER_INPUT_PASSWORD:
        {
            if(buttonIndex==1){
                self.progressAlert.dimBackground = YES;
                [self.progressAlert show:YES];
                UITextField *passwordField = [alertView textFieldAtIndex:0];
                NSString *inputPwd = passwordField.text;
                NSString *checkCode = self.field1.text;
                LoginResult *loginResult = [UDManager getLoginInfo];
                [[NetManager sharedManager] setAccountInfo:loginResult.contactId password:inputPwd phone:self.phoneNumber email:loginResult.email countryCode:self.countryCode phoneCheckCode:checkCode flag:@"1" sessionId:loginResult.sessionId callBack:^(id JSON){
                    [self.progressAlert hide:YES];
                    NSInteger error_code = (NSInteger)[JSON integerValue];
                    switch (error_code) {
                        case NET_RET_SET_ACCOUNT_SUCCESS:
                        {
                            loginResult.phone = self.phoneNumber;
                            loginResult.countryCode = self.countryCode;
                            [UDManager setLoginInfo:loginResult];
                            [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                sleep(1.0);
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.navigationController popToViewController:self.accountController animated:YES];
                                });
                            });
                            
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_PASSWORD_ERROR:
                        {
                            [self.view makeToast:NSLocalizedString(@"password_error", nil)];
                        }
                            break;
                        case NET_RET_SET_ACCOUNT_PHONE_USED:
                        {
                            [self.view makeToast:NSLocalizedString(@"phone_used", nil)];
                        }
                        default:
                        {
                            [self.view makeToast:[NSString stringWithFormat:@"%@:%ld",NSLocalizedString(@"unknown_error", nil),error_code]];
                        }
                            break;
                    }
                }];
            }
        }
            break;
            
            
            
    }
}

-(void)onResendPress:(UIButton*)button{
    [self normalButton:button];
    if(self.isCanResend){
        [self countDownTime];
        self.progressAlert.dimBackground = YES;
        [self.progressAlert show:YES];
        [[NetManager sharedManager] getPhoneCodeWithPhone:self.phoneNumber countryCode:self.countryCode callBack:^(id JSON) {
            [self.progressAlert hide:YES];
            NSInteger error_code = (NSInteger)[JSON integerValue];
            switch(error_code){
                case NET_RET_GET_PHONE_CODE_SUCCESS:
                {
                    
                }
                    break;
                case NET_RET_GET_PHONE_CODE_PHONE_USED:
                {
                    [self.view makeToast:NSLocalizedString(@"phone_used", nil)];
                    
                }
                    break;
                case NET_RET_GET_PHONE_CODE_TOO_TIMES:
                {
                    [self.view makeToast:NSLocalizedString(@"get_phone_code_too_times", nil)];
                }
                    break;
                default:
                {
                    [self.view makeToast:[NSString stringWithFormat:@"%@:%i",NSLocalizedString(@"unknown_error", nil),error_code]];
                }
                    break;
            }
        }];

    }
    
}

-(void)countDownTime{
    if(self.isCanResend){
    self.isCanResend = NO;
    __block int time = 180;
    self.resendLabel.text = [NSString stringWithFormat:@"%i",time];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while(time>0){
            sleep(1.0);
            time --;
            dispatch_async(dispatch_get_main_queue(), ^{
                DLog(@"%i",time);
                if(time<=0){
                    self.resendLabel.text = NSLocalizedString(@"resend", nil);
                    self.isCanResend = YES;
                }else{
                    self.resendLabel.text = [NSString stringWithFormat:@"%i",time];
                }
                
            });
        }
        
        
    });
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
