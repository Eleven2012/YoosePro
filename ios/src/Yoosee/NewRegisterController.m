//
//  NewRegisterController.m
//  Yoosee
//
//  Created by Jie on 14/12/6.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "NewRegisterController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Constants.h"
#import "BindPhoneController.h"
#import "EmailRegisterController.h"
#import "ChooseCountryController.h"
#import "NetManager.h"
#import "PhoneRegisterController.h"
#import "BindPhoneController2.h"
#import "LoginController.h"
#import "Toast+UIView.h"
#import "MBProgressHUD.h"
#import "RegisterResult.h"

@interface NewRegisterController ()

@end

@implementation NewRegisterController

-(void)dealloc{
    
    //{{-- kongyulu at 20150920
    self.mainView1 = nil;
    self.mainView2 = nil;
    self.leftLabel  = nil;
    self.rightLabel = nil;
    self.field1 = nil;
    self.emailField1 = nil;
    self.emailField2 = nil;
    self.emailField3 = nil;
    self.countryCode = nil;
    self.countryName = nil;
    self.progressAlert = nil;
    self.loginController = nil;
    //}}-- kongyulu at 20150920
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.registerType = 0;
    [self initComponent];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    /*
     *设置通知监听者，监听键盘的显示、收起通知
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if(!self.countryCode||!self.countryCode.length>0){
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        if([language hasPrefix:@"zh"]){
            self.countryCode = @"86";
            self.countryName = NSLocalizedString(@"china", nil);
        }else{
            self.countryCode = @"1";
            self.countryName = NSLocalizedString(@"america", nil);
        }
    }
    
    self.leftLabel.text = [NSString stringWithFormat:@"+%@",self.countryCode];
    self.rightLabel.text = self.countryName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define SEGMENT_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:38)
#define LOGIN_BTN_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:38)


-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"new_account_register",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    if(CURRENT_VERSION>=7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"phone_register", nil),NSLocalizedString(@"email_register", nil)]];
    [segment addTarget:self action:@selector(onLoginTypeChange:) forControlEvents:UIControlEventValueChanged];
    segment.frame = CGRectMake(30, NAVIGATION_BAR_HEIGHT+20, width-30*2, SEGMENT_HEIGHT);
    segment.segmentedControlStyle = UISegmentedControlStyleBar;
    segment.selectedSegmentIndex = self.registerType;
    [self.view addSubview:segment];
    [segment release];
    
    
    /*
     *mainView1表示手机注册界面
     */
    UIView *mainView1 = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+20+SEGMENT_HEIGHT+10, width, height-NAVIGATION_BAR_HEIGHT-20-SEGMENT_HEIGHT-10)];
    self.mainView1 = mainView1;
    
    /*
     *chooseCountryBtn
     *点击时，进入下一个界面，可以进行国家选择
     */
    UIButton *chooseCountryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    chooseCountryBtn.frame = CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 0, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT);
    chooseCountryBtn.layer.cornerRadius = 2.0;
    chooseCountryBtn.layer.borderWidth = 1.0;
    chooseCountryBtn.layer.borderColor = [[UIColor grayColor] CGColor];
    chooseCountryBtn.backgroundColor = XWhite;
    [chooseCountryBtn addTarget:self action:@selector(onChooseCountryPress:) forControlEvents:UIControlEventTouchUpInside];
    [chooseCountryBtn addTarget:self action:@selector(lightButton:) forControlEvents:UIControlEventTouchDown];
    [chooseCountryBtn addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchCancel];
    [chooseCountryBtn addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
    [chooseCountryBtn addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
    
    
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, chooseCountryBtn.frame.size.width/3, chooseCountryBtn.frame.size.height)];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.backgroundColor = XBGAlpha;
    leftLabel.textColor = XBlack;
    leftLabel.font = XFontBold_16;
    self.leftLabel = leftLabel;
    [leftLabel release];
    [chooseCountryBtn addSubview:self.leftLabel];
    
    UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(chooseCountryBtn.frame.size.width/3, 1, 0.5, chooseCountryBtn.frame.size.height-2)];
    separator.backgroundColor = [UIColor grayColor];
    [chooseCountryBtn addSubview:separator];
    [separator release];
    
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(chooseCountryBtn.frame.size.width/3+0.5, 0, chooseCountryBtn.frame.size.width/3*2-0.5, chooseCountryBtn.frame.size.height)];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.backgroundColor = XBGAlpha;
    rightLabel.textColor = XBlack;
    rightLabel.font = XFontBold_16;
    self.rightLabel = rightLabel;
    [rightLabel release];
    [chooseCountryBtn addSubview:self.rightLabel];
    
    [self.mainView1 addSubview: chooseCountryBtn];
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, TEXT_FIELD_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"input_phone", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.field1 = field1;
    [self.mainView1 addSubview:field1];
    [field1 release];
    
    
    /* 下一步button */
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    nextBtn.frame = CGRectMake(NORMAL_BUTTON_MARGIN_LEFT_AND_RIGHT,self.mainView1.frame.size.height-LOGIN_BTN_HEIGHT-20.0, width-NORMAL_BUTTON_MARGIN_LEFT_AND_RIGHT*2, LOGIN_BTN_HEIGHT);
    UIImage *loginBtnBackImg = [UIImage imageNamed:@"bg_button.png"];
    loginBtnBackImg = [loginBtnBackImg stretchableImageWithLeftCapWidth:loginBtnBackImg.size.width*0.5 topCapHeight:loginBtnBackImg.size.height*0.5];
    
    UIImage *loginBtnBackImg_p = [UIImage imageNamed:@"bg_button_p.png"];
    loginBtnBackImg_p = [loginBtnBackImg_p stretchableImageWithLeftCapWidth:loginBtnBackImg_p.size.width*0.5 topCapHeight:loginBtnBackImg_p.size.height*0.5];
    
    [nextBtn setBackgroundImage:loginBtnBackImg forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:loginBtnBackImg_p forState:UIControlStateHighlighted];
    [nextBtn addTarget:self action:@selector(onNextPress) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView1 addSubview:nextBtn];
    
    [self.view addSubview:mainView1];
    [mainView1 release];
    
    
    /*
     *mainView2表示邮箱注册界面
     */
    UIView *mainView2 = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+20+SEGMENT_HEIGHT+10, width, height-NAVIGATION_BAR_HEIGHT-20-SEGMENT_HEIGHT-10)];
    self.mainView2 = mainView2;
    
    
    UITextField *emailField1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 0, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        emailField1.layer.borderWidth = 1;
        emailField1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        emailField1.layer.cornerRadius = 5.0;
    }
    emailField1.textAlignment = NSTextAlignmentLeft;
    emailField1.placeholder = NSLocalizedString(@"input_email", nil);
    emailField1.borderStyle = UITextBorderStyleRoundedRect;
    emailField1.returnKeyType = UIReturnKeyDone;
    emailField1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [emailField1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.emailField1 = emailField1;
    [self.mainView2 addSubview:emailField1];
    [emailField1 release];
    
    UITextField *emailField2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        emailField2.layer.borderWidth = 1;
        emailField2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        emailField2.layer.cornerRadius = 5.0;
    }
    emailField2.textAlignment = NSTextAlignmentLeft;
    emailField2.placeholder = NSLocalizedString(@"input_password", nil);
    emailField2.borderStyle = UITextBorderStyleRoundedRect;
    emailField2.returnKeyType = UIReturnKeyDone;
    emailField2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField2.secureTextEntry = YES;
    emailField2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [emailField2 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.emailField2 = emailField2;
    [self.mainView2 addSubview:emailField2];
    [emailField2 release];
    
    UITextField *emailField3 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20*2+TEXT_FIELD_HEIGHT*2, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        emailField3.layer.borderWidth = 1;
        emailField3.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        emailField3.layer.cornerRadius = 5.0;
    }
    emailField3.textAlignment = NSTextAlignmentLeft;
    emailField3.placeholder = NSLocalizedString(@"confirm_input", nil);
    emailField3.borderStyle = UITextBorderStyleRoundedRect;
    emailField3.returnKeyType = UIReturnKeyDone;
    emailField3.secureTextEntry = YES;
    emailField3.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailField3.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [emailField3 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.emailField3 = emailField3;
    [self.mainView2 addSubview:emailField3];
    [emailField3 release];
    
    
    /* 下一步button */
    UIButton *nextBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBtn2 setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    nextBtn2.frame = CGRectMake(NORMAL_BUTTON_MARGIN_LEFT_AND_RIGHT,self.mainView1.frame.size.height-LOGIN_BTN_HEIGHT-20.0, width-NORMAL_BUTTON_MARGIN_LEFT_AND_RIGHT*2, LOGIN_BTN_HEIGHT);
    UIImage *loginBtnBackImg2 = [UIImage imageNamed:@"bg_button.png"];
    loginBtnBackImg2 = [loginBtnBackImg2 stretchableImageWithLeftCapWidth:loginBtnBackImg2.size.width*0.5 topCapHeight:loginBtnBackImg2.size.height*0.5];
    
    UIImage *loginBtnBackImg_p2 = [UIImage imageNamed:@"bg_button_p.png"];
    loginBtnBackImg_p2 = [loginBtnBackImg_p2 stretchableImageWithLeftCapWidth:loginBtnBackImg_p2.size.width*0.5 topCapHeight:loginBtnBackImg_p2.size.height*0.5];
    
    [nextBtn2 setBackgroundImage:loginBtnBackImg2 forState:UIControlStateNormal];
    [nextBtn2 setBackgroundImage:loginBtnBackImg_p2 forState:UIControlStateHighlighted];
    [nextBtn2 addTarget:self action:@selector(onNextPress) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView2 addSubview:nextBtn2];
    
    [self.view addSubview:mainView2];
    [mainView2 release];
    
    
    /*
     *初始化默认的登录界面
     */
    if(self.registerType==0){
        [self.mainView1 setHidden:NO];
        [self.mainView2 setHidden:YES];
    }else{
        [self.mainView1 setHidden:YES];
        [self.mainView2 setHidden:NO];
    }
    

    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.progressAlert];
}

-(void)lightButton:(UIView*)view{
    view.backgroundColor = XBlue;
}

-(void)normalButton:(UIView*)view{
    view.backgroundColor = XWhite;
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

#pragma mark - 监听键盘
#pragma mark 键盘将要显示时，调用
-(void)onKeyBoardWillShow:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    //keyBoard frame
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    DLog(@"%f",rect.size.height);
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        CGFloat offset1;//login button 以下的height
                        if (self.registerType == 0) {
                            offset1 = self.mainView1.frame.size.height-(self.field1.frame.origin.y+TEXT_FIELD_HEIGHT);
                        }else{
                            offset1 = self.mainView2.frame.size.height-(self.emailField3.frame.origin.y+TEXT_FIELD_HEIGHT);
                        }
                        CGFloat finalOffset;
                        if(offset1-rect.size.height<0){
                            finalOffset = rect.size.height-offset1+10;
                        }else {
                            if(offset1-rect.size.height>=10){
                                finalOffset = 0;
                            }else{
                                finalOffset = 10-(offset1-rect.size.height);
                            }
                        }
                        self.view.transform = CGAffineTransformMakeTranslation(0, -finalOffset);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

#pragma mark 键盘将要收起时，调用
-(void)onKeyBoardWillHide:(NSNotification*)notification{
    DLog(@"onKeyBoardWillHide");
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

#pragma mark - 调用时，进入国家选择界面
-(void)onChooseCountryPress:(UIButton*)button{
    [self normalButton:button];
    ChooseCountryController *chooseCountryController = [[ChooseCountryController alloc] init];
    chooseCountryController.registerController = self;
    [self presentViewController:chooseCountryController animated:YES completion:nil];
    [chooseCountryController release];
}

-(void)onBackPress{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onLoginTypeChange:(UISegmentedControl*)control{
    
    self.registerType = control.selectedSegmentIndex;
    if(self.registerType==0){
        [self.mainView1 setHidden:NO];
        [self.mainView2 setHidden:YES];
    }else{
        [self.mainView1 setHidden:YES];
        [self.mainView2 setHidden:NO];
    }
    
}

-(void)onNextPress{
    if (self.registerType==0) {
//        BindPhoneController *bindPhoneController = [[BindPhoneController alloc]init];
//        bindPhoneController.isRegister = YES;
//        [self.navigationController pushViewController:bindPhoneController animated:YES];
//        [bindPhoneController release];
        [self onPhoneRegister];
    }else{
//        EmailRegisterController *emailRegisterController = [[EmailRegisterController alloc]init];
//        [self.navigationController pushViewController:emailRegisterController animated:YES];
//        [emailRegisterController release];
        [self onEmailRegister];
    }
}

-(void)onPhoneRegister{
    NSString *phone = self.field1.text;
    
    if(!phone||!phone.length>0){
        [self.view makeToast:NSLocalizedString(@"input_phone", nil)];
        return;
    }
    
    if(phone.length<6||phone.length>15){
        [self.view makeToast:NSLocalizedString(@"phone_length_error", nil)];
        return;
    }
    
    if([self.countryCode isEqualToString:@"86"]){
        
        self.progressAlert.dimBackground = YES;
        [self.progressAlert show:YES];
        [[NetManager sharedManager] getPhoneCodeWithPhone:phone countryCode:self.countryCode callBack:^(id JSON) {
            [self.progressAlert hide:YES];
            NSInteger error_code = (NSInteger)[JSON integerValue];
            switch(error_code){
                case NET_RET_GET_PHONE_CODE_SUCCESS:
                {
                    BindPhoneController2 *bindPhoneController2 = [[BindPhoneController2 alloc] init];
                    bindPhoneController2.countryCode = self.countryCode;
                    bindPhoneController2.phoneNumber = phone;
                    bindPhoneController2.isRegister = YES;
                    bindPhoneController2.loginController = self.loginController;
                    [self.navigationController pushViewController:bindPhoneController2 animated:YES];
                    [bindPhoneController2 release];
                }
                    break;
                case NET_RET_GET_PHONE_CODE_PHONE_USED:
                {
                    [self.view makeToast:NSLocalizedString(@"phone_used", nil)];
                }
                    break;
                case NET_RET_GET_PHONE_CODE_FORMAT_ERROR:
                {
                    [self.view makeToast:NSLocalizedString(@"phone_format_error", nil)];
                }
                    break;
                case NET_RET_GET_PHONE_CODE_TOO_TIMES:
                {
                    [self.view makeToast:NSLocalizedString(@"get_phone_code_too_times", nil)];
                }
                    break;
                default:
                {
                    [self.view makeToast:[NSString stringWithFormat:@"%@:%ld",NSLocalizedString(@"unknown_error", nil),error_code]];
                }
                    break;
            }
        }];
    }else{

        PhoneRegisterController *phoneRegisterController = [[PhoneRegisterController alloc] init];
        phoneRegisterController.loginController = self.loginController;
        phoneRegisterController.phone = phone;
        phoneRegisterController.countryCode = self.countryCode;
        phoneRegisterController.phoneCode = @"";
        [self.navigationController pushViewController:phoneRegisterController animated:YES];
        [phoneRegisterController release];

        
    }
}

-(void)onEmailRegister{
    NSString *email = self.emailField1.text;
    NSString *password = self.emailField2.text;
    NSString *confirmPassword = self.emailField3.text;
    
    if(!email||!email.length>0){
        [self.view makeToast:NSLocalizedString(@"input_email", nil)];
        return;
    }
    
    if(email.length<5||email.length>32){
        [self.view makeToast:NSLocalizedString(@"email_length_error", nil)];
        return;
    }
    
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
    
    [[NetManager sharedManager] registerWithVersionFlag:@"1" email:email countryCode:@"" phone:@"" password:password repassword:confirmPassword phoneCode:@"" callBack:^(id JSON) {
        
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
