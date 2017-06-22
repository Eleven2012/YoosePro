//
//  QRCodeGuardSecond.m
//  Yoosee
//
//  Created by wutong on 15-2-3.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "QRCodeGuardSecond.h"
#import "Constants.h"

@implementation QRCodeGuardSecond

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
        [self initComponents];
    }
    return self;
}

- (void)initComponents
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat width = screenSize.width;
    
    CGFloat topInterval = 20;
    UILabel* lableTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, topInterval, width, 30)];
    lableTitle.font = XFontBold_18;
    [lableTitle setText:NSLocalizedString(@"add_guard_text06", nil)];  //walanguage
    lableTitle.backgroundColor = [UIColor clearColor];
    lableTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lableTitle];
    [lableTitle release];
    
    UIImage* img = [UIImage imageNamed:@"QRQuardIcon05"];
    UIImageView* imagView = [[UIImageView alloc]initWithImage:img];
    CGFloat imgWidht = width-100;
    CGFloat imgHiegt = imgWidht*(img.size.height/img.size.width);
    imagView.frame = CGRectMake(50, topInterval+50, imgWidht, imgHiegt);
    [self addSubview:imagView];
    [imagView release];
    
    //温馨提示
    NSString*sTip = NSLocalizedString(@"add_guard_text07", nil);
    UILabel* lableTip = [[UILabel alloc]initWithFrame:CGRectMake(25, imagView.frame.origin.y+imagView.frame.size.height+20, width-20*2, 60)];
    [lableTip setText:sTip];
    lableTip.lineBreakMode = NSLineBreakByWordWrapping; //自动折行设置
    lableTip.numberOfLines = 0;
    lableTip.font = XFontBold_16;
    lableTip.textAlignment = NSTextAlignmentCenter;
    lableTip.backgroundColor = [UIColor clearColor];
    [self addSubview:lableTip];
    [lableTip release];
}
@end
