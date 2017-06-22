//
//  ConnectFailurePromptView.m
//  Yoosee
//
//  Created by gwelltime on 15-3-13.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "ConnectFailurePromptView.h"
#import "Constants.h"

@implementation ConnectFailurePromptView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initCompnents];
    }
    return self;
}

#define QRCODE_IMAGE_WIDTH_HEIGHT 200
#define SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH 150 //set wifi to add device by qr
#define SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT 32
#define WAITING_CONTENT_VIEW_WIDTH 248
#define WAITING_CONTENT_VIEW_HEIGHT 310 //set wifi to add device by qr
#define TITLE_LABEL_HEIGHT 30.0 //set wifi to add device by qr

-(void)initCompnents
{
    self.backgroundColor = XBlack_128;
    
    
    //WAITING CONTENT
    UIView *waitingContent = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-WAITING_CONTENT_VIEW_WIDTH)/2, (self.frame.size.height-WAITING_CONTENT_VIEW_HEIGHT)/2, WAITING_CONTENT_VIEW_WIDTH, WAITING_CONTENT_VIEW_HEIGHT)];
    waitingContent.layer.cornerRadius = 8.0;
    waitingContent.userInteractionEnabled = YES;//影响UIButton的点击事件
    [self addSubview:waitingContent];
    waitingContent.backgroundColor = XWhite;
    
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, WAITING_CONTENT_VIEW_WIDTH, TITLE_LABEL_HEIGHT)];//set wifi to add device by qr
    titleLable.textColor = XBlack;
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = NSLocalizedString(@"connection_failure", nil);
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.font = XFontBold_18;
    [waitingContent addSubview:titleLable];
    [titleLable release];
    
    
    UIImageView *waitingContentTop = [[UIImageView alloc] initWithFrame:CGRectMake(20, TITLE_LABEL_HEIGHT-10, WAITING_CONTENT_VIEW_WIDTH-20*2, WAITING_CONTENT_VIEW_HEIGHT*0.4)];//set wifi to add device by qr
    //waitingContentTop.userInteractionEnabled = YES;
    waitingContentTop.contentMode = UIViewContentModeScaleAspectFit;
    waitingContentTop.image = [UIImage imageNamed:@"img_connect_failure.png"];
    [waitingContent addSubview:waitingContentTop];
    [waitingContentTop release];
    
    
    UILabel *waitingContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, waitingContentTop.frame.origin.y+waitingContentTop.frame.size.height-20, waitingContent.frame.size.width-10*2, 90)];//set wifi to add device by qr
    waitingContentLabel.lineBreakMode = NSLineBreakByWordWrapping; //自动折行设置
    waitingContentLabel.numberOfLines = 0;
    waitingContentLabel.backgroundColor = [UIColor clearColor];
    waitingContentLabel.textColor = XBlack;
    waitingContentLabel.textAlignment = NSTextAlignmentLeft;
    waitingContentLabel.text = NSLocalizedString(@"failure_reason", nil);
    waitingContentLabel.font = XFontBold_16;
    [waitingContent addSubview:waitingContentLabel];
    [waitingContentLabel release];
    
    //再试一次
    UIButton *bottomButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomButton1 addTarget:self action:@selector(connectOnceAgain) forControlEvents:UIControlEventTouchUpInside];
    bottomButton1.frame = CGRectMake((waitingContent.frame.size.width-SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH)/2, waitingContent.frame.size.height-2*(SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT+10), SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH, SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT);//set wifi to add device by qr
    
    UIImage *bottomButton1Image = [UIImage imageNamed:@"bg_blue_button.png"];
    UIImage *bottomButton1Image_p = [UIImage imageNamed:@"bg_blue_button_p.png"];
    bottomButton1Image = [bottomButton1Image stretchableImageWithLeftCapWidth:bottomButton1Image.size.width*0.5 topCapHeight:bottomButton1Image.size.height*0.5];
    bottomButton1Image_p = [bottomButton1Image_p stretchableImageWithLeftCapWidth:bottomButton1Image_p.size.width*0.5 topCapHeight:bottomButton1Image_p.size.height*0.5];
    [bottomButton1 setBackgroundImage:bottomButton1Image forState:UIControlStateNormal];
    [bottomButton1 setBackgroundImage:bottomButton1Image_p forState:UIControlStateHighlighted];
    [bottomButton1 setTitle:NSLocalizedString(@"try_again", nil) forState:UIControlStateNormal];
    [waitingContent addSubview:bottomButton1];
    
    //二维码
    //set wifi to add device by qr
    UIButton *qrButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [qrButton addTarget:self action:@selector(setWifiToAddDeviceByQR) forControlEvents:UIControlEventTouchUpInside];
    qrButton.frame = CGRectMake((waitingContent.frame.size.width-SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH)/2, waitingContent.frame.size.height-SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT-10, SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH, SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT);
    
    UIImage *qrButtonImage = [UIImage imageNamed:@"bg_blue_button.png"];
    UIImage *qrButtonImage_p = [UIImage imageNamed:@"bg_blue_button_p.png"];
    qrButtonImage = [qrButtonImage stretchableImageWithLeftCapWidth:qrButtonImage.size.width*0.5 topCapHeight:qrButtonImage.size.height*0.5];
    qrButtonImage_p = [qrButtonImage_p stretchableImageWithLeftCapWidth:qrButtonImage_p.size.width*0.5 topCapHeight:qrButtonImage_p.size.height*0.5];
    [qrButton setBackgroundImage:qrButtonImage forState:UIControlStateNormal];
    [qrButton setBackgroundImage:qrButtonImage_p forState:UIControlStateHighlighted];
    [qrButton setTitle:NSLocalizedString(@"add_by_qrcode", nil) forState:UIControlStateNormal];
    [waitingContent addSubview:qrButton];
    
    
    [waitingContent release];
}

-(void)setWifiToAddDeviceByQR{//set wifi to add device by qr
    if (self.delegate) {
        [self.delegate connectFailurePromptViewSetWifiToAddDeviceByQR];
    }
}

-(void)connectOnceAgain{
    if (self.delegate) {
        [self.delegate connectOnceAgainButtonClick];
    }
}

@end
