//
//  RadioButton.m
//  Yoosee
//
//  Created by guojunyi on 14-5-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "RadioButton.h"
#import "Constants.h"
@implementation RadioButton

#define LEFT_ICON_WIDTH_HEIGHT 24
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImageView *leftIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (frame.size.height-LEFT_ICON_WIDTH_HEIGHT)/2, LEFT_ICON_WIDTH_HEIGHT, LEFT_ICON_WIDTH_HEIGHT)];
        leftIconView.image = [UIImage imageNamed:@"ic_radio_button.png"];
        self.leftIconView = leftIconView;
        [leftIconView release];
        [self addSubview:self.leftIconView];
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(10+LEFT_ICON_WIDTH_HEIGHT, 0, frame.size.width-10-LEFT_ICON_WIDTH_HEIGHT, frame.size.height)];
        labelView.textAlignment = NSTextAlignmentCenter;
        labelView.textColor = XBlack;
        labelView.font = XFontBold_14;
        labelView.backgroundColor = XBGAlpha;
        self.labelView = labelView;
        [labelView release];
        [self addSubview:self.labelView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setText:(NSString *)text{
    if(self.labelView){
        self.labelView.text = text;
    }
}

-(void)setSelected:(BOOL)selected{
    self.isSelected = selected;
    if(self.leftIconView){
        if(selected){
            self.leftIconView.image = [UIImage imageNamed:@"ic_radio_button_p.png"];
        }else{
            self.leftIconView.image = [UIImage imageNamed:@"ic_radio_button.png"];
        }
    }
}
@end
