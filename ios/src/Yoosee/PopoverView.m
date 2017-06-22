//
//  PopoverView.m
//  Yoosee
//
//  Created by gwelltime on 15-3-20.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "PopoverView.h"
#import "PopoverButton.h"

@implementation PopoverView

-(void)dealloc{
    [self.backgroundImage release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    
    
    //backgroud image
    UIImageView *backgroundView = [[UIImageView alloc] init];
    backgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.image = self.backgroundImage;
    [self addSubview:backgroundView];
    [backgroundView release];
    
    //智能联机
    PopoverButton *button1 = [PopoverButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(0, 12.0, self.frame.size.width, (self.frame.size.height-13)/2.0);
    [button1 setImage:[UIImage imageNamed:@"img_radar_add.png"] forState:UIControlStateNormal];
    [button1 setTitle:NSLocalizedString(@"qrcode_add", nil) forState:UIControlStateNormal];
    button1.tag = 1;
    button1.backgroundColor = [UIColor clearColor];
    [button1 addTarget:self action:@selector(buttonBeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button1];
    
    //分割线
    UIView *lineView = [[UIView alloc] init];
    lineView.frame = CGRectMake(0, (self.frame.size.height-13)/2.0+12.0, self.frame.size.width, 1);
    lineView.backgroundColor = [UIColor whiteColor];
    [self addSubview:lineView];
    [lineView release];
    
    //手动添加
    PopoverButton *button2 = [PopoverButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(0, (self.frame.size.height-13)/2.0+13.0, self.frame.size.width, (self.frame.size.height-13)/2.0);
    [button2 setImage:[UIImage imageNamed:@"ic_add_contact_manually.png"] forState:UIControlStateNormal];
    [button2 setTitle:NSLocalizedString(@"manually_add", nil) forState:UIControlStateNormal];
    button2.tag = 2;
    button2.backgroundColor = [UIColor clearColor];
    [button2 addTarget:self action:@selector(buttonBeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button2];
    
}

-(void)buttonBeClicked:(UIButton *)sender{
    if (self.delegate) {
        [self.delegate didSelectedPopoverViewRow:sender.tag];
    }
}
@end
