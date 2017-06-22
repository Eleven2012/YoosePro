//
//  QRCodeSetWIFINextController.m
//  Yoosee
//
//  Created by gwelltime on 15-3-12.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "QRCodeSetWIFINextController.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "QRCodeGenerator.h"
#import "YProgressView.h"
#import "FListManager.h"

@interface QRCodeSetWIFINextController ()

@end

@implementation QRCodeSetWIFINextController

-(void)dealloc{
    [self.uuidString release];
    [self.wifiPwd release];
    [self.smartKeyPromptView release];
    [self.qrcodeImageView release];
    [self.promptButton release];
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
-(void)viewWillDisappear:(BOOL)animated{
    self.isWaiting = NO;
    self.isFinish = YES;
    self.isRun = NO;
    if(self.socket){
        [self.socket close];
        self.socket=nil;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    self.qrcodeImageView.image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"EnCtYpE_ePyTcNeEsSiD%@dIsSeCoDe%@eDoC",self.uuidString,self.wifiPwd] imageSize:self.qrcodeImageView.frame.size.width];
    self.isFinish = NO;
}



-(void)viewDidAppear:(BOOL)animated{
    self.isRun = YES;
    self.isPrepared = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(self.isRun){
            if(!self.isPrepared){
                [self prepareSocket];
            }
            usleep(1000000);
        }
    });
}

-(BOOL)prepareSocket{
    GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *error = nil;
    
    
    if (![socket bindToPort:9988 error:&error])
    {
        //NSLog(@"Error binding: %@", [error localizedDescription]);
        return NO;
    }
    if (![socket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", [error localizedDescription]);
        return NO;
    }
    
    if (![socket enableBroadcast:YES error:&error])
    {
        NSLog(@"Error enableBroadcast: %@", [error localizedDescription]);
        return NO;
    }
    
    self.socket = socket;
    self.isPrepared = YES;
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self initComponent];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define QRCODE_IMAGE_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 450:250)
#define SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH 68
#define SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT 32
#define WAITING_CONTENT_VIEW_WIDTH 288
#define WAITING_CONTENT_VIEW_HEIGHT 300

-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:NO];
    [topBar setRightButtonText:NSLocalizedString(@"help", nil)];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.rightButton addTarget:self action:@selector(onHelpPress) forControlEvents:UIControlEventTouchUpInside];
    
    [topBar setTitle:NSLocalizedString(@"qrcode",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    [self.view setBackgroundColor:XBgColor];
    
    UIImageView *qrcodeImage = [[UIImageView alloc] initWithFrame:CGRectMake((width-QRCODE_IMAGE_WIDTH_HEIGHT)/2, 20+NAVIGATION_BAR_HEIGHT, QRCODE_IMAGE_WIDTH_HEIGHT, QRCODE_IMAGE_WIDTH_HEIGHT)];
    qrcodeImage.layer.cornerRadius = 5.0;
    qrcodeImage.layer.borderColor = [XBlack CGColor];
    qrcodeImage.layer.borderWidth = 1.0;
    qrcodeImage.backgroundColor = XWhite;
    
    [self.view addSubview:qrcodeImage];
    self.qrcodeImageView = qrcodeImage;
    [qrcodeImage release];
    
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, self.qrcodeImageView.frame.origin.y+self.qrcodeImageView.frame.size.height+20, width-40, (height-(self.qrcodeImageView.frame.origin.y+self.qrcodeImageView.frame.size.height+20))/2);
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = XBlack;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        label.font = XFontBold_18;
    }else{
        label.font = XFontBold_16;
    }
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"qrcode_prompt", nil);
    [self.view addSubview:label];
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, label.frame.origin.y+label.frame.size.height, width, height-(label.frame.origin.y+label.frame.size.height))];
    
    UIButton *bottomButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomButton1 addTarget:self action:@selector(onBottomButtom1Press) forControlEvents:UIControlEventTouchUpInside];
    bottomButton1.frame = CGRectMake((bottomView.frame.size.width-SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH)/2, (bottomView.frame.size.height-SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT)/2-20, SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH, SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT);
    UIImage *bottomButton1Image = [UIImage imageNamed:@"bg_blue_button.png"];
    UIImage *bottomButton1Image_p = [UIImage imageNamed:@"bg_blue_button_p.png"];
    bottomButton1Image = [bottomButton1Image stretchableImageWithLeftCapWidth:bottomButton1Image.size.width*0.5 topCapHeight:bottomButton1Image.size.height*0.5];
    bottomButton1Image_p = [bottomButton1Image_p stretchableImageWithLeftCapWidth:bottomButton1Image_p.size.width*0.5 topCapHeight:bottomButton1Image_p.size.height*0.5];
    [bottomButton1 setBackgroundImage:bottomButton1Image forState:UIControlStateNormal];
    [bottomButton1 setBackgroundImage:bottomButton1Image_p forState:UIControlStateHighlighted];
    [bottomButton1 setTitle:NSLocalizedString(@"heard", nil) forState:UIControlStateNormal];
    
    [bottomView addSubview:bottomButton1];
    
    [self.view addSubview:bottomView];
    [label release];
    [bottomView release];
    
    
    
    UIView *smartKeyPromptView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    smartKeyPromptView.backgroundColor = XBlack_128;
    
    //WAITING CONTENT
    UIImageView *waitingContent = [[UIImageView alloc] initWithFrame:CGRectMake((smartKeyPromptView.frame.size.width-WAITING_CONTENT_VIEW_WIDTH)/2, (smartKeyPromptView.frame.size.height-WAITING_CONTENT_VIEW_HEIGHT)/2, WAITING_CONTENT_VIEW_WIDTH, WAITING_CONTENT_VIEW_HEIGHT)];
    UIImage *waitingContentImage = [UIImage imageNamed:@"bg_smart_key_prompt.png"];
    waitingContentImage = [waitingContentImage stretchableImageWithLeftCapWidth:waitingContentImage.size.width*0.5 topCapHeight:waitingContentImage.size.height*0.5];
    waitingContent.image = waitingContentImage;
    [smartKeyPromptView addSubview:waitingContent];
    
    UIImageView *waitingContentTop = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, waitingContent.frame.size.width-20*2, waitingContent.frame.size.height/2)];
    waitingContentTop.contentMode = UIViewContentModeScaleAspectFit;
    waitingContentTop.image = [UIImage imageNamed:@"img_waiting_set_wifi.png"];
    [waitingContent addSubview:waitingContentTop];
    [waitingContentTop release];
    
    /*
     * 二维码帮助引导视图
     */
    UIButton * promptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    promptButton.frame = CGRectMake(0, 0, width, height);
    promptButton.backgroundColor = XBlack_128;
    [promptButton addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *helpContent = [[UIImageView alloc] initWithFrame:CGRectMake((smartKeyPromptView.frame.size.width-WAITING_CONTENT_VIEW_WIDTH)/2, (smartKeyPromptView.frame.size.height-WAITING_CONTENT_VIEW_HEIGHT)/2+NAVIGATION_BAR_HEIGHT, WAITING_CONTENT_VIEW_WIDTH, WAITING_CONTENT_VIEW_HEIGHT)];
    UIImage *helpContentImage = [UIImage imageNamed:@"bg_smart_key_prompt.png"];
    helpContentImage = [helpContentImage stretchableImageWithLeftCapWidth:helpContentImage.size.width*0.5 topCapHeight:helpContentImage.size.height*0.5];
    helpContent.image = helpContentImage;
    [promptButton addSubview:helpContent];
    
    UIImageView *helpContentTop = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, waitingContent.frame.size.width-20*2, waitingContent.frame.size.height/2)];
    helpContentTop.contentMode = UIViewContentModeScaleAspectFit;
    helpContentTop.image = [UIImage imageNamed:@"img_scanning_code.png"];
    [helpContent addSubview:helpContentTop];
    [helpContentTop release];
    
    
    YProgressView *yProgress = [[YProgressView alloc] initWithFrame:CGRectMake((waitingContent.frame.size.width-38)/2, waitingContent.frame.size.height/2+20+20, 38, 38)];
    yProgress.backgroundView.image = [UIImage imageNamed:@"ic_progress_blue.png"];
    [yProgress start];
    [waitingContent addSubview:yProgress];
    [yProgress release];
    
    UILabel *waitingContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yProgress.frame.origin.y+yProgress.frame.size.height+10, waitingContent.frame.size.width-20*2, 50)];
    waitingContentLabel.backgroundColor = [UIColor clearColor];
    waitingContentLabel.textColor = XBlack;
    waitingContentLabel.textAlignment = NSTextAlignmentCenter;
    waitingContentLabel.text = NSLocalizedString(@"waiting_content_prompt", nil);
    waitingContentLabel.font = XFontBold_14;
    [waitingContent addSubview:waitingContentLabel];
    [waitingContentLabel release];
    [waitingContent release];
    
    UILabel *helpContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, helpContentTop.frame.origin.y+helpContentTop.frame.size.height+10, waitingContent.frame.size.width-20*2, 50)];
    helpContentLabel.backgroundColor = [UIColor clearColor];
    helpContentLabel.numberOfLines = 0;
    helpContentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    helpContentLabel.textColor = XBlack;
    helpContentLabel.textAlignment = NSTextAlignmentCenter;
    helpContentLabel.text = NSLocalizedString(@"set_scanning_code_prompt", nil);
    helpContentLabel.font = XFontBold_14;
    [helpContent addSubview:helpContentLabel];
    [helpContentLabel release];
    [helpContent release];
    
    
    [self.view addSubview:smartKeyPromptView];
    [self.view addSubview:promptButton];
    self.smartKeyPromptView = smartKeyPromptView;
    self.promptButton = promptButton;
    [smartKeyPromptView release];
    
    [self.smartKeyPromptView setHidden:YES];
    [self.promptButton setHidden:YES];
    
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onHelpPress{
    
    [self.promptButton setHidden:NO];
    
}

-(void)dismissView{
    
    [self.promptButton setHidden:YES];
}

-(void)onBottomButtom1Press{
    [self.smartKeyPromptView setHidden:NO];
    self.isWaiting = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int index = 0;
        while(self.isWaiting){
            DLog(@"%i",index);
            index++;
            if(index>=60){
                break;
            }
            sleep(1.0);
        }
        
        
        if(!self.isFinish){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.smartKeyPromptView setHidden:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"set_wifi_failed_title", nil) message:NSLocalizedString(@"set_wifi_failed_prompt", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil,nil];
                alert.tag = ALERT_TAG_SET_FAILED;
                [alert show];
                [alert release];
            });
            
        }
    });
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==ALERT_TAG_SET_FAILED) {
        if(buttonIndex==0){
            self.isWaiting = NO;
        }
    }else if(alertView.tag==ALERT_TAG_SET_SUCCESS){
        if(buttonIndex==0){
            self.isWaiting = NO;
            [self.navigationController popToRootViewControllerAnimated:YES];
            [[FListManager sharedFList] searchLocalDevices];
        }
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"did send");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"error %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    
    
    if (data) {
        Byte receiveBuffer[1024];
        [data getBytes:receiveBuffer length:1024];
        
        if(receiveBuffer[0]==1){
            NSString *host = nil;
            uint16_t port = 0;
            [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
            
            //int contactId = *(int*)(&receiveBuffer[16]);
            //int type = *(int*)(&receiveBuffer[20]);
            //int flag = *(int*)(&receiveBuffer[24]);
            //DLog(@"%i:%i:%i",contactId,type,flag);
            if(self.isShowSuccessAlert){
                return;
            }
            if(self.isWaiting){
                self.isWaiting = YES;
                self.isShowSuccessAlert = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.smartKeyPromptView setHidden:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"set_wifi_success_title", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil,nil];
                    alert.tag = ALERT_TAG_SET_SUCCESS;
                    [alert show];
                    [alert release];
                });
                
            }
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
