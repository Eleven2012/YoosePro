//
//  QRCodeController.m
//  Yoosee
//
//  Created by guojunyi on 14-8-28.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "QRCodeController.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "Constants.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Toast+UIView.h"
#import "QRCodeGenerator.h"
#import "QRCodeNextController.h"
#import "MainController.h"
#import "ParamDao.h"
#import "ConnectFailurePromptView.h"
#import "QRCodeSetWIFINextController.h"//set wifi to add device by qr

@interface QRCodeController ()
{
    BOOL _bShowTip;
    int _tipIndex;
    
    QRCodeGuardFirst* _guardView00;
    QRCodeGuardSecond* _guardView01;
    UIView* _guardView02;
    
    UILabel* _textLable;
    UIImageView* _imageView;
    
    int _conectType;
    
    BOOL _bQuit;
    BOOL _bInitWif;
}
@end

@implementation QRCodeController

-(void)dealloc{
    [self.connectFailurePromptView release];
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
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    [mainController setBottomBarHidden:YES];
    
    if (self.isFailForConnectingWIFI) {
        [self.connectFailurePromptView setHidden:NO];
        [_guardView01 setHidden:NO];
        [_guardView02 setHidden:YES];
        _tipIndex = QRGuard_index01;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    _bQuit = YES;
}

-(void)getWifiLoop
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (!_bQuit)
        {
            NSDictionary *ifs = [self fetchSSIDInfo];
            NSString *ssid = [ifs objectForKey:@"SSID"];
            if(nil != ssid)
            {
                if (!_bInitWif) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.ssidField.text = ssid;
                        self.pwdField.userInteractionEnabled = YES;
                        _bInitWif = YES;
                        return ;
                    });
                }
            }
            else
            {
                if (_bInitWif) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.ssidField.text = @"";
                        self.pwdField.text = @"";
                        self.pwdField.userInteractionEnabled = NO;
                        _bInitWif = NO;
                        return ;
                    });
                }
            }
            sleep(2);
        }
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ParamDao* dao = [[ParamDao alloc]init];
    _bShowTip = [dao getGuardValue];
    [dao release];
    
    [self initComponent];
    [self getWifiLoop];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    CGFloat heightNextBtn = 34;
    CGFloat heightTab = 40;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:YES];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"add_new_device",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    [self.view setBackgroundColor:XBgColor];

    //subview-1 2 ================================================
    if (_bShowTip) {
        _guardView00 = [[QRCodeGuardFirst alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT-heightNextBtn)];
        _guardView00.delegate = self;
        [self.view addSubview:_guardView00];
        [_guardView00 setHidden:YES];//i added
        [_guardView00 release];
        _tipIndex = QRGuard_index00;
        
        _guardView01 = [[QRCodeGuardSecond alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT-heightNextBtn)];
        [self.view addSubview:_guardView01];
        [_guardView01 release];
        [_guardView01 setHidden:NO];
        _tipIndex = QRGuard_index01;//i added
    }
    else
    {
        _tipIndex = QRGuard_index02;
    }
    
    
    //subview-3 ================================================
    _guardView02 = [[UIView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT-heightNextBtn)];
    [self.view addSubview:_guardView02];
    [_guardView02 release];
    
    TabView* tabView = [[TabView alloc]init];
    tabView.frame = CGRectMake(0, 0, width, heightTab);
    [tabView setBtnIndex:0 text:NSLocalizedString(@"add_tab_title00", nil)];
    [tabView setBtnIndex:1 text:NSLocalizedString(@"add_tab_title01", nil)];
    tabView.delegate = self;
    [_guardView02 addSubview:tabView];
    [tabView setHidden:YES];//隐藏，不显示
    [tabView release];

    
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 15+heightTab, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"link wifi", nil);
    field1.font = XFontBold_16;
    field1.userInteractionEnabled = NO;  //只读
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_guardView02 addSubview:field1];
    self.ssidField = field1;
    [field1 release];
    
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, self.ssidField.frame.origin.y+self.ssidField.frame.size.height+10, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        field2.layer.borderWidth = 1;
        field2.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field2.layer.cornerRadius = 5.0;
    }
    field2.textAlignment = NSTextAlignmentLeft;
    field2.placeholder = NSLocalizedString(@"input_wifi_password", nil);
    field2.font = XFontBold_16;
    field2.userInteractionEnabled = NO;  //只读
    field2.borderStyle = UITextBorderStyleRoundedRect;
    field2.returnKeyType = UIReturnKeyDone;
    field2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    field2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [field2 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_guardView02 addSubview:field2];
    self.pwdField = field2;
    [field2 release];
    
    _textLable = [[UILabel alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, 0, self.view.frame.size.width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, 80)];
    _textLable.text = NSLocalizedString(@"scan_prompt01", nil);
    _textLable.font = XFontBold_16;
    _textLable.numberOfLines = 4;
    _textLable.backgroundColor = [UIColor clearColor];
    [_guardView02 addSubview:_textLable];
    [_textLable release];
    
    UIImage *image = [UIImage imageNamed:@"Qcord.png"];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-image.size.width*0.8)/2, CGRectGetMaxY(_textLable.frame)+10, image.size.width*0.8, image.size.height*0.8)];
    _imageView.image = image;
    [_imageView setHidden:YES];
    [_guardView02 addSubview:_imageView];
    [_imageView release];
    
    if (_bShowTip) {
        [_guardView02 setHidden:YES];
    }
    //================================================

    
//    UIButton *saveButton = [[UIButton alloc]init];
//    [saveButton setFrame:CGRectMake(10, self.view.frame.size.height-48, 300, heightNextBtn)];
//    [saveButton.layer setCornerRadius:5.0];//圆角
//    saveButton.backgroundColor = customRedCorlor;
////    [saveButton setBackgroundImage:[UIImage imageNamed:@"add_camera_bg.png"] forState:UIControlStateNormal];
//    [saveButton addTarget:self action:@selector(onMakePress) forControlEvents:UIControlEventTouchUpInside];
//    [saveButton setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
//    saveButton.showsTouchWhenHighlighted = YES;
//    [self.view  addSubview:saveButton];
//    [saveButton release];
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setFrame:CGRectMake((self.view.frame.size.width-300)/2, self.view.frame.size.height-48, 300, heightNextBtn)];
    UIImage *bottomButton1Image = [UIImage imageNamed:@"bg_blue_button"];
    UIImage *bottomButton1Image_p = [UIImage imageNamed:@"bg_blue_button_p"];
    bottomButton1Image = [bottomButton1Image stretchableImageWithLeftCapWidth:bottomButton1Image.size.width*0.5 topCapHeight:bottomButton1Image.size.height*0.5];
    bottomButton1Image_p = [bottomButton1Image_p stretchableImageWithLeftCapWidth:bottomButton1Image_p.size.width*0.5 topCapHeight:bottomButton1Image_p.size.height*0.5];
    [saveButton setBackgroundImage:bottomButton1Image forState:UIControlStateNormal];
    [saveButton setBackgroundImage:bottomButton1Image_p forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(onMakePress) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    //saveButton.showsTouchWhenHighlighted = YES;//不要点击高亮
    [self.view  addSubview:saveButton];
    
    ConnectFailurePromptView *connectFailurePromptView = [[ConnectFailurePromptView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    connectFailurePromptView.delegate = self;
    [self.view addSubview:connectFailurePromptView];
    [connectFailurePromptView setHidden:YES];
    self.connectFailurePromptView = connectFailurePromptView;
    [connectFailurePromptView release];
}

-(void)connectOnceAgainButtonClick{
    self.pwdField.text = @"";
    [self.connectFailurePromptView setHidden:YES];
    self.isFailForConnectingWIFI = NO;
}

-(void)connectFailurePromptViewSetWifiToAddDeviceByQR{//set wifi to add device by qr
    self.pwdField.text = @"";
    [self.connectFailurePromptView setHidden:YES];
    self.isFailForConnectingWIFI = NO;
    
    [_guardView01 setHidden:YES];
    [_guardView02 setHidden:NO];
    _tipIndex = QRGuard_index02;
    self.isSetWifiToAddDeviceByQR = YES;
}

-(void)onKeyBoardDown:(id)sender{
    [self.ssidField resignFirstResponder];
    [self.pwdField resignFirstResponder];
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onMakePress{
//    if (_tipIndex == QRGuard_index00) {
//        [_guardView00 setHidden:YES];
//        [_guardView01 setHidden:NO];
//        _tipIndex = QRGuard_index01;
//        if (!_bShowTip) {
//            ParamDao* dao = [[ParamDao alloc]init];
//            [dao setGuardValue:NO bInsert:NO];
//        }
//    }
    if (_tipIndex == QRGuard_index01)
    {
        [_guardView01 setHidden:YES];
        [_guardView02 setHidden:NO];
        _tipIndex = QRGuard_index02;
    }
    else
    {
        NSString *ssidString = self.ssidField.text;
        NSString *pwdString = self.pwdField.text;
        if (!pwdString) {//ios<7.0
            pwdString = @"";
        }
        if(ssidString.length<=0){
            [self.view makeToast:NSLocalizedString(@"link_wifi", nil)];
            return;
        }
//        if(!pwdString||pwdString.length<=0){
//            [self.view makeToast:NSLocalizedString(@"input_wifi_password", nil)];
//            return;
//        }
        
        //    self.qrcodeImage.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"EnCtYpE_ePyTcNeEsSiD%@dIsSeCoDe%@eDoC",ssidString,pwdString] imageSize:self.qrcodeImage.frame.size.width];
        [self onKeyBoardDown:nil];
        
        QRCodeNextController *qrcodeNextController = [[QRCodeNextController alloc] init];
        qrcodeNextController.uuidString = ssidString;
        qrcodeNextController.wifiPwd = pwdString;
        if (self.isSetWifiToAddDeviceByQR) {//set wifi to add device by qr
            self.isSetWifiToAddDeviceByQR = NO;
            qrcodeNextController.conectType = 1;
            qrcodeNextController.qrCodeController = self;
        }else{
            qrcodeNextController.conectType = 0;
        }
        [self.navigationController pushViewController:qrcodeNextController animated:YES];
        [qrcodeNextController release];
        
    }
}

-(void)setQRGuard:(BOOL)bEnable
{
    _bShowTip = bEnable;
}

-(void)tabViewSetPage:(int)index
{
    if (index == 0) {
        _textLable.text = NSLocalizedString(@"scan_prompt01", nil);
        [_imageView setHidden:YES];
    }
    else
    {
        _textLable.text = NSLocalizedString(@"scan_prompt", nil);
        [_imageView setHidden:NO];
    }
    
    _conectType = index;
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
