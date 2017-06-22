//
//  P2PPlayingbackController.m
//  Yoosee
//
//  Created by guojunyi on 14-4-23.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "P2PPlayingbackController.h"
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
@interface P2PPlayingbackController ()

@end

@implementation P2PPlayingbackController

-(void)dealloc{

    [self.remoteView release];
    [self.controllerView release];
    [self.pauseIconView release];
    [self.leftTimeLabel release];
    [self.rightTimeLabel release];
    [self.slider release];
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
    [[P2PClient sharedClient] setPlaybackDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePlayingCommand:) name:RECEIVE_PLAYING_CMD object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    self.isReject = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_PLAYING_CMD object:nil];
}


- (void)receivePlayingCommand:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    
    if(key==RECEIVE_PLAYING_CMD_PLAYBACK_STOP){
        DLog(@"RECEIVE_PLAYING_CMD_PLAYBACK_STOP");


        dispatch_async(dispatch_get_main_queue(), ^{
            self.pauseIconView.image = [UIImage imageNamed:@"ic_playing_start.png"];
        });
        
    }else if(key==RECEIVE_PLAYING_CMD_PLAYBACK_START){
        DLog(@"RECEIVE_PLAYING_CMD_PLAYBACK_START");


        dispatch_async(dispatch_get_main_queue(), ^{
            self.pauseIconView.image = [UIImage imageNamed:@"ic_playing_pause.png"];
        });
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [NSThread detachNewThreadSelector:@selector(renderView) toTarget:self withObject:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.isShowControllerBar = YES;
    [[PAIOUnit sharedUnit] setMuteAudio:NO];
    [[PAIOUnit sharedUnit] setSilentAudio:YES];
    [self initComponent];
    
    
}

- (void)renderView
{
    
    
    GAVFrame * m_pAVFrame ;
    
    //    [_remoteView setInitialized:YES];
    
    
    while (!self.isReject)
    {
        if([[P2PClient sharedClient] playbackState]==PLAYBACK_STATE_PAUSE){
            usleep(10000);
            continue;
        }
        
        if(fgGetVideoFrameToDisplay(&m_pAVFrame))
        {
            //DLog(@"%i:%i",m_pAVFrame->width,m_pAVFrame->height);
           
            
            
                uint64_t playValue = (m_pAVFrame->pts-[[P2PClient sharedClient] playback_startTime])/1000000;
                UINT64 totalTime = [[P2PClient sharedClient] playback_totalTime]/1000000;
                self.slider.maximumValue = totalTime;
                NSString *leftTime = [Utils getPlaybackTime:playValue];
                NSString *rightTime = [Utils getPlaybackTime:totalTime];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if(playValue<86400&&!self.isTouchSlider){
                         self.leftTimeLabel.text = leftTime;
                         self.slider.value = playValue;
                    }
                    self.rightTimeLabel.text = rightTime;
                    
                    
                    if([[P2PClient sharedClient] playbackState]==PLAYBACK_STATE_PLAYING){
                        self.pauseIconView.image = [UIImage imageNamed:@"ic_playing_pause.png"];
                    }
                });
            
            
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





#define CONTROLLER_VIEW_HEIGHT 90
#define CONTROLLER_VIEW_TOP_HEIGHT 40
#define CONTROLLER_VIEW_OPERATOR_ITEM_ICON_MARGIN 2
#define CONTROLLER_VIEW_TIME_LABEL_WIDTH 80
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
    
    self.remoteView = glView;
    [self.remoteView.layer setMasksToBounds:YES];
    [self.view addSubview:self.remoteView];
    [glView release];
    
    
    
    UITapGestureRecognizer *doubleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap)];
    doubleTapG.delegate = self;
    [doubleTapG setNumberOfTapsRequired:2];
    [self.remoteView addGestureRecognizer:doubleTapG];
    
    UITapGestureRecognizer *singleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    singleTapG.delegate = self;
    [singleTapG setNumberOfTapsRequired:1];
    [singleTapG requireGestureRecognizerToFail:doubleTapG];
    [self.remoteView addGestureRecognizer:singleTapG];
    
    UIView *controllerView = [[UIView alloc] initWithFrame:CGRectMake(0, height-CONTROLLER_VIEW_HEIGHT, width, CONTROLLER_VIEW_HEIGHT)];
    [controllerView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:144.0/255.0]];
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, CONTROLLER_VIEW_TOP_HEIGHT)];
    
    UILabel *leftTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CONTROLLER_VIEW_TIME_LABEL_WIDTH, CONTROLLER_VIEW_TOP_HEIGHT)];
    leftTimeLabel.textAlignment = NSTextAlignmentCenter;
    leftTimeLabel.textColor = XWhite;
    leftTimeLabel.font = XFontBold_14;
    leftTimeLabel.text = @"00:00:00";
    leftTimeLabel.backgroundColor = XBGAlpha;
    [topView addSubview:leftTimeLabel];
    self.leftTimeLabel = leftTimeLabel;
    [leftTimeLabel release];
    
    UILabel *rightTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(width-10-CONTROLLER_VIEW_TIME_LABEL_WIDTH, 0, CONTROLLER_VIEW_TIME_LABEL_WIDTH, CONTROLLER_VIEW_TOP_HEIGHT)];
    rightTimeLabel.textAlignment = NSTextAlignmentCenter;
    rightTimeLabel.textColor = XWhite;
    rightTimeLabel.font = XFontBold_14;
    rightTimeLabel.text = @"00:00:00";
    rightTimeLabel.backgroundColor = XBGAlpha;
    [topView addSubview:rightTimeLabel];
    self.rightTimeLabel = rightTimeLabel;
    [rightTimeLabel release];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10+CONTROLLER_VIEW_TIME_LABEL_WIDTH+10, 0, width-(10+CONTROLLER_VIEW_TIME_LABEL_WIDTH+10)*2, CONTROLLER_VIEW_TOP_HEIGHT)];
    
    slider.minimumValue = 0;
    slider.enabled = YES;

    
    [slider addTarget:self action:@selector(onSlider:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchUpOutside];
    [slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(onSliderEnd:) forControlEvents:UIControlEventTouchCancel];
    [topView addSubview: slider];
    self.slider = slider;
    [slider release];
    
    [controllerView addSubview:topView];
    [topView release];
    
    UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(0,CONTROLLER_VIEW_TOP_HEIGHT,width,2)];
    [seperator setBackgroundColor:[UIColor grayColor]];
    [controllerView addSubview:seperator];
    [seperator release];
    
    
    for(int i=0;i<5;i++){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*width/5, CONTROLLER_VIEW_TOP_HEIGHT+2, width/5, CONTROLLER_VIEW_HEIGHT-CONTROLLER_VIEW_TOP_HEIGHT-2);
        button.tag = i;
        
        [button setBackgroundImage:[UIImage imageNamed:@"bg_normal_cell_p.png"] forState:UIControlStateHighlighted];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-(button.frame.size.height-CONTROLLER_VIEW_OPERATOR_ITEM_ICON_MARGIN*2))/2, CONTROLLER_VIEW_OPERATOR_ITEM_ICON_MARGIN, button.frame.size.height-CONTROLLER_VIEW_OPERATOR_ITEM_ICON_MARGIN*2, button.frame.size.height-CONTROLLER_VIEW_OPERATOR_ITEM_ICON_MARGIN*2)];
        switch(i){
            case 0:
            {
                iconView.image = [UIImage imageNamed:@"ic_ctl_sound_on.png"];
            }
                break;
            case 1:
            {
                iconView.image = [UIImage imageNamed:@"ic_playing_previous.png"];
            }
                break;
            case 2:
            {
                iconView.image = [UIImage imageNamed:@"ic_playing_start.png"];
                self.pauseIconView = iconView;
            }
                break;
            case 3:
            {
                iconView.image = [UIImage imageNamed:@"ic_playing_next.png"];
            }
                break;
            case 4:
            {
                iconView.image = [UIImage imageNamed:@"ic_ctl_hungup.png"];
            }
                break;
        }
        [button addSubview:iconView];
        
        [button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [iconView release];
        [controllerView addSubview:button];
    }
    
    [self.view addSubview:controllerView];
    self.controllerView = controllerView;
    [controllerView release];
    
}

-(void)onSlider:(id)sender{
    self.isTouchSlider = YES;
    UISlider *slider = (UISlider*)sender;
    self.leftTimeLabel.text = [Utils getPlaybackTime:slider.value];
}

-(void)onSliderEnd:(id)sender{
    DLog(@"onSlideronSliderEnd");
    self.isTouchSlider = NO;
    UISlider *slider = (UISlider*)sender;
    [[P2PClient sharedClient] jump:slider.value];
}

-(void)onButtonPress:(id)sender{
    UIButton *button = (UIButton*)sender;
    
    UIImageView *iconView;
    for(UIView *view in button.subviews){
        if([view isKindOfClass:[UIImageView class]]){

            iconView = (UIImageView*)view;
        }
    }
    
    
    switch(button.tag){
        case 0:
        {
            BOOL isMute = [[PAIOUnit sharedUnit] muteAudio];
            
            if(isMute){
                
                [[PAIOUnit sharedUnit] setMuteAudio:NO];
                
                [iconView setImage:[UIImage imageNamed:@"ic_ctl_sound_on.png"]];
                [iconView layoutSubviews];
            }else{
                
                [[PAIOUnit sharedUnit] setMuteAudio:YES];
                [iconView setImage:[UIImage imageNamed:@"ic_ctl_sound_off.png"]];
                [iconView layoutSubviews];

            }
        }
            break;
        case 1:
        {
            if([[P2PClient sharedClient] getPlaybackCurrentFileIndex]==0){
                [self.view makeToast:NSLocalizedString(@"no_previous_files", nil)];
                return;
            }
            
            [[P2PClient sharedClient] previous];
        }
            break;
        case 2:
        {
            vSetSupperDrop(FALSE);
            if([[P2PClient sharedClient] playbackState]==PLAYBACK_STATE_PLAYING){
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_PAUSE];
                self.pauseIconView.image = [UIImage imageNamed:@"ic_playing_start.png"];
            }else if([[P2PClient sharedClient] playbackState]==PLAYBACK_STATE_PAUSE){
                [[P2PClient sharedClient] setPlaybackState:PLAYBACK_STATE_PLAYING];
                self.pauseIconView.image = [UIImage imageNamed:@"ic_playing_pause.png"];
            }else if([[P2PClient sharedClient] playbackState]==PLAYBACK_STATE_STOP){
                [[P2PClient sharedClient] sendCommandType:USR_CMD_PLAY_CTL
                                                andOption:USR_CMD_OPTION_PLAY];
            }
        }
            break;
        case 3:
        {
            if([[P2PClient sharedClient] getPlaybackCurrentFileIndex]>=([[P2PClient sharedClient] getPlaybackFilesLength]-1)){
                [self.view makeToast:NSLocalizedString(@"no_next_files", nil)];
            }
            
            [[P2PClient sharedClient] next];
        }
            break;
        case 4:
        {
            if(!self.isReject){
                self.isReject = !self.isReject;
                [[P2PClient sharedClient] p2pHungUp];
                //回放挂断问题
            }
        }
            break;
    }
}

-(void)onSingleTap{
    
    if (self.isShowControllerBar) {
        self.isShowControllerBar = !self.isShowControllerBar;
        [UIView transitionWithView:self.controllerView duration:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.controllerView.transform = CGAffineTransformMakeTranslation(0, self.controllerView.frame.size.height);
            }
         
            completion:^(BOOL isFinish){
                        
            }
         ];
    }else{
        self.isShowControllerBar = !self.isShowControllerBar;
        [UIView transitionWithView:self.controllerView duration:0.2 options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                self.controllerView.transform = CGAffineTransformMakeTranslation(0, 0);
            }
         
            completion:^(BOOL isFinish){
                            
            }
         ];
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
            CGAffineTransform transform = CGAffineTransformMakeScale(width/(height*4/3),1.0f);
            self.remoteView.transform = transform;
            [UIView commitAnimations];
        }
    }
}

#pragma mark - 视频回放挂断的回调
-(void)P2PPlaybackReject:(NSDictionary *)info{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:[info objectForKey:@"rejectMsg"]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            usleep(800000);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                MainController *mainController = [AppDelegate sharedDefault].mainController;
                [mainController dismissP2PView];
                //[self dismissViewControllerAnimated:YES completion:nil];//回放挂断问题
            });
        });
    });
}

#pragma mark -
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
