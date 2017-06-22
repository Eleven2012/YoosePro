//
//  P2PEmailSettingCell.m
//  Yoosee
//
//  Created by guojunyi on 14-5-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "P2PEmailSettingCell.h"
#import "Constants.h"
@implementation P2PEmailSettingCell

-(void)dealloc{
    [self.leftLabelText release];
    [self.leftLabelView release];
    [self.rightIconView release];
    [self.rightIcon release];
    [self.rightLabelText release];
    [self.rightLabelView release];
    [self.leftIcon release];
    [self.leftIconView release];
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

#define LEFT_LABEL_WIDTH 150
#define PROGRESS_WIDTH_HEIGHT 32
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth = self.backgroundView.frame.size.width;
    CGFloat cellHeight = self.backgroundView.frame.size.height;
    
    if(!self.leftLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT)];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.leftLabelText;
        [self.contentView addSubview:textLabel];
        self.leftLabelView = textLabel;
        [textLabel release];
        [self.leftLabelView setHidden:self.isLeftLabelHidden];
        
    }else{
        self.leftLabelView.frame = CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT);
        self.leftLabelView.textAlignment = NSTextAlignmentLeft;
        self.leftLabelView.textColor = XBlack;
        self.leftLabelView.backgroundColor = XBGAlpha;
        [self.leftLabelView setFont:XFontBold_16];
        self.leftLabelView.text = self.leftLabelText;
        [self.contentView addSubview:self.leftLabelView];
        [self.leftLabelView setHidden:self.isLeftLabelHidden];
    }
    
    if(!self.leftIconView){
        UIImageView *leftIconView = [[UIImageView alloc] initWithFrame:CGRectMake(30,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)];
        leftIconView.contentMode = UIViewContentModeScaleAspectFit;
        leftIconView.image = [UIImage imageNamed:self.leftIcon];
        [self.contentView addSubview:leftIconView];
        self.leftIconView = leftIconView;
        [leftIconView release];
        [self.leftIconView setHidden:self.isLeftIconHidden];
    }else{
        self.leftIconView.frame = CGRectMake(30,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT);
        
        self.leftIconView.image = [UIImage imageNamed:self.leftIcon];
        
        [self.contentView addSubview:self.leftIconView];
        [self.leftIconView setHidden:self.isLeftIconHidden];
    }
    
    
    if(!self.rightIconView){
        UIImageView *rightIconView = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth-30-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)];
        rightIconView.contentMode = UIViewContentModeScaleAspectFit;
        rightIconView.image = [UIImage imageNamed:self.rightIcon];
        [self.contentView addSubview:rightIconView];
        self.rightIconView = rightIconView;
        [rightIconView release];
        [self.rightIconView setHidden:self.isRightIconHidden];
    }else{
        self.rightIconView.frame = CGRectMake(cellWidth-30-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT);
        
        self.rightIconView.image = [UIImage imageNamed:self.rightIcon];
        
        [self.contentView addSubview:self.rightIconView];
        [self.rightIconView setHidden:self.isRightIconHidden];
    }
    
    if(!self.rightLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30+LEFT_LABEL_WIDTH, 0, cellWidth-30*2-LEFT_LABEL_WIDTH-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT-5, BAR_BUTTON_HEIGHT)];
        textLabel.textAlignment = NSTextAlignmentRight;
        textLabel.textColor = [UIColor grayColor];
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_14];
        textLabel.text = self.rightLabelText;
        [self.contentView addSubview:textLabel];
        self.rightLabelView = textLabel;
        [textLabel release];
        [self.rightLabelView setHidden:self.isRightLabelHidden];
    }else{
        self.rightLabelView.frame = CGRectMake(30+LEFT_LABEL_WIDTH, 0, cellWidth-30*2-LEFT_LABEL_WIDTH-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT-5, BAR_BUTTON_HEIGHT);
        self.rightLabelView.textAlignment = NSTextAlignmentRight;
        self.rightLabelView.textColor = [UIColor grayColor];
        self.rightLabelView.backgroundColor = XBGAlpha;
        [self.rightLabelView setFont:XFontBold_14];
        self.rightLabelView.text = self.rightLabelText;
        [self.contentView addSubview:self.rightLabelView];
        [self.rightLabelView setHidden:self.isRightLabelHidden];
    }
    
    if(!self.isProgressViewHidden){
        if(!self.progressView){
            UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            progressView.frame = CGRectMake(cellWidth-30-PROGRESS_WIDTH_HEIGHT, (cellHeight-PROGRESS_WIDTH_HEIGHT)/2, PROGRESS_WIDTH_HEIGHT, PROGRESS_WIDTH_HEIGHT);
            [progressView setHidden:self.isProgressViewHidden];
            [self.contentView addSubview:progressView];
            [progressView startAnimating];
            self.progressView = progressView;
            [progressView release];
            [self.progressView setHidden:self.isProgressViewHidden];
        }else{
            self.progressView.frame = CGRectMake(cellWidth-30-PROGRESS_WIDTH_HEIGHT, (cellHeight-PROGRESS_WIDTH_HEIGHT)/2, PROGRESS_WIDTH_HEIGHT, PROGRESS_WIDTH_HEIGHT);
            [self.progressView setHidden:self.isProgressViewHidden];
            [self.contentView addSubview:self.progressView];
            [self.progressView startAnimating];
        }
        
    }else{
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
}

-(void)setProgressViewHidden:(BOOL)hidden{
    self.isProgressViewHidden = hidden;
    if(self.progressView){
        [self.progressView setHidden:hidden];
        
    }
}

-(void)setLeftLabelHidden:(BOOL)hidden{
    self.isLeftLabelHidden = hidden;
    if(self.leftLabelView){
        [self.leftLabelView setHidden:hidden];
    }
}
    
-(void)setRightLabelHidden:(BOOL)hidden{
    self.isRightLabelHidden = hidden;
    if(self.rightLabelView){
        [self.rightLabelView setHidden:hidden];
    }
}

-(void)setLeftIconHidden:(BOOL)hidden{
    self.isLeftIconHidden = hidden;
    if(self.leftIconView){
        [self.leftIconView setHidden:hidden];
    }
}
    
-(void)setRightIconHidden:(BOOL)hidden{
    self.isRightIconHidden = hidden;
    if(self.rightIconView){
        [self.rightIconView setHidden:hidden];
    }
}
@end
