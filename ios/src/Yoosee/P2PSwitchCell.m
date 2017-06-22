//
//  P2PSwitchCell.m
//  Yoosee
//
//  Created by guojunyi on 14-5-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "P2PSwitchCell.h"
#import "Constants.h"
@implementation P2PSwitchCell

-(void)dealloc{
    [self.leftLabelText release];
    [self.leftLabelView release];
    [self.switchView release];
    [self.progressView release];
    [self.indexPath release];
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

#define LEFT_LABEL_WIDTH 120
#define PROGRESS_WIDTH_HEIGHT 32

#define SWITCH_WIDTH ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 ? 72:49)
#define SWITCH_HEIGHT 31
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

    }else{
        self.leftLabelView.frame = CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT);
        self.leftLabelView.textAlignment = NSTextAlignmentLeft;
        self.leftLabelView.textColor = XBlack;
        self.leftLabelView.backgroundColor = XBGAlpha;
        [self.leftLabelView setFont:XFontBold_16];
        self.leftLabelView.text = self.leftLabelText;
        [self.contentView addSubview:self.leftLabelView];

    }
    
    
    if(!self.switchView){
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(cellWidth-30-SWITCH_WIDTH, (cellHeight-SWITCH_HEIGHT)/2, SWITCH_WIDTH, SWITCH_HEIGHT)];
        
        
       
        
        self.switchView = switchView;
        self.switchView.on = self.on;
        [self.switchView addTarget:self action:@selector(onSwitchValueChange:) forControlEvents:UIControlEventValueChanged];
        [switchView release];
        [self.contentView addSubview:self.switchView];
        [self.switchView setHidden:self.isSwitchViewHidden];
        
    }else{
        
        self.switchView.frame = CGRectMake(cellWidth-30-SWITCH_WIDTH, (cellHeight-SWITCH_HEIGHT)/2, SWITCH_WIDTH, SWITCH_HEIGHT);
        [self.contentView addSubview:self.switchView];
        [self.switchView setHidden:self.isSwitchViewHidden];
        self.switchView.on = self.on;
        [self.switchView addTarget:self action:@selector(onSwitchValueChange:) forControlEvents:UIControlEventValueChanged];
    }
   
    if(!self.isProgressViewHidden){
        if(!self.progressView){
            UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            progressView.frame = CGRectMake(cellWidth-30-PROGRESS_WIDTH_HEIGHT, (cellHeight-PROGRESS_WIDTH_HEIGHT)/2, PROGRESS_WIDTH_HEIGHT, PROGRESS_WIDTH_HEIGHT);
            [self.contentView addSubview:progressView];
            [progressView startAnimating];
            self.progressView = progressView;
            [progressView release];
            [self.progressView setHidden:self.isProgressViewHidden];
        }else{
            self.progressView.frame = CGRectMake(cellWidth-30-PROGRESS_WIDTH_HEIGHT, (cellHeight-PROGRESS_WIDTH_HEIGHT)/2, PROGRESS_WIDTH_HEIGHT, PROGRESS_WIDTH_HEIGHT);
            [self.contentView addSubview:self.progressView];
            [self.progressView startAnimating];
            [self.progressView setHidden:self.isProgressViewHidden];
        }
    }
    
}

-(void)setProgressViewHidden:(BOOL)hidden{
    self.isProgressViewHidden = hidden;
    if(self.progressView){
        [self.progressView setHidden:hidden];
    }
}

-(void)setSwitchViewHidden:(BOOL)hidden{
    self.isSwitchViewHidden = hidden;
    if(self.switchView){
        [self.switchView setHidden:hidden];
    }
}

-(void)onSwitchValueChange:(UISwitch*)sender{
    if(self.delegate){
        [self.delegate onSwitchValueChange:sender indexPath:self.indexPath];
    }
}



@end
