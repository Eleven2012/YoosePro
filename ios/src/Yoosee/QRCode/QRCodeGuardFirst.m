//
//  QRCodeGuardFirst.m
//  Yoosee
//
//  Created by wutong on 15-2-3.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "QRCodeGuardFirst.h"

@implementation QRCodeGuardFirst

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
    lableTitle.textAlignment = NSTextAlignmentCenter;
    [lableTitle setFont:[UIFont boldSystemFontOfSize:15.0]];
    [lableTitle setText:NSLocalizedString(@"add_guard_text00", nil)];
    lableTitle.backgroundColor = [UIColor clearColor];
    [self addSubview:lableTitle];
    [lableTitle release];
    
    
    NSArray* arrayText = [[NSArray alloc]initWithObjects:NSLocalizedString(@"add_guard_text01", nil), NSLocalizedString(@"add_guard_text02", nil), NSLocalizedString(@"add_guard_text03", nil), nil];
    NSArray* arrayIcon = [[NSArray alloc]initWithObjects:@"QRQuardIcon00", @"QRQuardIcon01", @"QRQuardIcon02", nil];
    for (int i=0; i<3; i++) {
        
        UIImage* img = [UIImage imageNamed:[arrayIcon objectAtIndex:i]];
        UIImageView* imgView = [[UIImageView alloc]initWithImage:img];
        if (i==0) {
            imgView.frame = CGRectMake(70, topInterval+50+40*i, 30, 30);
        }
        else if(i==1)
        {
            imgView.frame = CGRectMake(70, topInterval+50+40*i, 30, 30);
        }
        else
        {
            imgView.frame = CGRectMake(70, topInterval+50+40*i, 30, 30);
        }
        [self addSubview:imgView];
        [imgView release];
        
        UILabel* lableTitle = [[UILabel alloc]initWithFrame:CGRectMake(110, topInterval+50+40*i, 150, 30)];
        [lableTitle setFont:[UIFont boldSystemFontOfSize:13.0]];
        [lableTitle setText:[arrayText objectAtIndex:i]];
        lableTitle.backgroundColor = [UIColor clearColor];
        lableTitle.textAlignment = NSTextAlignmentLeft;
        [self addSubview:lableTitle];
        [lableTitle release];
    }
    
    //温馨提示
    NSString*sTip = NSLocalizedString(@"add_guard_text04", nil);
    UILabel* lableTip = [[UILabel alloc]initWithFrame:CGRectMake(25, topInterval+170, width-25*2, 80)];
    lableTip.lineBreakMode = NSLineBreakByWordWrapping; //自动折行设置
    lableTip.numberOfLines = 0;
    lableTip.font = [UIFont boldSystemFontOfSize: 13.0];
    [lableTip setText:sTip];
    lableTip.backgroundColor = [UIColor clearColor];
    [self addSubview:lableTip];
    [lableTip release];
    
    //不再提示
    UIButton* btnTip = [[UIButton alloc]initWithFrame:CGRectMake(25, topInterval+250, 200, 30)];
    [btnTip setImage:[UIImage imageNamed:@"QRQuardIcon03"] forState:UIControlStateNormal];
    [btnTip setImage:[UIImage imageNamed:@"QRQuardIcon04"] forState:UIControlStateSelected];
    btnTip.titleLabel.font = [UIFont boldSystemFontOfSize: 13.0];
    [btnTip setTitle:NSLocalizedString(@"add_guard_text05", nil) forState:UIControlStateNormal];
    [btnTip setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnTip setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, btnTip.bounds.size.width - btnTip.bounds.size.height)];
    [btnTip setTitleEdgeInsets:UIEdgeInsetsMake(0, btnTip.titleLabel.bounds.size.width + btnTip.imageView.bounds.size.width + 30 - btnTip.bounds.size.width, 0, 0)];
    [btnTip layoutIfNeeded];
    btnTip.showsTouchWhenHighlighted = YES;
    [btnTip addTarget:self action:@selector(checkboxClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnTip];
    [btnTip release];
}

-(void)checkboxClick:(UIButton*)btn{
    btn.selected=!btn.selected;//每次点击都改变按钮的状态
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(setQRGuard:)]) {
        BOOL bEnable = !(btn.selected);
        [self.delegate setQRGuard:bEnable];
    }
}
@end