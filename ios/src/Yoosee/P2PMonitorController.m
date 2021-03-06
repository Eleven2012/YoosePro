///
//  P2PMonitorController.m
//  Yoosee
//
//  Created by guojunyi on 14-3-26.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "P2PMonitorController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "P2PClient.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "PAIOUnit.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "Utils.h"
#import "TouchButton.h"
#import "ContactDAO.h"//delete
#import "FListManager.h"//delete
#import "Contact.h"//delete

@interface P2PMonitorController ()
{
    CGFloat _horizontalScreenH;
}
@end

@implementation P2PMonitorController

-(void)dealloc{
    [self.remoteView release];
    [self.bottomView release];//重新调整监控画面
    [self.pressView release];
    [self.controllerRight release];
    [self.controllerRightBg release];//重新调整监控画面
    [self.bottomBarView release];//重新调整监控画面
    [self.numberViewer release];
    [self.scrollView release];//监控界面缩放
    [self.customBorderButton release];
    [self.leftView release];
    [self.clickGPIO0_0Button release];
    [self.clickGPIO0_1Button release];
    [self.clickGPIO0_2Button release];
    [self.clickGPIO0_3Button release];
    [self.clickGPIO0_4Button release];
    [self.clickGPIO2_6Button release];
    [self.lightButton release];
    [self.progressView release];
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

-(void)onClick{
    [self dismissViewControllerAnimated:YES completion:^{
    
    }];
    [[P2PClient sharedClient] p2pHungUp];
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePlayingCommand:) name:RECEIVE_PLAYING_CMD object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    
    NSString *contactId = [[P2PClient sharedClient] callId];
    NSString *contactPassword = [[P2PClient sharedClient] callPassword];
    if ([AppDelegate sharedDefault].isDoorBellAlarm) {//透传连接
        
        [[P2PClient sharedClient] sendCustomCmdWithId:contactId password:contactPassword cmd:@"IPC1anerfa:connect"];
    }
    
    //过滤当前被监控帐号的推送显示
    [AppDelegate sharedDefault].monitoredContactId = contactId;
    
    
    //获取当前被监控帐号的灯状态
    //若设备支持灯设备时，则显示开关按钮；若不支持，则隐藏
    [[P2PClient sharedClient] getLightStateWithDeviceId:contactId password:contactPassword];
    
    //从本地中获取当前被监控的设备ID的defenceState
    NSArray *contacts = [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]];//delete
    for (Contact *contact in contacts) {
        if ([contactId isEqualToString:contact.contactId]) {
            UIButton *defenceButton = (UIButton *)[self.view viewWithTag:4];
            if (contact.defenceState == DEFENCE_STATE_ON) {
                [defenceButton setBackgroundImage:[UIImage imageNamed:@"ic_ctl_lock_on.png"] forState:UIControlStateNormal];
                self.isDefenceOn = YES;
            }else if(contact.defenceState == DEFENCE_STATE_OFF){
                [defenceButton setBackgroundImage:[UIImage imageNamed:@"ic_ctl_lock_off.png"] forState:UIControlStateNormal];
                self.isDefenceOn = NO;
            }
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [NSThread detachNewThreadSelector:@selector(renderView) toTarget:self withObject:nil];
    
    if([AppDelegate sharedDefault].isDoorBellAlarm){//门铃推送,点按开关说话
        self.isTalking = YES;
        [self.pressView setHidden:NO];
        [[PAIOUnit sharedUnit] setSpeckState:NO];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    self.isReject = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.remoteView setCaptureFinishScreen:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_PLAYING_CMD object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    if ([AppDelegate sharedDefault].isDoorBellAlarm) {//透传连接
        NSString *contactId = [[P2PClient sharedClient] callId];
        NSString *contactPassword = [[P2PClient sharedClient] callPassword];
        [[P2PClient sharedClient] sendCustomCmdWithId:contactId password:contactPassword cmd:@"IPC1anerfa:disconnect"];
    }
    
    [AppDelegate sharedDefault].monitoredContactId = nil;
}

#define MESG_SET_GPIO_PERMISSION_DENIED 86
#define MESG_GPIO_CTRL_QUEUE_IS_FULL 87
#define MESG_SET_DEVICE_NOT_SUPPORT 255

#define GPIO0_0 10
#define GPIO0_1 11
#define GPIO0_2 12
#define GPIO0_3 13
#define GPIO0_4 14
#define GPIO2_6 15
- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_SET_GPIO_CTL:
        {
            int result = [[parameter valueForKey:@"result"] intValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.clickGPIO0_0Button.backgroundColor = [UIColor clearColor];
                self.clickGPIO0_1Button.backgroundColor = [UIColor clearColor];
                self.clickGPIO0_2Button.backgroundColor = [UIColor clearColor];
                self.clickGPIO0_3Button.backgroundColor = [UIColor clearColor];
                self.clickGPIO0_4Button.backgroundColor = [UIColor clearColor];
                self.clickGPIO2_6Button.backgroundColor = [UIColor clearColor];
            });
            if (result == 0) {
                //设置成功
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                });
            }else if (result == MESG_SET_GPIO_PERMISSION_DENIED){
                //该GPIO未开放
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.view makeToast:NSLocalizedString(@"not_open", nil)];
                });
            }else if (result == MESG_GPIO_CTRL_QUEUE_IS_FULL){
                //操作过于频繁，之前的操作未执行完
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.view makeToast:NSLocalizedString(@"too_frequent", nil)];
                });
            }else if(result == MESG_SET_DEVICE_NOT_SUPPORT){
                //设备不支持此操作
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.view makeToast:NSLocalizedString(@"not_support_operation", nil)];
                });
            }
        }
            break;
        case RET_GET_LIGHT_SWITCH_STATE:
        {
            int result = [[parameter valueForKey:@"result"] intValue];
            
            if (result == 0) {
                int state = [[parameter valueForKey:@"state"] intValue];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.lightButton setHidden:NO];
                    if (state == 1) {//灯是开状态
                        self.isLightSwitchOn = YES;
                        [self.lightButton setBackgroundImage:[UIImage imageNamed:@"lighton.png"] forState:UIControlStateNormal];
                    }else{
                        self.isLightSwitchOn = NO;
                        [self.lightButton setBackgroundImage:[UIImage imageNamed:@"lightoff.png"] forState:UIControlStateNormal];
                    }
                });
            }
        }
            break;
        case RET_SET_LIGHT_SWITCH_STATE:
        {
            int result = [[parameter valueForKey:@"result"] intValue];
            
            if (result == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.lightButton setHidden:NO];
                    [self.progressView setHidden:YES];
                    [self.progressView stopAnimating];
                    if (self.isLightSwitchOn) {//灯正开着
                        self.isLightSwitchOn = NO;//关灯
                        [self.lightButton setBackgroundImage:[UIImage imageNamed:@"lightoff.png"] forState:UIControlStateNormal];
                    }else{//灯正关着
                        self.isLightSwitchOn = YES;//开灯
                        [self.lightButton setBackgroundImage:[UIImage imageNamed:@"lighton.png"] forState:UIControlStateNormal];
                    }
                });
            }
        }
            break;
        case RET_DEVICE_NOT_SUPPORT:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.clickGPIO0_0Button.backgroundColor = [UIColor clearColor];
                self.clickGPIO0_1Button.backgroundColor = [UIColor clearColor];
                self.clickGPIO0_2Button.backgroundColor = [UIColor clearColor];
                self.clickGPIO0_3Button.backgroundColor = [UIColor clearColor];
                self.clickGPIO0_4Button.backgroundColor = [UIColor clearColor];
                self.clickGPIO2_6Button.backgroundColor = [UIColor clearColor];
                
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
        case ACK_RET_SET_GPIO_CTL:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                }else if(result==2){
                    DLog(@"resend do device update");
                    NSString *contactId = [[P2PClient sharedClient] callId];
                    NSString *contactPassword = [[P2PClient sharedClient] callPassword];
                    
                    [[P2PClient sharedClient] setGpioCtrlWithId:contactId password:contactPassword group:self.lastGroup pin:self.lastPin value:self.lastValue time:self.lastTime];
                }
            });
        }
            break;
        case ACK_RET_GET_LIGHT_STATE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                }else if(result==2){
                    DLog(@"resend do device update");
                    NSString *contactId = [[P2PClient sharedClient] callId];
                    NSString *contactPassword = [[P2PClient sharedClient] callPassword];
                    
                    [[P2PClient sharedClient] getLightStateWithDeviceId:contactId password:contactPassword];
                }
            });
        }
            break;
        case ACK_RET_SET_LIGHT_STATE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    
                    [self.view makeToast:NSLocalizedString(@"device_password_error", nil)];
                }else if(result==2){
                    DLog(@"resend do device update");
                    NSString *contactId = [[P2PClient sharedClient] callId];
                    NSString *contactPassword = [[P2PClient sharedClient] callPassword];
                    
                    if (self.isLightSwitchOn) {//灯正开着
                        [[P2PClient sharedClient] setLightStateWithDeviceId:contactId password:contactPassword switchState:0];//关灯
                    }else{
                        [[P2PClient sharedClient] setLightStateWithDeviceId:contactId password:contactPassword switchState:1];//开灯
                    }
                }
            });
        }
            break;
    }
    
}

- (void)receivePlayingCommand:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int value  = [[parameter valueForKey:@"value"] intValue];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.number = value;
        
        self.numberViewer.text = [NSString stringWithFormat:@"%@ %i",NSLocalizedString(@"number_viewer", nil),self.number];
    });
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isShowControllerBar = YES;
    self.isVideoModeHD = NO;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [[PAIOUnit sharedUnit] setMuteAudio:NO];
    [[PAIOUnit sharedUnit] setSpeckState:YES];
    [self initComponent];
}

- (void)renderView
{
    
    
    GAVFrame * m_pAVFrame ;
    //    [_remoteView setInitialized:YES];
    while (!self.isReject)
    {
        
        if(fgGetVideoFrameToDisplay(&m_pAVFrame))
        {
            //DLog(@"%i:%i",m_pAVFrame->width,m_pAVFrame->height);
            [self.remoteView render:m_pAVFrame];
            vReleaseVideoFrame();

        }
        usleep(10000);
        
        
    }
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (TouchButton *)getControllerButton
{
    TouchButton *button = [TouchButton buttonWithType:UIButtonTypeCustom];
    
    [button setFrame:CGRectMake(0, 0, 50, 38)];
    [button setAlpha:0.5];
    [button setOpaque:YES];
    [button setBackgroundColor:[UIColor darkGrayColor]];
    [button.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [button.layer setBorderWidth:2.0f];
    return button;
}

#define BOTTOM_BAR_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 95.0:50.0)

#define PRESS_LAYOUT_WIDTH_AND_HEIGHT 38

#define CONTROLLER_BTN_COUNT 5
#define PUBLIC_WIDTH_OR_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 95.0:50.0)
#define CONTROLLER_BTN_H_W (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 70.0:40.0)  //布防、声音...高度宽度
#define RESOLUTION_BTN_H (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 44.0:30.0)   //分辨率按钮高度

#define CONTROLLER_RIGHT_ITEM_WIDTH 70
#define CONTROLLER_RIGHT_ITEM_HEIGHT 40

#define CONTROLLER_BTN_TAG_HUNGUP 0
#define CONTROLLER_BTN_TAG_SOUND 1
#define CONTROLLER_BTN_TAG_SCREENSHOT 2
#define CONTROLLER_BTN_TAG_PRESS_TALK 3
#define CONTROLLER_BTN_TAG_DEFENCE_LOCK 4
#define CONTROLLER_BTN_TAG_HD 5
#define CONTROLLER_BTN_TAG_SD 6
#define CONTROLLER_BTN_TAG_LD 7
#define CONTROLLER_BTN_TAG_RESOLUTION 8
#define CONTROLLER_LABEL_TAG_HD 10
#define CONTROLLER_LABEL_TAG_SD 11
#define CONTROLLER_LABEL_TAG_LD 12

#define CONTROLLER_BTN_TAG_GPIO1_0 13  //lock

#define LEFTVIEW_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 88:88)
#define LEFTVIEW_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 120:120)
#define CUSTOM_BORDER_BUTTON_WIDTH 20
#define CUSTOM_BORDER_BUTTON_HEIGHT 45

-(void)initComponent{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    CGRect rect = [AppDelegate getScreenSize:NO isHorizontal:YES];
    CGFloat width = rect.size.width;
    
    CGFloat height = rect.size.height;
    if(CURRENT_VERSION<7.0){
        height +=20;
    }
    _horizontalScreenH = height;
    
    [self.view setBackgroundColor:XBlack];
    
    OpenGLView *glView = [[OpenGLView alloc] init];
    
    BOOL is16B9 = [[P2PClient sharedClient] is16B9];
    if(is16B9){
        CGFloat finalWidth = height*16/9;
        CGFloat finalHeight = height;
        if(finalWidth>width){
            finalWidth = width;
            finalHeight = width*9/16;
        }else{
            finalWidth = height*16/9;
            finalHeight = height;
        }
        glView.frame = CGRectMake((width-finalWidth)/2, (height-finalHeight)/2, finalWidth, finalHeight);
        
    }else{
        glView.frame = CGRectMake((width-height*4/3)/2, 0, height*4/3, height);
    }
    
    self.remoteView = glView;
    self.remoteView.delegate = self;
    [self.remoteView.layer setMasksToBounds:YES];
    
    //监控界面缩放
    NSString * plist = [[NSBundle mainBundle] pathForResource:@"Common-Configuration" ofType:@"plist"];
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
    BOOL isSupportZoom = [dic[@"isSupportZoom"] boolValue];
    if (isSupportZoom) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        scrollView.multipleTouchEnabled = YES;
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = 4.0;
        scrollView.delegate = self;
        scrollView.backgroundColor = [UIColor blackColor];
        
        [scrollView addSubview:self.remoteView];
        [self.view addSubview:scrollView];
        self.scrollView = scrollView;
        [scrollView release];
        [glView release];
    }else{
        [self.view addSubview:self.remoteView];
        [glView release];
    }
    
    
    //双击手势
    UITapGestureRecognizer *doubleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap)];
    doubleTapG.delegate = self;
    [doubleTapG setNumberOfTapsRequired:2];
    [self.remoteView addGestureRecognizer:doubleTapG];
    
    //单击手势
    UITapGestureRecognizer *singleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    singleTapG.delegate = self;
    [singleTapG setNumberOfTapsRequired:1];
    [singleTapG requireGestureRecognizerToFail:doubleTapG];
    [self.remoteView addGestureRecognizer:singleTapG];
    
    //上划手势
    UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    [swipeGestureUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeGestureUp setCancelsTouchesInView:YES];
    [swipeGestureUp setDelaysTouchesEnded:YES];
    [_remoteView addGestureRecognizer:swipeGestureUp];
    
    //下划手势
    UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    [swipeGestureDown setDirection:UISwipeGestureRecognizerDirectionDown];
    
    [swipeGestureDown setCancelsTouchesInView:YES];
    [swipeGestureDown setDelaysTouchesEnded:YES];
    [_remoteView addGestureRecognizer:swipeGestureDown];
    
    //左划手势
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeGestureLeft setCancelsTouchesInView:YES];
    [swipeGestureLeft setDelaysTouchesEnded:YES];
    [_remoteView addGestureRecognizer:swipeGestureLeft];
    
    //右划手势
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeGestureRight setCancelsTouchesInView:YES];
    [swipeGestureRight setDelaysTouchesEnded:YES];
    [_remoteView addGestureRecognizer:swipeGestureRight];
    
    [doubleTapG release];
    [singleTapG release];
    [swipeGestureUp release];
    [swipeGestureDown release];
    [swipeGestureLeft release];
    [swipeGestureRight release];
    
    //右上角的观看人数
    if (is16B9) {
        //text size
        NSString *text = [NSString stringWithFormat:@"%@ %i",NSLocalizedString(@"number_viewer", nil),self.number];
        CGSize textSize = [self sizeWithString:text font:XFontBold_16 maxWidth:MAXFLOAT];
        
        //半透明背景
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(width-textSize.width-15, 5, textSize.width, textSize.height)];
        [bgView setAlpha:0.5];
        [bgView setBackgroundColor:XBlack];
        [self.remoteView addSubview:bgView];
        [bgView release];
        
        UILabel *label11 = [[UILabel alloc] initWithFrame:CGRectMake(width-textSize.width-15, 5, textSize.width, textSize.height)];
        label11.backgroundColor = [UIColor clearColor];
        label11.textAlignment = NSTextAlignmentCenter;
        label11.textColor = XWhite;
        label11.font = XFontBold_16;
        label11.text = [NSString stringWithFormat:@"%@ %i",NSLocalizedString(@"number_viewer", nil),self.number];
        
        [self.remoteView addSubview:label11];
        self.numberViewer = label11;
        [label11 release];
    }
    
    //左边的按住说话弹出的声音图标
    UIView *pressView = [[UIView alloc] initWithFrame:CGRectMake(10, height-PRESS_LAYOUT_WIDTH_AND_HEIGHT-BOTTOM_BAR_HEIGHT, PRESS_LAYOUT_WIDTH_AND_HEIGHT/2, PRESS_LAYOUT_WIDTH_AND_HEIGHT)];
    
    UIImageView *pressLeftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PRESS_LAYOUT_WIDTH_AND_HEIGHT/2, PRESS_LAYOUT_WIDTH_AND_HEIGHT)];
    pressLeftView.image = [UIImage imageNamed:@"ic_voice.png"];
    [pressView addSubview:pressLeftView];
    
    UIImageView *pressRightView = [[UIImageView alloc] initWithFrame:CGRectMake(PRESS_LAYOUT_WIDTH_AND_HEIGHT/2, 0, PRESS_LAYOUT_WIDTH_AND_HEIGHT/2, PRESS_LAYOUT_WIDTH_AND_HEIGHT)];
    NSArray *imagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"amp1.png"],[UIImage imageNamed:@"amp2.png"],[UIImage imageNamed:@"amp3.png"],[UIImage imageNamed:@"amp4.png"],[UIImage imageNamed:@"amp5.png"],[UIImage imageNamed:@"amp6.png"],[UIImage imageNamed:@"amp7.png"],[UIImage imageNamed:@"amp4.png"],[UIImage imageNamed:@"amp5.png"],[UIImage imageNamed:@"amp6.png"],[UIImage imageNamed:@"amp3.png"],[UIImage imageNamed:@"amp5.png"],[UIImage imageNamed:@"amp6.png"],[UIImage imageNamed:@"amp6.png"],[UIImage imageNamed:@"amp3.png"],[UIImage imageNamed:@"amp4.png"],[UIImage imageNamed:@"amp5.png"],[UIImage imageNamed:@"amp5.png"],nil];
    
    pressRightView.animationImages = imagesArray;
    pressRightView.animationDuration = ((CGFloat)[imagesArray count])*200.0f/1000.0f;
    pressRightView.animationRepeatCount = 0;
    [pressRightView startAnimating];
    
    [pressView addSubview:pressRightView];
    [self.view addSubview:pressView];
    [pressView setHidden:YES];
    self.pressView = pressView;
    
    [pressView release];
    [pressLeftView release];
    [pressRightView release];
    
    //右边的画质图标
    int rightItemCount = 0;
    if(is16B9){
        rightItemCount = 3;
    }else{
        rightItemCount = 2;
    }
    //半透明背景
    UIView *controllerRightBg = [[UIView alloc] initWithFrame:CGRectMake(5.0, height, CONTROLLER_RIGHT_ITEM_WIDTH, CONTROLLER_RIGHT_ITEM_HEIGHT*rightItemCount)];
    controllerRightBg.layer.cornerRadius = 1.0f;
    [controllerRightBg setAlpha:0.5];
    [controllerRightBg setBackgroundColor:XBlack];
    self.controllerRightBg = controllerRightBg;
    [self.view addSubview:controllerRightBg];
    [controllerRightBg release];
    
    UIView *controllerRight = [[UIView alloc] initWithFrame:CGRectMake(5.0, height, CONTROLLER_RIGHT_ITEM_WIDTH, CONTROLLER_RIGHT_ITEM_HEIGHT*rightItemCount)];
    self.controllerRight = controllerRight;
    [self.view addSubview:controllerRight];
    //分隔线
    for (int i=1; i < rightItemCount; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, i*CONTROLLER_RIGHT_ITEM_HEIGHT+1.0*(i-1), CONTROLLER_RIGHT_ITEM_WIDTH, 1.0)];
        lineView.backgroundColor = XWhite;
        [controllerRight addSubview:lineView];
        [lineView release];
    }
    
    for(int i=0;i<rightItemCount;i++){
        TouchButton *button = [self getBottomBarButton];
        button.frame = CGRectMake(0, (CONTROLLER_RIGHT_ITEM_HEIGHT+1.0)*i, CONTROLLER_RIGHT_ITEM_WIDTH, CONTROLLER_RIGHT_ITEM_HEIGHT);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width, button.frame.size.height)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = XWhite;
        label.font = [UIFont boldSystemFontOfSize:16.0];
        
        if(rightItemCount==2){//NPC
            if(i==0){
                label.text = NSLocalizedString(@"SD", nil);
                label.tag = CONTROLLER_LABEL_TAG_SD;
                button.tag = CONTROLLER_BTN_TAG_SD;
            }else if(i==1){
                label.text = NSLocalizedString(@"LD", nil);
                label.tag = CONTROLLER_LABEL_TAG_LD;
                label.textColor = XBlue;
                button.tag = CONTROLLER_BTN_TAG_LD;
            }
        }else if(rightItemCount==3){//IPC
            if(i==0){
                label.text = NSLocalizedString(@"HD", nil);
                label.tag = CONTROLLER_LABEL_TAG_HD;
                button.tag = CONTROLLER_BTN_TAG_HD;
            }else if(i==1){
                label.text = NSLocalizedString(@"SD", nil);
                label.tag = CONTROLLER_LABEL_TAG_SD;
                label.textColor = XBlue;
                button.tag = CONTROLLER_BTN_TAG_SD;
            }else if(i==2){
                label.text = NSLocalizedString(@"LD", nil);
                label.tag = CONTROLLER_LABEL_TAG_LD;
                button.tag = CONTROLLER_BTN_TAG_LD;
                //
                
            }
        }
        [button addSubview:label];
        [label release];
        [button addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        [controllerRight addSubview:button];
    }
    
    [controllerRight release];
    
    //重新调整监控画面
    //底部半透明块
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0, height-BOTTOM_BAR_HEIGHT, width, BOTTOM_BAR_HEIGHT)];
    [bottomView setAlpha:0.5];
    [bottomView setBackgroundColor:XBlack];
    self.bottomView = bottomView;
    [self.view addSubview:bottomView];
    [bottomView release];
    
    UIView *bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, height-BOTTOM_BAR_HEIGHT, width, BOTTOM_BAR_HEIGHT)];
    self.bottomBarView  = bottomBarView;
    [self.view addSubview:bottomBarView];
    //左边的画质图标
    TouchButton *resolutionButton = [self getBottomBarButton];
    [resolutionButton setFrame:CGRectMake(5.0, (BOTTOM_BAR_HEIGHT-RESOLUTION_BTN_H)/2.0, CONTROLLER_RIGHT_ITEM_WIDTH, RESOLUTION_BTN_H)];
    resolutionButton.tag = CONTROLLER_BTN_TAG_RESOLUTION;
    if (rightItemCount == 2) {
        [resolutionButton setTitle:NSLocalizedString(@"LD", nil) forState:UIControlStateNormal];
    }else{
        [resolutionButton setTitle:NSLocalizedString(@"SD", nil) forState:UIControlStateNormal];
    }
    [resolutionButton setBackgroundImage:[UIImage imageNamed:@"ic_ctl_resolution.png"] forState:UIControlStateNormal];
    [resolutionButton addTarget:self action:@selector(selectResolutionClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:resolutionButton];
    
    //右边的挂断图标
    TouchButton *hungUpButton = [self getBottomBarButton];
    [hungUpButton setFrame:CGRectMake(width-CONTROLLER_BTN_H_W-5.0, (BOTTOM_BAR_HEIGHT-CONTROLLER_BTN_H_W)/2.0, CONTROLLER_BTN_H_W, CONTROLLER_BTN_H_W)];
    hungUpButton.tag = CONTROLLER_BTN_TAG_HUNGUP;
    [hungUpButton setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_hungup.png"] forState:UIControlStateNormal];
    [hungUpButton addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:hungUpButton];
    
    //布防撤防、声音开关、截图开关、按住说话开关
    UIView *controllBar = [[UIView alloc] initWithFrame:CGRectMake(CONTROLLER_RIGHT_ITEM_WIDTH+5.0, 0.0, width-CONTROLLER_RIGHT_ITEM_WIDTH-5.0-PUBLIC_WIDTH_OR_HEIGHT-5.0, PUBLIC_WIDTH_OR_HEIGHT)];
    controllBar.backgroundColor = [UIColor clearColor];
    int btnCount;
    if ([AppDelegate sharedDefault].mainController.contact.defenceState == DEFENCE_STATE_NO_PERMISSION|| [AppDelegate sharedDefault].contact.defenceState == DEFENCE_STATE_NO_PERMISSION) {//访客密码
        btnCount = CONTROLLER_BTN_COUNT-2;
        CGFloat firstControllerBtnX = (controllBar.frame.size.width-PUBLIC_WIDTH_OR_HEIGHT*btnCount)/2.0;
        for(int i=0;i<btnCount;i++){
            TouchButton *controllerBtn = [self getBottomBarButton];
            controllerBtn.frame = CGRectMake(PUBLIC_WIDTH_OR_HEIGHT*i+firstControllerBtnX, (BOTTOM_BAR_HEIGHT-CONTROLLER_BTN_H_W)/2.0, CONTROLLER_BTN_H_W,CONTROLLER_BTN_H_W);
            
            
            if(i==0){//声音开关
                controllerBtn.tag = CONTROLLER_BTN_TAG_SOUND;
                [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_sound_on.png"] forState:UIControlStateNormal];
            }else if(i==1){//按住说话开关
                controllerBtn.tag = CONTROLLER_BTN_TAG_PRESS_TALK;
                [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_send_audio.png"] forState:UIControlStateNormal];
                [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_send_audio_p.png"] forState:UIControlStateHighlighted];
            }else if(i==2){//截图开关
                controllerBtn.tag = CONTROLLER_BTN_TAG_SCREENSHOT;
                [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_screenshot.png"] forState:UIControlStateNormal];
            }
            
            if(i==1){
                //非本地设备
                NSInteger deviceType1 = [AppDelegate sharedDefault].contact.contactType;
                //本地设备
                NSInteger deviceType2 = [[FListManager sharedFList] getType:[[P2PClient sharedClient] callId]];
                if (deviceType1 == CONTACT_TYPE_DOORBELL || deviceType2 == CONTACT_TYPE_DOORBELL) {//支持门铃,点按开关说话
                    if([AppDelegate sharedDefault].isDoorBellAlarm){//门铃推送
                        
                        [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_send_audio_p.png"] forState:UIControlStateNormal];
                    }
                    
                    [controllerBtn addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
                }else{
                    //不是门铃，则按住说话
                    controllerBtn.delegate = self;
                }
            }else{
                [controllerBtn addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [controllBar addSubview:controllerBtn];
        }
    }else{
//        CGFloat firstControllerBtnX = (controllBar.frame.size.width-PUBLIC_WIDTH_OR_HEIGHT*CONTROLLER_BTN_COUNT)/2.0;
        if ([AppDelegate sharedDefault].isDoorBellAlarm) {
            btnCount = CONTROLLER_BTN_COUNT;
        }else{
            btnCount = CONTROLLER_BTN_COUNT-1;
        }
        
        CGFloat firstControllerBtnX = (controllBar.frame.size.width-PUBLIC_WIDTH_OR_HEIGHT*btnCount)/2.0;
        for(int i=0;i<btnCount;i++){
            TouchButton *controllerBtn = [self getBottomBarButton];
            controllerBtn.frame = CGRectMake(PUBLIC_WIDTH_OR_HEIGHT*i+firstControllerBtnX, (BOTTOM_BAR_HEIGHT-CONTROLLER_BTN_H_W)/2.0, CONTROLLER_BTN_H_W,CONTROLLER_BTN_H_W);
            
            if(i==0){//布防撤防
                controllerBtn.tag = CONTROLLER_BTN_TAG_DEFENCE_LOCK;
                if ([AppDelegate sharedDefault].mainController.contact.defenceState == DEFENCE_STATE_ON || [AppDelegate sharedDefault].contact.defenceState == DEFENCE_STATE_ON) {
                    [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_lock_on.png"] forState:UIControlStateNormal];
                    self.isDefenceOn = YES;
                }else if([AppDelegate sharedDefault].mainController.contact.defenceState == DEFENCE_STATE_OFF || [AppDelegate sharedDefault].contact.defenceState == DEFENCE_STATE_OFF){
                    [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_lock_off.png"] forState:UIControlStateNormal];
                    self.isDefenceOn = NO;
                }
            }else if(i==1){//声音开关
                controllerBtn.tag = CONTROLLER_BTN_TAG_SOUND;
                [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_sound_on.png"] forState:UIControlStateNormal];
            }else if(i==2){//按住说话开关
                controllerBtn.tag = CONTROLLER_BTN_TAG_PRESS_TALK;
                [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_send_audio.png"] forState:UIControlStateNormal];
                [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_send_audio_p.png"] forState:UIControlStateHighlighted];
            }else if(i==3){//截图开关
                controllerBtn.tag = CONTROLLER_BTN_TAG_SCREENSHOT;
                [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_screenshot.png"] forState:UIControlStateNormal];
            }else if(i==4){//输出6秒高电平脉冲按钮
                controllerBtn.tag = CONTROLLER_BTN_TAG_GPIO1_0;
                [controllerBtn setBackgroundImage:[UIImage imageNamed:@"long_press_lock.png"] forState:UIControlStateNormal];
            }
            
            if(i==2){
                //非本地设备
                NSInteger deviceType1 = [AppDelegate sharedDefault].contact.contactType;
                //本地设备
                NSInteger deviceType2 = [[FListManager sharedFList] getType:[[P2PClient sharedClient] callId]];
                if (deviceType1 == CONTACT_TYPE_DOORBELL || deviceType2 == CONTACT_TYPE_DOORBELL) {//支持门铃,点按开关说话
                    if([AppDelegate sharedDefault].isDoorBellAlarm){//门铃推送
                    
                        [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_send_audio_p.png"] forState:UIControlStateNormal];
                    }
                    
                    [controllerBtn addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
                }else{
                    //不是门铃，则按住说话
                    controllerBtn.delegate = self;
                }
            }else{
                [controllerBtn addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [controllBar addSubview:controllerBtn];
        }
    }
    [bottomBarView addSubview:controllBar];
    [controllBar release];
    
    [bottomBarView release];
    //重新调整监控画面
    
    
    //button arrow
    CGFloat customBorderButtonY = (height - CUSTOM_BORDER_BUTTON_HEIGHT)/2.0;
    
    CustomBorderButton *customBorderButton=[CustomBorderButton buttonWithType:UIButtonTypeCustom];
    customBorderButton.frame = CGRectMake(0, customBorderButtonY, CUSTOM_BORDER_BUTTON_WIDTH, CUSTOM_BORDER_BUTTON_HEIGHT);
    
    [customBorderButton setNeedLineTop:true left:true bottom:true right:true];
    [customBorderButton setLineColorTop:[UIColor blackColor] left:[UIColor clearColor] bottom:[UIColor blackColor] right:[UIColor blackColor]];//用同一色边线
    [customBorderButton setLineWidthTop:2.0 left:2.0 bottom:2.0 right:2.0];//设置线的粗细，这里可以随意调整
    
    [customBorderButton setRadiusTopLeft:0 topRight:8.0 bottomLeft:0 bottomRight:8.0];//边线加弧度
    [customBorderButton setClipsToBoundsWithBorder:true];//裁剪掉边线外面的区域
    
    [customBorderButton setFillColor:[UIColor darkGrayColor]];//增加内部填充颜色
    [customBorderButton setAlpha:0.5];
    [customBorderButton setOpaque:YES];
    
    
    [customBorderButton setImage:[UIImage imageNamed:@"button_right"] forState:UIControlStateNormal];
    [customBorderButton setImage:[UIImage imageNamed:@"button_right_selected"] forState:UIControlStateHighlighted];
    [customBorderButton addTarget:self action:@selector(showLeftView:) forControlEvents:UIControlEventTouchUpInside];
    self.customBorderButton = customBorderButton;
    //[self.remoteView addSubview:self.customBorderButton];
    if ([AppDelegate sharedDefault].mainController.contact.defenceState == DEFENCE_STATE_NO_PERMISSION|| [AppDelegate sharedDefault].contact.defenceState == DEFENCE_STATE_NO_PERMISSION) {//访客密码
        
    }else{
        //[self.view addSubview:self.customBorderButton];//隐藏左侧按钮
    }
    
    //左侧界面
    CGFloat leftViewY = (height - LEFTVIEW_HEIGHT)/2.0;
    CustomView *leftView = [[CustomView alloc] initWithFrame:CGRectMake(-LEFTVIEW_WIDTH, leftViewY, LEFTVIEW_WIDTH, LEFTVIEW_HEIGHT)];
    [leftView setNeedLineTop:true left:true bottom:true right:true];
    
    [leftView setLineColorTop:[UIColor blackColor] left:[UIColor blackColor] bottom:[UIColor blackColor] right:[UIColor blackColor]];//用同一色边线
    [leftView setLineWidthTop:2.0 left:2.0 bottom:2.0 right:2.0];//设置线的粗细，这里可以随意调整
    [leftView setRadiusTopLeft:8.0 topRight:8.0 bottomLeft:8.0 bottomRight:8.0];//边线加弧度
    [leftView setClipsToBoundsWithBorder:true];//裁剪掉边线外面的区域
    
    [leftView setFillColor:[UIColor darkGrayColor]];//增加内部填充颜色
    [leftView setAlpha:0.5];
    [leftView setOpaque:YES];
    self.leftView = leftView;
    [self.leftView setHidden:YES];
    if ([AppDelegate sharedDefault].mainController.contact.defenceState == DEFENCE_STATE_NO_PERMISSION|| [AppDelegate sharedDefault].contact.defenceState == DEFENCE_STATE_NO_PERMISSION) {//访客密码
        
    }else{
        //[self.view addSubview:self.leftView];//隐藏左侧按钮
    }
    [leftView release];
    
    
    CGFloat xSpace = 4.0;
    CGFloat ySpace = 4.0;
    CGFloat numLabelW = 12.0;
    CGFloat buttonW = (leftView.frame.size.width - numLabelW - xSpace*4)/2.0;
    CGFloat buttonH = (leftView.frame.size.height - ySpace*4)/3.0;
    int tag = 10;
    for (int i = 0; i < 3; i++) {
        
        UIButton *onButton = [UIButton buttonWithType:UIButtonTypeCustom];
        onButton.frame = CGRectMake(xSpace, (buttonH+ySpace)*i+ySpace, buttonW, buttonH);
        onButton.tag = tag++;
        [onButton setTitle:@"ON" forState:UIControlStateNormal];
        [onButton setTitleColor:XWhite forState:UIControlStateNormal];
        
        onButton.titleLabel.font = XFontBold_12;
        [onButton addTarget:self action:@selector(onOrOffButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.leftView addSubview:onButton];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(2*xSpace+buttonW, (buttonH+ySpace)*i+ySpace, numLabelW, buttonH)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = XWhite;
        label.text = [NSString stringWithFormat:@"%d",i + 1];
        label.font = XFontBold_12;
        label.textAlignment = NSTextAlignmentCenter;
        [self.leftView addSubview:label];
        [label release];
        
        UIButton *offButton = [UIButton buttonWithType:UIButtonTypeCustom];
        offButton.frame = CGRectMake(3*xSpace+buttonW +numLabelW, (buttonH+ySpace)*i+ySpace, buttonW, buttonH);
        offButton.tag = tag++;
        [offButton setTitle:@"OFF" forState:UIControlStateNormal];
        [offButton setTitleColor:XWhite forState:UIControlStateNormal];
        
        offButton.titleLabel.font = XFontBold_12;
        [offButton addTarget:self action:@selector(onOrOffButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.leftView addSubview:offButton];
        
    }
    
    //右侧，灯控制按钮
    //提示器
    UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    progressView.frame = CGRectMake(self.remoteView.frame.size.width-30.0-20.0, (self.remoteView.frame.size.height-30.0)/2, 30.0, 30.0);
    [self.remoteView addSubview:progressView];
    self.progressView = progressView;
    [self.progressView setHidden:YES];
    [progressView release];
    
    //若设备支持灯设备时，则显示开关；若不支持，则隐藏
    UIButton *lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lightButton.frame = CGRectMake(self.remoteView.frame.size.width-30.0-20.0, (self.remoteView.frame.size.height-30.0)/2, 30.0, 30.0);
    lightButton.backgroundColor = [UIColor clearColor];
    [lightButton setBackgroundImage:[UIImage imageNamed:@"lighton.png"] forState:UIControlStateNormal];
    [lightButton addTarget:self action:@selector(btnClickToSetLightState:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.remoteView addSubview:lightButton];
    [lightButton setHidden:YES];
    self.lightButton = lightButton;
    
}

#pragma mark - 开灯或关灯
-(void)btnClickToSetLightState:(UIButton *)button{
    NSString *contactId = [[P2PClient sharedClient] callId];
    NSString *contactPassword = [[P2PClient sharedClient] callPassword];
    if (self.isLightSwitchOn) {//灯正开着
        
        [self.lightButton setHidden:YES];
        [self.progressView setHidden:NO];
        [self.progressView startAnimating];
        
        [[P2PClient sharedClient] setLightStateWithDeviceId:contactId password:contactPassword switchState:0];//关灯
    }else{
        
        [self.lightButton setHidden:YES];
        [self.progressView setHidden:NO];
        [self.progressView startAnimating];
        
        [[P2PClient sharedClient] setLightStateWithDeviceId:contactId password:contactPassword switchState:1];//开灯
    }
    
}

-(void)showLeftView:(UIButton *)button{
    
    if (!self.isShowLeftView) {
        self.isShowLeftView = YES;
        [self.leftView setHidden:NO];
        [UIView animateWithDuration:0.2 animations:^{
            CGRect leftViewRect = self.leftView.frame;
            leftViewRect.origin.x = 0;
            self.leftView.frame = leftViewRect;
            
            CGRect customBorderButtoRect = self.customBorderButton.frame;
            customBorderButtoRect.origin.x = LEFTVIEW_WIDTH;
            self.customBorderButton.frame = customBorderButtoRect;
            
            [self.customBorderButton setImage:[UIImage imageNamed:@"button_left"] forState:UIControlStateNormal];
            [self.customBorderButton setImage:[UIImage imageNamed:@"button_left_selected"] forState:UIControlStateHighlighted];
        } completion:^(BOOL finished) {
            
        }];
    }else{
        self.isShowLeftView = NO;
        [UIView animateWithDuration:0.2 animations:^{
            CGRect leftViewRect = self.leftView.frame;
            leftViewRect.origin.x = -LEFTVIEW_WIDTH;
            self.leftView.frame = leftViewRect;
            
            CGRect customBorderButtoRect = self.customBorderButton.frame;
            customBorderButtoRect.origin.x = 0;
            self.customBorderButton.frame = customBorderButtoRect;
            
            [self.customBorderButton setImage:[UIImage imageNamed:@"button_right"] forState:UIControlStateNormal];
            [self.customBorderButton setImage:[UIImage imageNamed:@"button_right_selected"] forState:UIControlStateHighlighted];
        } completion:^(BOOL finished) {
            [self.leftView setHidden:YES];
        }];
    }
    
}

-(void)onOrOffButtonClick:(UIButton *)button{
    
    //
    int group, pin;
    int value = 5;
    int time[8] = {0};
    time[0] = -1000;
    time[1] = 1000;
    time[2] = -1000;
    time[3] = 1000;
    time[4] = -1000;
    switch (button.tag) {
        case GPIO0_0:
        {
            group = 0;
            pin = 0;
            self.clickGPIO0_0Button = button;
            self.clickGPIO0_0Button.backgroundColor = XBlue;
        }
            break;
        case GPIO0_1:
        {
            group = 0;
            pin = 1;
            self.clickGPIO0_1Button = button;
            self.clickGPIO0_1Button.backgroundColor = XBlue;
        }
            break;
        case GPIO0_2:
        {
            group = 0;
            pin = 2;
            self.clickGPIO0_2Button = button;
            self.clickGPIO0_2Button.backgroundColor = XBlue;
        }
            break;
        case GPIO0_3:
        {
            group = 0;
            pin = 3;
            self.clickGPIO0_3Button = button;
            self.clickGPIO0_3Button.backgroundColor = XBlue;
        }
            break;
        case GPIO0_4:
        {
            group = 0;
            pin = 4;
            self.clickGPIO0_4Button = button;
            self.clickGPIO0_4Button.backgroundColor = XBlue;
        }
            break;
        case GPIO2_6:
        {
            group = 2;
            pin = 6;
            self.clickGPIO2_6Button = button;
            self.clickGPIO2_6Button.backgroundColor = XBlue;
        }
            break;
    }
    
    //记录当前的GPIO设置参数
    self.lastGroup = group;
    self.lastPin = pin;
    self.lastValue = value;
    self.lastTime = time;
    
    NSString *contactId = [[P2PClient sharedClient] callId];
    NSString *contactPassword = [[P2PClient sharedClient] callPassword];
    [[P2PClient sharedClient] setGpioCtrlWithId:contactId password:contactPassword group:group pin:pin value:value time:time];
}

- (TouchButton *)getBottomBarButton//重新调整监控画面
{
    TouchButton *button = [TouchButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    return button;
}

-(void)didShowResolutionInterface{
    BOOL is16B9 = [[P2PClient sharedClient] is16B9];
    //右边的画质图标
    int rightItemCount = 0;
    if(is16B9){
        rightItemCount = 3;
    }else{
        rightItemCount = 2;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect controllerRight = self.controllerRight.frame;
        controllerRight.origin.y = _horizontalScreenH-BOTTOM_BAR_HEIGHT-CONTROLLER_RIGHT_ITEM_HEIGHT*rightItemCount-1.0;
        self.controllerRight.frame = controllerRight;
        self.controllerRightBg.frame = controllerRight;
        
    } completion:^(BOOL finished) {
        self.isAlreadyShowResolution = YES;
    }];
    
}

-(void)didHiddenResolutionInterface{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect controllerRight = self.controllerRight.frame;
        controllerRight.origin.y = _horizontalScreenH;
        self.controllerRight.frame = controllerRight;
        self.controllerRightBg.frame = controllerRight;
        
    } completion:^(BOOL finished) {
        self.isAlreadyShowResolution = NO;
    }];
}

-(void)selectResolutionClick:(UIButton *)button{//重新调整监控画面
    
    
    if (self.isAlreadyShowResolution) {
        [self didHiddenResolutionInterface];
    }else{
        [self didShowResolutionInterface];
    }
    
}

//监控界面缩放
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.remoteView;
}

//监控界面缩放
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    self.remoteView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}

//监控界面缩放
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    if(scale>1.0){
        self.isScale = YES;
        
        if (self.isShowControllerBar) {
            self.isShowControllerBar = !self.isShowControllerBar;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
            [self.controllerRightBg setAlpha:0.0];
            [self.controllerRight setAlpha:0.0];
            [self.bottomView setAlpha:0.0];
            [self.bottomBarView setAlpha:0.0];
            [self.customBorderButton setAlpha:0.0];
            [self.leftView setAlpha:0.0];
            [UIView commitAnimations];
        }
        
    }else{
        self.isScale = NO;
    }
}

-(void)onBegin:(TouchButton *)touchButton widthTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    DLog(@"onBegin");
    [self.pressView setHidden:NO];
    [[PAIOUnit sharedUnit] setSpeckState:NO];
}

-(void)onCancelled:(TouchButton *)touchButton widthTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    DLog(@"onCancelled");
    [self.pressView setHidden:YES];
    [[PAIOUnit sharedUnit] setSpeckState:YES];
}

-(void)onEnded:(TouchButton *)touchButton widthTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    DLog(@"onEnded");
    [self.pressView setHidden:YES];
    [[PAIOUnit sharedUnit] setSpeckState:YES];
}

-(void)onMoved:(TouchButton *)touchButton widthTouches:(NSSet *)touches withEvent:(UIEvent *)event{
    DLog(@"onMoved");
}

-(void)onControllerBtnPress:(id)sender{
    UIButton *button = (UIButton*)sender;
    switch(button.tag){
        case CONTROLLER_BTN_TAG_HUNGUP:
        {
            if(!self.isReject){
                self.isReject = !self.isReject;
                [[P2PClient sharedClient] p2pHungUp];
                MainController *mainController = [AppDelegate sharedDefault].mainController;
                [mainController dismissP2PView];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_PLAYING_CMD object:nil];
            }
            
        }
            break;
        case CONTROLLER_BTN_TAG_SOUND:
        {
            
            BOOL isMute = [[PAIOUnit sharedUnit] muteAudio];
            
            
            DLog(@"onControllerBtnPress:CONTROLLER_BTN_TAG_SOUND");
            if(isMute){
                [[PAIOUnit sharedUnit] setMuteAudio:NO];
                [sender setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_sound_on.png"] forState:UIControlStateNormal];
            }else{
                
                [[PAIOUnit sharedUnit] setMuteAudio:YES];
                [sender setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_sound_off.png"] forState:UIControlStateNormal];
            }
        }
            break;
        case CONTROLLER_BTN_TAG_SCREENSHOT:
        {
            
            [self.remoteView setIsScreenShotting:YES];
        }
            break;
        case CONTROLLER_BTN_TAG_GPIO1_0:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"door_bell", nil) message:NSLocalizedString(@"confirm_open", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
            [alertView show];
            [alertView release];
            
        }
            break;
        case CONTROLLER_BTN_TAG_PRESS_TALK://支持门铃,点按开关说话
        {
            if (self.isTalking) {
                [sender setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_send_audio.png"] forState:UIControlStateNormal];
                
                self.isTalking = NO;
                [self.pressView setHidden:YES];
                [[PAIOUnit sharedUnit] setSpeckState:YES];
            }else{
                [sender setBackgroundImage:[UIImage imageNamed:@"ic_ctl_new_send_audio_p.png"] forState:UIControlStateNormal];
                
                self.isTalking = YES;
                [self.pressView setHidden:NO];
                [[PAIOUnit sharedUnit] setSpeckState:NO];
            }
        }
            break;
        case CONTROLLER_BTN_TAG_DEFENCE_LOCK://重新调整监控画面
        {
            NSString *contactId = [[P2PClient sharedClient] callId];
            NSString *contactPassword = [[P2PClient sharedClient] callPassword];
            
            if (self.isDefenceOn) {
                self.isDefenceOn = NO;
                [sender setBackgroundImage:[UIImage imageNamed:@"ic_ctl_lock_off.png"] forState:UIControlStateNormal];
                
                [[P2PClient sharedClient] setRemoteDefenceWithId:contactId password:contactPassword state:SETTING_VALUE_REMOTE_DEFENCE_STATE_OFF];
            }else{
                self.isDefenceOn = YES;
                [sender setBackgroundImage:[UIImage imageNamed:@"ic_ctl_lock_on.png"] forState:UIControlStateNormal];
                
                [[P2PClient sharedClient] setRemoteDefenceWithId:contactId password:contactPassword state:SETTING_VALUE_REMOTE_DEFENCE_STATE_ON];
            }
        }
            break;
        case CONTROLLER_BTN_TAG_HD:
        {
            [[P2PClient sharedClient] sendCommandType:USR_CMD_VIDEO_CTL andOption:7];
            [self updateRightButtonState:CONTROLLER_BTN_TAG_HD];
            
        }
            break;
        case CONTROLLER_BTN_TAG_SD:
        {
            [[P2PClient sharedClient] sendCommandType:USR_CMD_VIDEO_CTL andOption:5];
            [self updateRightButtonState:CONTROLLER_BTN_TAG_SD];
        }
            break;
        case CONTROLLER_BTN_TAG_LD:
        {
            [[P2PClient sharedClient] sendCommandType:USR_CMD_VIDEO_CTL andOption:6];
            [self updateRightButtonState:CONTROLLER_BTN_TAG_LD];
        }
            break;
    }
}

#pragma mark - UIAlertViewDelegate（开门）
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        
        //GPIO口开锁
        int time[8] = {0};
        time[0] = -1;
        time[1] = 6000;
        time[2] = -1;
        //记录当前的GPIO设置参数
        self.lastGroup = 1;
        self.lastPin = 0;
        self.lastValue = 3;
        self.lastTime = time;
        NSString *contactId = [[P2PClient sharedClient] callId];
        NSString *contactPassword = [[P2PClient sharedClient] callPassword];
        [[P2PClient sharedClient] setGpioCtrlWithId:contactId password:contactPassword group:1 pin:0 value:3 time:time];
        
        
        //透传开锁
        [[P2PClient sharedClient] sendCustomCmdWithId:contactId password:contactPassword cmd:@"IPC1anerfa:unlock"];
        
    }
}

-(void)onScreenShotted:(UIImage *)image{
    UIImage *tempImage = [[UIImage alloc] initWithCGImage:image.CGImage];
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSData *imgData = [NSData dataWithData:UIImagePNGRepresentation(tempImage)];
    [Utils saveScreenshotFileWithId:loginResult.contactId data:imgData];
    [tempImage release];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:NSLocalizedString(@"screenshot_success", nil)];
    });
    
}

#pragma mark - 设置高清、标清选中
-(void)updateRightButtonState:(NSInteger)tag{
    for(UIView *view in self.controllerRight.subviews){
        UILabel *labelHD = (UILabel *)[view viewWithTag:CONTROLLER_LABEL_TAG_HD];
        if (labelHD) {
            labelHD.textColor = XWhite;
        }
        UILabel *labelSD = (UILabel *)[view viewWithTag:CONTROLLER_LABEL_TAG_SD];
        if (labelSD) {
            labelSD.textColor = XWhite;
        }
        UILabel *labelLD = (UILabel *)[view viewWithTag:CONTROLLER_LABEL_TAG_LD];
        if (labelLD) {
            labelLD.textColor = XWhite;
        }
    }
    UIButton *button = (UIButton*)[self.controllerRight viewWithTag:tag];
    
    
    //重新调整监控画面
    UIButton *rButton = (UIButton *)[self.bottomBarView viewWithTag:CONTROLLER_BTN_TAG_RESOLUTION];
    if (tag == CONTROLLER_BTN_TAG_HD) {
        UILabel *label = (UILabel *)[button viewWithTag:CONTROLLER_LABEL_TAG_HD];
        label.textColor = XBlue;
        [rButton setTitle:NSLocalizedString(@"HD", nil) forState:UIControlStateNormal];
    }else if(tag == CONTROLLER_BTN_TAG_SD){
        UILabel *label = (UILabel *)[button viewWithTag:CONTROLLER_LABEL_TAG_SD];
        label.textColor = XBlue;
        [rButton setTitle:NSLocalizedString(@"SD", nil) forState:UIControlStateNormal];
    }else if (tag == CONTROLLER_BTN_TAG_LD){
        UILabel *label = (UILabel *)[button viewWithTag:CONTROLLER_LABEL_TAG_LD];
        label.textColor = XBlue;
        [rButton setTitle:NSLocalizedString(@"LD", nil) forState:UIControlStateNormal];
    }
    
    [self didHiddenResolutionInterface];
}

- (void)swipeUp:(id)sender {
    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
                                                 andOption:USR_CMD_OPTION_PTZ_TURN_DOWN];
}

- (void)swipeDown:(id)sender {
    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
                                                 andOption:USR_CMD_OPTION_PTZ_TURN_UP];
}

- (void)swipeLeft:(id)sender {
    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
                                                 andOption:USR_CMD_OPTION_PTZ_TURN_LEFT];
}

- (void)swipeRight:(id)sender {
    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
                                                 andOption:USR_CMD_OPTION_PTZ_TURN_RIGHT];
}

-(void)onSingleTap{
    
    if (self.isShowControllerBar) {
        self.isShowControllerBar = !self.isShowControllerBar;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [self.controllerRightBg setAlpha:0.0];//重新调整监控画面
        [self.controllerRight setAlpha:0.0];
        [self.bottomView setAlpha:0.0];//重新调整监控画面
        [self.bottomBarView setAlpha:0.0];//重新调整监控画面
        [self.customBorderButton setAlpha:0.0];
        [self.leftView setAlpha:0.0];
        [UIView commitAnimations];
    }else{
        self.isShowControllerBar = !self.isShowControllerBar;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [self.controllerRightBg setAlpha:0.5];//重新调整监控画面
        [self.controllerRight setAlpha:1.0];//重新调整监控画面
        [self.bottomView setAlpha:0.5];//重新调整监控画面
        [self.bottomBarView setAlpha:1.0];//重新调整监控画面
        [self.customBorderButton setAlpha:0.5];
        [self.leftView setAlpha:0.5];
        [UIView commitAnimations];
    }
    
    //重新调整监控画面
    [self didHiddenResolutionInterface];
}

-(void)onDoubleTap{
    
    BOOL is16B9 = [[P2PClient sharedClient] is16B9];
    if(!is16B9){
        CGRect rect = [AppDelegate getScreenSize:NO isHorizontal:YES];
        CGFloat width = rect.size.width;
        CGFloat height = rect.size.height;
        if(CURRENT_VERSION<7.0){
            height +=20;
        }
        DLog(@"screen-size: %f-%f",width,height);
        if (self.isFullScreen) {
            self.isFullScreen = !self.isFullScreen;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
            CGAffineTransform transform;
            transform = CGAffineTransformMakeScale(1.0, 1.0f);
            self.remoteView.transform = transform;
            [UIView commitAnimations];
        }else{
            self.isFullScreen = !self.isFullScreen;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.2];
            if (CURRENT_VERSION>=8.0) {
                CGAffineTransform transform = CGAffineTransformMakeScale(height/(width*4/3),1.0f);
                self.remoteView.transform = transform;
            }else{
                CGAffineTransform transform = CGAffineTransformMakeScale(width/(height*4/3),1.0f);
                self.remoteView.transform = transform;
            }
//            CGAffineTransform transform = CGAffineTransformMakeScale(width/(height*4/3),1.0f);
//            self.remoteView.transform = transform;
            [UIView commitAnimations];
        }
    }
}

#pragma mark - 计算文本的尺寸
-(CGSize)sizeWithString:(NSString*)string font:(UIFont*)font maxWidth:(CGFloat)maxWidth{
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0) {
        CGSize sizeToFit = [string sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)];
        
        return sizeToFit;
    }else{
        NSDictionary *dict = @{NSFontAttributeName : font};
        CGRect rectToFit = [string boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
        return rectToFit.size;
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
    return (interface == UIInterfaceOrientationLandscapeRight );
}

#ifdef IOS6

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}
#endif

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}
@end
