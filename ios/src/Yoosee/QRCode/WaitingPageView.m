//
//  WaitingPageView.m
//  Yoosee
//
//  Created by wutong on 15-2-4.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "WaitingPageView.h"
#import "Constants.h"
#import "YProgressView.h"

@implementation WaitingPageView

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
#define SET_WIFI_CONTENT_BOTTOM_BUTTON_WIDTH 100
#define SET_WIFI_CONTENT_BOTTOM_BUTTON_HEIGHT 32
#define WAITING_CONTENT_VIEW_WIDTH 288
#define WAITING_CONTENT_VIEW_HEIGHT 300

-(void)initCompnents
{
    self.backgroundColor = XBgColor;
    
    //WAITING CONTENT
    UIView *waitingContent = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-WAITING_CONTENT_VIEW_WIDTH)/2, (self.frame.size.height-WAITING_CONTENT_VIEW_HEIGHT)/2, WAITING_CONTENT_VIEW_WIDTH, WAITING_CONTENT_VIEW_HEIGHT)];
    [self addSubview:waitingContent];
    [waitingContent release];
//    waitingContent.backgroundColor = [UIColor orangeColor];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, waitingContent.frame.size.width, 30)];
    titleLable.textColor = XBlack;
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.text = NSLocalizedString(@"waiting_content_prompt01", nil);
    titleLable.backgroundColor = [UIColor clearColor];
    titleLable.font = XFontBold_18;
    [waitingContent addSubview:titleLable];
    [titleLable release];

    
    UIImageView *waitingContentTop = [[UIImageView alloc] initWithFrame:CGRectMake(20, 50, waitingContent.frame.size.width-20*2, waitingContent.frame.size.height*0.4)];
    waitingContentTop.contentMode = UIViewContentModeScaleAspectFit;
    waitingContentTop.image = [UIImage imageNamed:@"img_waiting_set_wifi01.png"];
    [waitingContent addSubview:waitingContentTop];
    [waitingContentTop release];
    
    
    YProgressView *yProgress = [[YProgressView alloc] initWithFrame:CGRectMake((waitingContent.frame.size.width-38)/2, waitingContent.frame.size.height/2+20+20, 38, 38)];
    yProgress.backgroundView.image = [UIImage imageNamed:@"ic_progress_blue.png"];
    [yProgress start];
    [waitingContent addSubview:yProgress];
    [yProgress release];
    
    UILabel *waitingContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, yProgress.frame.origin.y+yProgress.frame.size.height+10, waitingContent.frame.size.width-10*2, 60)];
    waitingContentLabel.lineBreakMode = NSLineBreakByWordWrapping; //自动折行设置
    waitingContentLabel.numberOfLines = 0;
    waitingContentLabel.backgroundColor = [UIColor clearColor];
    waitingContentLabel.textColor = XBlack;
    waitingContentLabel.textAlignment = NSTextAlignmentLeft;
    waitingContentLabel.text = NSLocalizedString(@"waiting_content_prompt02", nil);
    waitingContentLabel.font = XFontBold_16;
    [waitingContent addSubview:waitingContentLabel];
    [waitingContentLabel release];
}


@end
