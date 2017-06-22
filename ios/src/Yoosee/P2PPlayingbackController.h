//
//  P2PPlayingbackController.h
//  Yoosee
//
//  Created by guojunyi on 14-4-23.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P2PClient.h"
#import <AVFoundation/AVFoundation.h>
#import "TouchButton.h"
#import "OpenGLView.h"



@interface P2PPlayingbackController : UIViewController<UIGestureRecognizerDelegate,P2PPlaybackDelegate>

@property (nonatomic, strong) OpenGLView *remoteView;
@property (nonatomic) BOOL isReject;
@property (nonatomic) BOOL isTouchSlider;
@property (nonatomic) BOOL isFullScreen;
@property (nonatomic) BOOL isShowControllerBar;

@property (nonatomic, strong) UIView *controllerView;
@property (nonatomic, strong) UIImageView *pauseIconView;

@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UISlider *slider;
@end
