//
//  QRCodeSetWIFIController.m
//  Yoosee
//
//  Created by gwelltime on 15-3-12.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "QRCodeSetWIFIController.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "Constants.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Toast+UIView.h"
#import "QRCodeGenerator.h"
#import "QRCodeSetWIFINextController.h"
#import "MainController.h"

@interface QRCodeSetWIFIController ()

@end

@implementation QRCodeSetWIFIController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    [mainController setBottomBarHidden:YES];
    NSDictionary *ifs = [self fetchSSIDInfo];
    NSLog(@"ifs:%@",ifs);
    NSString *ssid = [ifs objectForKey:@"SSID"];
    NSLog(@"ssid：%@",ssid);
    if(nil==ssid){
        self.ssidField.text = @"";
    }else{
        self.ssidField.text = ssid;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initComponent];
    // Do any additional setup after loading the view.
}

- (id)fetchSSIDInfo
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
        [info release];
    }
    [ifs release];
    return [info autorelease];
}

#define QRCODE_IMAGE_WIDTH_HEIGHT 200
-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:NO];
    
    [topBar setRightButtonText:NSLocalizedString(@"next", nil)];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.rightButton addTarget:self action:@selector(onMakePress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"qrcode",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    [self.view setBackgroundColor:XBgColor];
    DLog(@"window:%f  view:%f",height,self.view.frame.size.height);
    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"input_ssid", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:field1];
    self.ssidField = field1;
    [field1 release];
    
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, self.ssidField.frame.origin.y+self.ssidField.frame.size.height+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field2.layer.borderWidth = 1;
        field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field2.layer.cornerRadius = 5.0;
    }
    
    field2.textAlignment = NSTextAlignmentLeft;
    field2.placeholder = NSLocalizedString(@"input_wifi_password", nil);
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field2 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:field2];
    self.pwdField = field2;
    [field2 release];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.pwdField.frame.origin.y+self.pwdField.frame.size.height, width, height-(self.pwdField.frame.origin.y+self.pwdField.frame.size.height))];
    UIImageView *qrcodeImage = [[UIImageView alloc] initWithFrame:CGRectMake((bottomView.frame.size.width-QRCODE_IMAGE_WIDTH_HEIGHT)/2, (bottomView.frame.size.height-QRCODE_IMAGE_WIDTH_HEIGHT)/2, QRCODE_IMAGE_WIDTH_HEIGHT, QRCODE_IMAGE_WIDTH_HEIGHT)];
    qrcodeImage.layer.cornerRadius = 5.0;
    qrcodeImage.layer.borderColor = [XBlack CGColor];
    qrcodeImage.layer.borderWidth = 1.0;
    qrcodeImage.backgroundColor = XWhite;
    
    [bottomView addSubview:qrcodeImage];
    [self.view addSubview:bottomView];
    self.qrcodeImage = qrcodeImage;
    [qrcodeImage release];
    [bottomView release];
    
    [bottomView setHidden:YES];
    
}

-(void)onKeyBoardDown:(id)sender{
    [self.ssidField resignFirstResponder];
    [self.pwdField resignFirstResponder];
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onMakePress{
    NSString *ssidString = self.ssidField.text;
    NSString *pwdString = self.pwdField.text;
    if(ssidString.length<=0){
        [self.view makeToast:NSLocalizedString(@"input_ssid", nil)];
        return;
    }
    
    //    self.qrcodeImage.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"EnCtYpE_ePyTcNeEsSiD%@dIsSeCoDe%@eDoC",ssidString,pwdString] imageSize:self.qrcodeImage.frame.size.width];
    [self onKeyBoardDown:nil];
    QRCodeSetWIFINextController *qrcodeNextController = [[QRCodeSetWIFINextController alloc] init];
    qrcodeNextController.uuidString = ssidString;
    qrcodeNextController.wifiPwd = pwdString;
    [self.navigationController pushViewController:qrcodeNextController animated:YES];
    [qrcodeNextController release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
