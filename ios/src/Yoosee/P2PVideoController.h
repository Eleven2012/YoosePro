//
//  P2PVideoController.h
//  Yoosee
//
//  Created by guojunyi on 14-4-17.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P2PClient.h"
#import <AVFoundation/AVFoundation.h>

#import "OpenGLView.h"

@interface P2PVideoController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) OpenGLView *remoteView;
@property (nonatomic, strong) UIView *remoteMaskView;
@property (nonatomic, strong) UIImageView *localView;
@property (nonatomic) BOOL isReject;
@property (nonatomic) BOOL isFullScreen;
@property (nonatomic) BOOL isShowControllerBar;
@property (nonatomic) BOOL isVideoModeHD;
@property (nonatomic) BOOL isScreenShotting;
@property (strong, nonatomic) UIView *controllerBar;
@end
