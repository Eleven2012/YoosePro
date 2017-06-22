//
//  P2PVideoController.m
//  Yoosee
//
//  Created by guojunyi on 14-4-17.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "P2PVideoController.h"
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
#import "CameraManager.h"

@interface P2PVideoController ()

@end

@implementation P2PVideoController

-(void)dealloc{
    [self.localView release];
    [self.remoteView release];
    [self.controllerBar release];
    [self.remoteMaskView release];
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


-(void)viewDidAppear:(BOOL)animated{
    [NSThread detachNewThreadSelector:@selector(renderView) toTarget:self withObject:nil];
    [[CameraManager sharedManager] startCamera:YES];
    [[CameraManager sharedManager] addCameraView:self.localView];
}

-(void)viewWillDisappear:(BOOL)animated{
    self.isReject = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[CameraManager sharedManager] stopCamera];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_PLAYING_CMD object:nil];
    [self.remoteView setCaptureFinishScreen:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePlayingCommand:) name:RECEIVE_PLAYING_CMD object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.isShowControllerBar = YES;
    self.isVideoModeHD = NO;
    self.isScreenShotting = NO;
    [[PAIOUnit sharedUnit] setMuteAudio:NO];
    [[PAIOUnit sharedUnit] setSilentAudio:NO];
    [self initComponent];
}

- (void)receivePlayingCommand:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int value  = [[parameter valueForKey:@"value"] intValue];
    if(key==RECEIVE_PLAYING_CMD_CHANGE_VIDEO_STATE){
        if(value==1){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.remoteMaskView setHidden:NO];
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.remoteMaskView setHidden:YES];
            });
        }
    }
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

- (UIButton *)getControllerButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 50, 38)];
    [button setAlpha:0.5];
    [button setOpaque:YES];
    [button setBackgroundColor:[UIColor darkGrayColor]];
    [button.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [button.layer setBorderWidth:2.0f];
    return button;
}

#define CONTROLLER_BAR_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 62:38)
#define CONTROLLER_BAR_BUTTON_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 82:50)

#define CONTROLLER_BTN_COUNT 3

#define CONTROLLER_BTN_TAG_HUNGUP 0
#define CONTROLLER_BTN_TAG_MIKE 1
#define CONTROLLER_BTN_TAG_SWITCH_CAMERA 2

-(void)initComponent{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    CGRect rect = [AppDelegate getScreenSize:NO isHorizontal:YES];
    CGFloat width = rect.size.width;
    
    CGFloat height = rect.size.height;
    if(CURRENT_VERSION<7.0){
        height +=20;
    }
    
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
    
    UIView *remoteMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, glView.frame.size.width, glView.frame.size.height)];
    [remoteMaskView setBackgroundColor:[UIColor blackColor]];
    
    UIImageView *maskIconView = [[UIImageView alloc] initWithFrame:CGRectMake((remoteMaskView.frame.size.width-50)/2, (remoteMaskView.frame.size.height-50)/2, 50, 50)];
    
    [maskIconView setImage:[UIImage imageNamed:@"ic_mask.png"]];
    [remoteMaskView addSubview:maskIconView];
    [maskIconView release];
    [remoteMaskView setHidden:YES];
    
    [glView addSubview:remoteMaskView];
    self.remoteMaskView = remoteMaskView;
    [remoteMaskView release];
    
    self.remoteView = glView;
    [self.remoteView.layer setMasksToBounds:YES];
    [self.view addSubview:self.remoteView];
    [glView release];
    
    
    UIImageView *localView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 120, 90)];
    [localView setBackgroundColor:[UIColor blackColor]];

    [self.view addSubview:localView];
    self.localView = localView;
    [localView release];
    
    UITapGestureRecognizer *doubleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap)];
    doubleTapG.delegate = self;
    [doubleTapG setNumberOfTapsRequired:2];
    [self.remoteView addGestureRecognizer:doubleTapG];
    
    UITapGestureRecognizer *singleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    singleTapG.delegate = self;
    [singleTapG setNumberOfTapsRequired:1];
    [singleTapG requireGestureRecognizerToFail:doubleTapG];
    [self.remoteView addGestureRecognizer:singleTapG];
    
//    UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
//    [swipeGestureUp setDirection:UISwipeGestureRecognizerDirectionUp];
//    [swipeGestureUp setCancelsTouchesInView:YES];
//    [swipeGestureUp setDelaysTouchesEnded:YES];
//    [_remoteView addGestureRecognizer:swipeGestureUp];
//    
//    UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
//    [swipeGestureDown setDirection:UISwipeGestureRecognizerDirectionDown];
//    
//    [swipeGestureDown setCancelsTouchesInView:YES];
//    [swipeGestureDown setDelaysTouchesEnded:YES];
//    [_remoteView addGestureRecognizer:swipeGestureDown];
//    
//    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
//    [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
//    [swipeGestureLeft setCancelsTouchesInView:YES];
//    [swipeGestureLeft setDelaysTouchesEnded:YES];
//    [_remoteView addGestureRecognizer:swipeGestureLeft];
//    
//    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
//    [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
//    [swipeGestureRight setCancelsTouchesInView:YES];
//    [swipeGestureRight setDelaysTouchesEnded:YES];
//    [_remoteView addGestureRecognizer:swipeGestureRight];
    
    UIView *controllBar = [[UIView alloc] initWithFrame:CGRectMake((width-CONTROLLER_BAR_BUTTON_WIDTH*CONTROLLER_BTN_COUNT)/2, height-20-CONTROLLER_BAR_HEIGHT, CONTROLLER_BAR_BUTTON_WIDTH*CONTROLLER_BTN_COUNT, CONTROLLER_BAR_HEIGHT)];
    controllBar.layer.cornerRadius = 8.0f;
    [controllBar.layer setBorderWidth:2];
    [controllBar.layer setMasksToBounds:YES];
    for(int i=0;i<CONTROLLER_BTN_COUNT;i++){
        UIButton *controllerBtn = [self getControllerButton];
        
        if(i==0){
            controllerBtn.tag = CONTROLLER_BTN_TAG_MIKE;
            [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_mike_on.png"] forState:UIControlStateNormal];
            
        }else if(i==1){
            controllerBtn.tag = CONTROLLER_BTN_TAG_SWITCH_CAMERA;
            [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_switch_camera.png"] forState:UIControlStateNormal];
        }else if(i==2){
            controllerBtn.tag = CONTROLLER_BTN_TAG_HUNGUP;
            [controllerBtn setBackgroundImage:[UIImage imageNamed:@"ic_ctl_hungup.png"] forState:UIControlStateNormal];
            
            UIColor *bgRedColor = [UIColor colorWithRed:0.82 green:0.22 blue:0.20 alpha:1.0];
            [controllerBtn setBackgroundColor:bgRedColor];
        }
        controllerBtn.frame = CGRectMake(CONTROLLER_BAR_BUTTON_WIDTH*i, 0, CONTROLLER_BAR_BUTTON_WIDTH,CONTROLLER_BAR_HEIGHT);
        [controllerBtn addTarget:self action:@selector(onControllerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        [controllBar addSubview:controllerBtn];
        
        
    }
    
    
    [self.view addSubview:controllBar];
    self.controllerBar = controllBar;
    [controllBar release];
    
    
}

-(void)onControllerBtnPress:(id)sender{
    UIButton *button = (UIButton*)sender;
    switch(button.tag){
        case CONTROLLER_BTN_TAG_HUNGUP:
        {
            if(!self.isReject){
                self.isReject = !self.isReject;
                [[P2PClient sharedClient] setIsFromVideoController:YES];//视频回放修复
                [[P2PClient sharedClient] p2pHungUp];
                MainController *mainController = [AppDelegate sharedDefault].mainController;
                [mainController dismissP2PView];
            }
            
        }
            break;
        case CONTROLLER_BTN_TAG_MIKE:
        {
            
            BOOL isSilent = [[PAIOUnit sharedUnit] silentAudio];
            
            if(isSilent){
                [[PAIOUnit sharedUnit] setSilentAudio:NO];
                [sender setBackgroundImage:[UIImage imageNamed:@"ic_ctl_mike_on.png"] forState:UIControlStateNormal];
            }else{
                
                [[PAIOUnit sharedUnit] setSilentAudio:YES];
                [sender setBackgroundImage:[UIImage imageNamed:@"ic_ctl_mike_off.png"] forState:UIControlStateNormal];
            }
        }
            break;
        case CONTROLLER_BTN_TAG_SWITCH_CAMERA:
        {
            [[CameraManager sharedManager] cameraChange];
            
        }
            break;
    }
}

//- (void)swipeUp:(id)sender {
//    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
//                                    andOption:USR_CMD_OPTION_PTZ_TURN_DOWN];
//}
//
//- (void)swipeDown:(id)sender {
//    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
//                                    andOption:USR_CMD_OPTION_PTZ_TURN_UP];
//}
//
//- (void)swipeLeft:(id)sender {
//    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
//                                    andOption:USR_CMD_OPTION_PTZ_TURN_LEFT];
//}
//
//- (void)swipeRight:(id)sender {
//    [[P2PClient sharedClient] sendCommandType:USR_CMD_PTZ_CTL
//                                    andOption:USR_CMD_OPTION_PTZ_TURN_RIGHT];
//}

-(void)onSingleTap{
    
    if (self.isShowControllerBar) {
        self.isShowControllerBar = !self.isShowControllerBar;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [self.controllerBar setAlpha:0.0];
        [UIView commitAnimations];
    }else{
        self.isShowControllerBar = !self.isShowControllerBar;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [self.controllerBar setAlpha:1.0];
        [UIView commitAnimations];
    }
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
            //self.remoteView.transform = transform;
            [UIView commitAnimations];
        }
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
