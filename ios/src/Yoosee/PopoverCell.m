//
//  PopoverCell.m
//  Yoosee
//
//  Created by gwelltime on 15-3-10.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "PopoverCell.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation PopoverCell

-(void)dealloc{
    [self.leftIcon release];
    [self.rightIcon release];
    [self.labelText release];
    [self.leftIconView release];
    [self.leftIconView_p release];
    [self.textLabelView release];
    [self.textLabelView_p release];
    [self.rightIconView release];
    [self.rightIconView_p release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect rect1 = self.backgroundView.frame;
    rect1.origin.x = -20;
    rect1.size.width = 240;
    self.backgroundView.frame = rect1;
    CGRect rect2 = self.selectedBackgroundView.frame;
    rect2.origin.x = -20;
    rect2.size.width = 240;
    self.selectedBackgroundView.frame = rect2;
    
    if(self.leftIcon&&self.leftIcon.length>0){
        if(!self.leftIconView){
            UIImageView *left_icon = [[UIImageView alloc] initWithFrame:CGRectMake(30, (BAR_BUTTON_HEIGHT-BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT)/2, BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT)];
            
            UIImage *leftIconImg = [UIImage imageNamed:self.leftIcon];
            left_icon.image = leftIconImg;
            left_icon.contentMode = UIViewContentModeScaleAspectFit;
            [self.backgroundView addSubview:left_icon];
            self.leftIconView = left_icon;
            [left_icon release];
        }else{
            self.leftIconView.frame = CGRectMake(30, (BAR_BUTTON_HEIGHT-BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT)/2, BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT);
            UIImage *leftIconImg = [UIImage imageNamed:self.leftIcon];
            self.leftIconView.image = leftIconImg;
            self.leftIconView.contentMode = UIViewContentModeScaleAspectFit;
            [self.backgroundView addSubview:self.leftIconView];
        }
        
        if(!self.leftIconView_p){
            
            UIImageView *left_icon_p = [[UIImageView alloc] initWithFrame:CGRectMake(30, (BAR_BUTTON_HEIGHT-BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT)/2, BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT)];
            UIImage *leftIconImg = [UIImage imageNamed:self.leftIcon];
            
            left_icon_p.image = leftIconImg;
            
            left_icon_p.contentMode = UIViewContentModeScaleAspectFit;
            [self.selectedBackgroundView addSubview:left_icon_p];
            self.leftIconView_p = left_icon_p;
            [left_icon_p release];
        }else{
            self.leftIconView_p.frame = CGRectMake(30, (BAR_BUTTON_HEIGHT-BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT)/2, BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT);
            UIImage *leftIconImg = [UIImage imageNamed:self.leftIcon];
            
            self.leftIconView_p.image = leftIconImg;
            
            self.leftIconView_p.contentMode = UIViewContentModeScaleAspectFit;
            [self.selectedBackgroundView addSubview:self.leftIconView_p];
        }
    }
    CGFloat cellWidth = self.backgroundView.frame.size.width;
    
    
    if(self.rightIcon&&self.rightIcon.length>0){
        if(!self.rightIconView){
            UIImageView *right_icon = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth-30-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)];
            right_icon.contentMode = UIViewContentModeScaleAspectFit;
            UIImage *rightIconImg = [UIImage imageNamed:self.rightIcon];
            right_icon.image = rightIconImg;
            [self.backgroundView addSubview:right_icon];
            self.rightIconView = right_icon;
            [right_icon release];
        }else{
            self.rightIconView.frame = CGRectMake(cellWidth-30-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT);
            self.rightIconView.contentMode = UIViewContentModeScaleAspectFit;
            UIImage *rightIconImg = [UIImage imageNamed:self.rightIcon];
            self.rightIconView.image = rightIconImg;
            [self.backgroundView addSubview:self.rightIconView];
        }
        
        if(!self.rightIconView_p){
            UIImageView *right_icon_p = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth-30-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)];
            
            right_icon_p.contentMode = UIViewContentModeScaleAspectFit;
            UIImage *rightIconImg = [UIImage imageNamed:self.rightIcon];
            right_icon_p.image = rightIconImg;
            [self.selectedBackgroundView addSubview:right_icon_p];
            self.rightIconView_p = right_icon_p;
            [right_icon_p release];
        }else{
            self.rightIconView_p.frame = CGRectMake(cellWidth-30-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT);
            self.rightIconView_p.contentMode = UIViewContentModeScaleAspectFit;
            UIImage *rightIconImg = [UIImage imageNamed:self.rightIcon];
            self.rightIconView_p.image = rightIconImg;
            [self.selectedBackgroundView addSubview:self.rightIconView_p];
        }
        
    }
    
    if(self.labelText&&self.labelText.length>0){
        if(!self.textLabelView){
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30+BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT+10, 0, cellWidth-(30+10)*2-BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_HEIGHT)];
            textLabel.textAlignment = NSTextAlignmentLeft;
            textLabel.textColor = XBlack;
            textLabel.backgroundColor = XBGAlpha;
            [textLabel setFont:XFontBold_16];
            textLabel.text = self.labelText;
            [self.backgroundView addSubview:textLabel];
            self.textLabelView = textLabel;
            [textLabel release];
        }else{
            self.textLabelView.frame = CGRectMake(30+BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT+10, 0, cellWidth-(30+10)*2-BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_HEIGHT);
            self.textLabelView.textAlignment = NSTextAlignmentLeft;
            self.textLabelView.textColor = XBlack;
            self.textLabelView.backgroundColor = XBGAlpha;
            [self.textLabelView setFont:XFontBold_16];
            self.textLabelView.text = self.labelText;
            [self.backgroundView addSubview:self.textLabelView];
        }
        
        if(!self.textLabelView_p){
            UILabel *textLabel_p = [[UILabel alloc] initWithFrame:CGRectMake(30+BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT+10, 0, cellWidth-(30+10)*2-BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_HEIGHT)];
            textLabel_p.textAlignment = NSTextAlignmentLeft;
            textLabel_p.textColor = XBlack;
            textLabel_p.backgroundColor = XBGAlpha;
            [textLabel_p setFont:XFontBold_16];
            textLabel_p.text = self.labelText;
            [self.selectedBackgroundView addSubview:textLabel_p];
            self.textLabelView_p = textLabel_p;
            [textLabel_p release];
        }else{
            self.textLabelView_p.frame = CGRectMake(30+BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT+10, 0, cellWidth-(30+10)*2-BAR_BUTTON_LEFT_ICON_WIDTH_AND_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_HEIGHT);
            self.textLabelView_p.textAlignment = NSTextAlignmentLeft;
            self.textLabelView_p.textColor = XBlack;
            self.textLabelView_p.backgroundColor = XBGAlpha;
            [self.textLabelView_p setFont:XFontBold_16];
            self.textLabelView_p.text = self.labelText;
            [self.selectedBackgroundView addSubview:self.textLabelView_p];
        }
        
        
        
    }
    
}

@end
