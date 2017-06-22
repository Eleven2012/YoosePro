//
//  QRCodeController.h
//  Yoosee
//
//  Created by guojunyi on 14-8-28.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeGuardFirst.h"
#import "QRCodeGuardSecond.h"
#import "TabView.h"
#import "ConnectFailurePromptView.h"

enum
{
    QRGuard_index00,
    QRGuard_index01,
    QRGuard_index02
};


@interface QRCodeController : UIViewController<QRGuardDelegate, tabviewDelegate, ConnectFailurePromptViewDelegate>
@property (nonatomic,strong) UITextField *ssidField;
@property (nonatomic,strong) UITextField *pwdField;
@property (nonatomic,strong) UIImageView *qrcodeImage;

@property (nonatomic) BOOL isFailForConnectingWIFI;
@property (nonatomic,strong) ConnectFailurePromptView *connectFailurePromptView;
@property (nonatomic) BOOL isSetWifiToAddDeviceByQR;//set wifi to add device by qr
@end
