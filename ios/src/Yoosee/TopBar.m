//
//  TopBar.m
//  Yoosee
//
//  Created by guojunyi on 14-4-3.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "TopBar.h"
#import "Constants.h"
@implementation TopBar

-(void)dealloc{
    [self.titleLabel release];
    [self.backButton release];
    [self.rightButton release];
    [self.rightButtonIconView release];
    [self.rightButtonLabel release];
    [super dealloc];
}

#define LEFT_BAR_BTN_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 90:60)
#define LEFT_BAR_BTN_MARGIN (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10:5)

#define RIGHT_BAR_BTN_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 90:60)
#define RIGHT_BAR_BTN_MARGIN (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10:5)
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *backImgView = [[UIImageView alloc] initWithFrame:frame];
        UIImage *backImg = [UIImage imageNamed:@"bg_navigation_bar.png"];
        backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
        backImgView.image = backImg;
        
        [self addSubview:backImgView];
        
        if(CURRENT_VERSION>=7.0){
            frame = CGRectMake(frame.origin.x, frame.origin.y+20, frame.size.width, frame.size.height-20);
        }
        UILabel *textLabel = [[UILabel alloc] initWithFrame:frame];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = XHeadBarTextColor;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:[UIFont boldSystemFontOfSize:XHeadBarTextSize]];
        [backImgView addSubview:textLabel];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(frame.origin.x+LEFT_BAR_BTN_MARGIN, frame.origin.y+LEFT_BAR_BTN_MARGIN, LEFT_BAR_BTN_WIDTH, frame.size.height-LEFT_BAR_BTN_MARGIN*2);
        
        UIImage *backButtonImg = [UIImage imageNamed:@"bg_bar_btn.png"];
        backButtonImg = [backButtonImg stretchableImageWithLeftCapWidth:backButtonImg.size.width*0.5 topCapHeight:backButtonImg.size.height*0.5];
        
        UIImage *backButtonImg_p = [UIImage imageNamed:@"bg_bar_btn_p.png"];
        backButtonImg_p = [backButtonImg_p stretchableImageWithLeftCapWidth:backButtonImg_p.size.width*0.5 topCapHeight:backButtonImg_p.size.height*0.5];
        
        [backButton setBackgroundImage:backButtonImg forState:UIControlStateNormal];
        [backButton setBackgroundImage:backButtonImg_p forState:UIControlStateHighlighted];;
        
        UIImageView *backBtnIconView = [[UIImageView alloc]initWithFrame:CGRectMake((backButton.frame.size.width-backButton.frame.size.height)/2, 0, backButton.frame.size.height, backButton.frame.size.height)];
        backBtnIconView.image = [UIImage imageNamed:@"ic_bar_btn_back.png"];
        [backButton addSubview:backBtnIconView];
        [backBtnIconView release];
        [backButton setHidden:YES];
        [self addSubview:backButton];
        
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(frame.origin.x+(frame.size.width-RIGHT_BAR_BTN_MARGIN-RIGHT_BAR_BTN_WIDTH), frame.origin.y+RIGHT_BAR_BTN_MARGIN, RIGHT_BAR_BTN_WIDTH, frame.size.height-RIGHT_BAR_BTN_MARGIN*2);
        
        //UIImage *rightButtonImg = [UIImage imageNamed:@"bg_bar_btn.png"];
        backButtonImg = [backButtonImg stretchableImageWithLeftCapWidth:backButtonImg.size.width*0.5 topCapHeight:backButtonImg.size.height*0.5];
        
        //UIImage *rightButtonImg_p = [UIImage imageNamed:@"bg_bar_btn_p.png"];
        backButtonImg_p = [backButtonImg_p stretchableImageWithLeftCapWidth:backButtonImg_p.size.width*0.5 topCapHeight:backButtonImg_p.size.height*0.5];
        
        [rightButton setBackgroundImage:backButtonImg forState:UIControlStateNormal];
        [rightButton setBackgroundImage:backButtonImg_p forState:UIControlStateHighlighted];;
        
        UIImageView *rightButtonIconView = [[UIImageView alloc]initWithFrame:CGRectMake((rightButton.frame.size.width-rightButton.frame.size.height)/2, 0, rightButton.frame.size.height, rightButton.frame.size.height)];
        rightButtonIconView.image = [UIImage imageNamed:@""];
        [rightButton addSubview:rightButtonIconView];
        
        self.rightButtonIconView = rightButtonIconView;
        [rightButtonIconView release];
        
        UILabel *rightButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,rightButton.frame.size.width,rightButton.frame.size.height)];
        rightButtonLabel.textAlignment = NSTextAlignmentCenter;
        rightButtonLabel.textColor = XWhite;
        rightButtonLabel.backgroundColor = XBGAlpha;
        [rightButtonLabel setFont:XFontBold_14];
        
        [rightButton addSubview:rightButtonLabel];
        
        self.rightButtonLabel = rightButtonLabel;
        [rightButtonLabel release];
        
        [rightButton setHidden:YES];
        [self addSubview:rightButton];
        
        self.backButton = backButton;
        self.rightButton = rightButton;
        self.titleLabel = textLabel;
        
        [textLabel release];
        [backImgView release];
    }
    return self;
}


-(void)setTitle:(NSString *)title{

    if(self.titleLabel){
        self.titleLabel.text = title;
    }
}

-(void)setBackButtonHidden:(BOOL)hidden{
    if(self.backButton){
        [self.backButton setHidden:hidden];
    }
}

-(void)setRightButtonHidden:(BOOL)hidden{
    if(self.rightButton){
        [self.rightButton setHidden:hidden];
    }
}

-(void)setRightButtonIcon:(UIImage *)img{
    if(self.rightButtonIconView){
        self.rightButtonIconView.image = img;
    }
}

-(void)setRightButtonText:(NSString *)text{
    if(self.rightButtonLabel){
        self.rightButtonLabel.text = text;
    }
}
@end
