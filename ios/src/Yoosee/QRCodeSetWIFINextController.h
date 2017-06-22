//
//  QRCodeSetWIFINextController.h
//  Yoosee
//
//  Created by gwelltime on 15-3-12.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncUdpSocket.h"
#define ALERT_TAG_SET_FAILED 0
#define ALERT_TAG_SET_SUCCESS 1
@interface QRCodeSetWIFINextController : UIViewController
@property (nonatomic,strong) NSString *uuidString;
@property (nonatomic,strong) NSString *wifiPwd;
@property (nonatomic,strong) UIImageView *qrcodeImageView;
@property (nonatomic,strong) UIView *smartKeyPromptView;
@property (nonatomic,strong) UIButton *promptButton;

@property (nonatomic) BOOL isWaiting;
@property (nonatomic) BOOL isFinish;
@property (strong, nonatomic) GCDAsyncUdpSocket *socket;
@property (assign) BOOL isRun;
@property (nonatomic) BOOL isShowSuccessAlert;
@property (assign) BOOL isPrepared;
@end
