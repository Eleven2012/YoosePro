//
//  ModifyDevicePasswordController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ModifyDevicePasswordController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Constants.h"
#import "Contact.h"
#import "TopBar.h"
#import "Toast+UIView.h"
#import "MBProgressHUD.h"

#import "FListManager.h"
@interface ModifyDevicePasswordController ()

@end

@implementation ModifyDevicePasswordController

-(void)dealloc{
    [self.contact release];
    [self.lastSetOriginPassowrd release];
    [self.lastSetNewPassowrd release];
    [self.pwdStrengthView release];//password strength2
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

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //write code here...
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];//password strength2
    
    /*
     *移除对键盘将要显示、收起的监听
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.field2];//password strength2
    
    /*
     *设置通知监听者，监听键盘的显示、收起通知
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        
        case RET_SET_DEVICE_PASSWORD:
        {
            
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0){
                
                self.contact.contactPassword = self.lastSetNewPassowrd;
                [[FListManager sharedFList] update:self.contact];
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
        case ACK_RET_SET_DEVICE_PASSWORD:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"original_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend set device password");
                    [[P2PClient sharedClient] setDevicePasswordWithId:self.contact.contactId password:self.lastSetOriginPassowrd newPassword:self.lastSetNewPassowrd];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_SET_DEVICE_PASSWORD:%i",result);
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
    [topBar setTitle:NSLocalizedString(@"modify_manager_password", nil)];
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
    field1.placeholder = NSLocalizedString(@"input_original_password", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.secureTextEntry = YES;
    field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.field1 = field1;
    field1.tag = 11;//password strength2
    field1.delegate = self;//password strength2
    [contentView addSubview:field1];
    [field1 release];
    
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20*2+TEXT_FIELD_HEIGHT, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field2.layer.borderWidth = 1;
        field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field2.layer.cornerRadius = 5.0;
    }
    field2.textAlignment = NSTextAlignmentLeft;
    field2.placeholder = NSLocalizedString(@"input_new_password", nil);
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.secureTextEntry = YES;
    field2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.field2 = field2;
    field2.tag = 12;//password strength2
    field2.delegate = self;//password strength2
    [contentView addSubview:field2];
    [field2 release];
    
    UITextField *field3 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 20*3+TEXT_FIELD_HEIGHT*2, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field3.layer.borderWidth = 1;
        field3.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field3.layer.cornerRadius = 5.0;
    }
    field3.textAlignment = NSTextAlignmentLeft;
    field3.placeholder = NSLocalizedString(@"confirm_input", nil);
    field3.borderStyle = UITextBorderStyleRoundedRect;
    field3.returnKeyType = UIReturnKeyDone;
    field3.secureTextEntry = YES;
    field3.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field3.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field3.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.field3 = field3;
    field3.tag = 13;//password strength2
    field3.delegate = self;//password strength2
    [contentView addSubview:field3];
    [field3 release];
    
    
    //password strength2
    //密码强度UI显示，红（弱）、橙（中）、绿（强）3种强度
    UIView *pwdStrengthView = [[UIView alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, self.field3.frame.origin.y+TEXT_FIELD_HEIGHT+10, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT/2)];
    [contentView addSubview:pwdStrengthView];
    [pwdStrengthView setHidden:YES];
    self.pwdStrengthView = pwdStrengthView;
    [pwdStrengthView release];
    //
    CGFloat indicatorViewWidth = (self.pwdStrengthView.frame.size.width-4-60.0)/3;
    for (int i = 0; i < 3; i++) {
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.frame = CGRectMake(i*(indicatorViewWidth+2), (self.pwdStrengthView.frame.size.height-progressView.frame.size.height)/2, indicatorViewWidth, 20.0);
        //更改进度条高度
        //progressView.transform = CGAffineTransformMakeScale(1.0f,5.0f);
        progressView.tag = 100+i;
        [self.pwdStrengthView addSubview:progressView];
        [progressView release];
    }
    //弱、中、强文字
    UILabel *pwdStrengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(3*(indicatorViewWidth+2), (self.pwdStrengthView.frame.size.height-20.0)/2, 60.0, 20.0)];
    pwdStrengthLabel.text = NSLocalizedString(@"weak", nil);
    pwdStrengthLabel.textColor = XBlack_128;
    pwdStrengthLabel.textAlignment = NSTextAlignmentLeft;
    pwdStrengthLabel.tag = 1111;
    pwdStrengthLabel.backgroundColor = XBGAlpha;
    [pwdStrengthLabel setFont:XFontBold_14];
    [self.pwdStrengthView addSubview:pwdStrengthLabel];
    [pwdStrengthLabel release];
    
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

#pragma mark - 监听键盘
#pragma mark 键盘将要显示时，调用
-(void)onKeyBoardWillShow:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    //keyBoard frame
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    DLog(@"%f",rect.size.height);
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        CGFloat offset1 = self.view.frame.size.height-NAVIGATION_BAR_HEIGHT - self.pwdStrengthView.frame.origin.y - self.pwdStrengthView.frame.size.height;
                        
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

-(void)onSavePress{
    //密码过于简单，请重新输入
    int pwdStrength = [self pwdStrengthWithPwd:self.field2.text];
    if (pwdStrength == 0) {//弱（红）
        [self.view makeToast:NSLocalizedString(@"pwd_too_simple", nil)];
        return;
        
    }
    
    
    NSString *originalPassword = self.field1.text;
    NSString *newPassword = self.field2.text;
    NSString *confirmPassword = self.field3.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]*$"];
    
    if(!originalPassword||!originalPassword.length>0){
        [self.view makeToast:NSLocalizedString(@"input_original_password", nil)];
        return;
    }
    
    if([predicate evaluateWithObject:originalPassword]==NO){
        [self.view makeToast:NSLocalizedString(@"password_number_format_error", nil)];
        return;
    }
    
    if(!newPassword||!newPassword.length>0){
        [self.view makeToast:NSLocalizedString(@"input_new_password", nil)];
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
    
    if(!confirmPassword||!confirmPassword.length>0){
        [self.view makeToast:NSLocalizedString(@"confirm_input", nil)];
        return;
    }
    
    if(![newPassword isEqualToString:confirmPassword]){
        [self.view makeToast:NSLocalizedString(@"two_passwords_not_match", nil)];
        return;
    }
    
    self.progressAlert.dimBackground = YES;
    [self.progressAlert show:YES];
    self.lastSetNewPassowrd = newPassword;
    self.lastSetOriginPassowrd = originalPassword;
    [[P2PClient sharedClient] setDevicePasswordWithId:self.contact.contactId password:originalPassword newPassword:newPassword];
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{//password strength2
    if (textField.tag == 12) {
        //开始进入编辑状态，显示密码强度
        [self.pwdStrengthView setHidden:NO];
    }else{
        //隐藏密码强度
        [self.pwdStrengthView setHidden:YES];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //密码框只许输入数字值
    return [self validateNumber:string];
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    //隐藏密码强度
    [self.pwdStrengthView setHidden:YES];
    
    return YES;
}

#pragma mark - UITextFieldTextDidChangeNotification
//已经开始编辑
- (void)textFieldChanged:(id)sender//password strength2
{
    //显示密码的强度
    UIProgressView *progressView100 = (UIProgressView *)[self.pwdStrengthView viewWithTag:100];
    UIProgressView *progressView101 = (UIProgressView *)[self.pwdStrengthView viewWithTag:101];
    UIProgressView *progressView102 = (UIProgressView *)[self.pwdStrengthView viewWithTag:102];
    UILabel *pwdStrengthLabel = (UILabel *)[self.pwdStrengthView viewWithTag:1111];
    
    int pwdStrength = [self pwdStrengthWithPwd:self.field2.text];
    if (pwdStrength == 0) {//弱（红）
        progressView100.progress = 1.0;
        progressView101.progress = 0.0;
        progressView102.progress = 0.0;
        progressView100.progressTintColor = [UIColor colorWithRed:249/255.0 green:0.0 blue:6/255.0 alpha:1.0];
        //文字
        pwdStrengthLabel.text = NSLocalizedString(@"weak", nil);
        pwdStrengthLabel.textColor = [UIColor colorWithRed:249/255.0 green:0.0 blue:6/255.0 alpha:1.0];
    }else if (pwdStrength == 1){//中（橙）
        progressView100.progress = 1.0;
        progressView101.progress = 1.0;
        progressView102.progress = 0.0;
        progressView100.progressTintColor = [UIColor colorWithRed:252/255.0 green:134/255.0 blue:8/255.0 alpha:1.0];
        progressView101.progressTintColor = [UIColor colorWithRed:252/255.0 green:134/255.0 blue:8/255.0 alpha:1.0];
        //文字
        pwdStrengthLabel.text = NSLocalizedString(@"general", nil);
        pwdStrengthLabel.textColor = [UIColor colorWithRed:252/255.0 green:134/255.0 blue:8/255.0 alpha:1.0];
    }else if (pwdStrength == 2){//强（绿）
        progressView102.progress = 1.0;
        progressView101.progress = 1.0;
        progressView102.progress = 1.0;
        progressView100.progressTintColor = [UIColor colorWithRed:46/255.0 green:203/255.0 blue:5/255.0 alpha:1.0];
        progressView101.progressTintColor = [UIColor colorWithRed:46/255.0 green:203/255.0 blue:5/255.0 alpha:1.0];
        progressView102.progressTintColor = [UIColor colorWithRed:46/255.0 green:203/255.0 blue:5/255.0 alpha:1.0];
        //文字
        pwdStrengthLabel.text = NSLocalizedString(@"strong", nil);
        pwdStrengthLabel.textColor = [UIColor colorWithRed:46/255.0 green:203/255.0 blue:5/255.0 alpha:1.0];
    }else{
        progressView100.progress = 0.0;
        progressView101.progress = 0.0;
        progressView102.progress = 0.0;
        //文字
        pwdStrengthLabel.text = NSLocalizedString(@"weak", nil);
        pwdStrengthLabel.textColor = XBlack_128;
    }
}

-(int)pwdStrengthWithPwd:(NSString *)pwd{
    int weakPwd = 0;//弱密码
    int midPwd = 1;//中密码
    int strongPwd = 2;//强密码
    int otherSt = 3;//密码框为空
    
    BOOL isWeak = [self isWeakPasswordStrengthWithPWD:pwd];
    if ((pwd.length > 0 && pwd.length < 6) || isWeak){
        return weakPwd;
        
    }else if (pwd.length >= 6 && pwd.length <= 9){
        return midPwd;
        
    }else if (pwd.length > 9){
        return strongPwd;
        
    }else{
        return otherSt;
    }
}

-(BOOL)isWeakPasswordStrengthWithPWD:(NSString *)pwd{//password strength2
    BOOL isWeak = NO;
    
    //连号
    if (pwd.length >= 6) {
        int temp1 = (int)[pwd characterAtIndex:0];
        int temp2 = (int)[pwd characterAtIndex:1];
        int sub = abs(temp1 - temp2);
        for (int i = 1; i < pwd.length; i++) {
            int temp = (int)[pwd characterAtIndex:i]-(int)[pwd characterAtIndex:i-1];
            if (abs(temp) != sub) {
                isWeak = NO;
                break;
            }
            isWeak = YES;
        }
    }
    if (isWeak) {
        return isWeak;
    }
    
    //同号
    if (pwd.length >= 6) {
        int pwd0 = (int)[pwd characterAtIndex:0];
        for (int i = 0; i < pwd.length; i++) {
            if (pwd0 == (int)[pwd characterAtIndex:i]) {
                isWeak = YES;
            }else{
                isWeak = NO;
                break;
            }
        }
    }
    
    return isWeak;
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
