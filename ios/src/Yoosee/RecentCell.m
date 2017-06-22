//
//  RecentCell.m
//  Yoosee
//
//  Created by guojunyi on 14-4-2.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "RecentCell.h"
#import "Constants.h"
#import "Utils.h"
@implementation RecentCell

-(void)dealloc{
    [self.leftIcon release];
    [self.contactId release];
    [self.callState release];
    [self.time release];
    
    [self.leftIconView release];
    [self.contactIdLabel release];
    [self.callStateView release];
    [self.timeLabel release];
    
    [self.contactIdLabel_p release];
    [self.callStateView_p release];
    [self.timeLabel_p release];
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

#define LEFT_IMAGE_MARGIN 6

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.backgroundView.frame.size.width;
    CGFloat height = self.backgroundView.frame.size.height;
   
    
    if(self.leftIcon&&self.leftIcon.length>0){
        if(!self.leftIconView){
            UIImageView *left_icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, LEFT_IMAGE_MARGIN, (height-LEFT_IMAGE_MARGIN*2)*4/3, height-LEFT_IMAGE_MARGIN*2)];
            
            
            NSString *filePath = [Utils getHeaderFilePathWithId:self.contactId];
            UIImage *leftIconImg = [UIImage imageWithContentsOfFile:filePath];
            if(leftIconImg==nil){
                leftIconImg = [UIImage imageNamed:@"ic_header.png"];
            }
            
            left_icon.image = leftIconImg;
            left_icon.contentMode = UIViewContentModeScaleAspectFit;
            [self.contentView addSubview:left_icon];
            self.leftIconView = left_icon;
            [left_icon release];
        }else{
            self.leftIconView.frame = CGRectMake(10, LEFT_IMAGE_MARGIN, (height-LEFT_IMAGE_MARGIN*2)*4/3, height-LEFT_IMAGE_MARGIN*2);
            
            NSString *filePath = [Utils getHeaderFilePathWithId:self.contactId];
            UIImage *leftIconImg = [UIImage imageWithContentsOfFile:filePath];
            if(leftIconImg==nil){
                leftIconImg = [UIImage imageNamed:@"ic_header.png"];
            }
            
            self.leftIconView.image = leftIconImg;
            self.leftIconView.contentMode = UIViewContentModeScaleAspectFit;
            [self.contentView addSubview:self.leftIconView];
          
        }
        
    }
    
    if(self.contactId&&self.contactId.length>0){
        if(!self.contactIdLabel){
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+(height-LEFT_IMAGE_MARGIN*2)*4/3+5, LEFT_IMAGE_MARGIN, width-(10+height-LEFT_IMAGE_MARGIN*2+5)-(10+(height-LEFT_IMAGE_MARGIN*2)/2+5), (height-LEFT_IMAGE_MARGIN*2)/2)];
            
            textLabel.textAlignment = NSTextAlignmentLeft;
            textLabel.textColor = XBlack;
            textLabel.backgroundColor = XBGAlpha;
            [textLabel setFont:XFontBold_16];
            textLabel.text = self.contactId;
            [self.backgroundView addSubview:textLabel];
            self.contactIdLabel = textLabel;
            [textLabel release];
        }else{
            self.contactIdLabel.frame = CGRectMake(10+(height-LEFT_IMAGE_MARGIN*2)*4/3+5, LEFT_IMAGE_MARGIN, width-(10+height-LEFT_IMAGE_MARGIN*2+5)-(10+(height-LEFT_IMAGE_MARGIN*2)/2+5), (height-LEFT_IMAGE_MARGIN*2)/2);
            self.contactIdLabel.textAlignment = NSTextAlignmentLeft;
            self.contactIdLabel.textColor = XBlack;
            self.contactIdLabel.backgroundColor = XBGAlpha;
            [self.contactIdLabel setFont:XFontBold_16];
            self.contactIdLabel.text = self.contactId;
            [self.backgroundView addSubview:self.contactIdLabel];
        }
        
        if(!self.contactIdLabel_p){
            UILabel *textLabel_p = [[UILabel alloc] initWithFrame:CGRectMake(10+(height-LEFT_IMAGE_MARGIN*2)*4/3+5, LEFT_IMAGE_MARGIN, width-(10+height-LEFT_IMAGE_MARGIN*2+5)-(10+(height-LEFT_IMAGE_MARGIN*2)/2+5), (height-LEFT_IMAGE_MARGIN*2)/2)];
            textLabel_p.textAlignment = NSTextAlignmentLeft;
            textLabel_p.textColor = XBlack;
            textLabel_p.backgroundColor = XBGAlpha;
            [textLabel_p setFont:XFontBold_16];
            textLabel_p.text = self.contactId;
            [self.selectedBackgroundView addSubview:textLabel_p];
            self.contactIdLabel_p = textLabel_p;
            [textLabel_p release];
        }else{
            self.contactIdLabel_p.frame = CGRectMake(10+(height-LEFT_IMAGE_MARGIN*2)*4/3+5, LEFT_IMAGE_MARGIN, width-(10+height-LEFT_IMAGE_MARGIN*2+5)-(10+(height-LEFT_IMAGE_MARGIN*2)/2+5), (height-LEFT_IMAGE_MARGIN*2)/2);
            self.contactIdLabel_p.textAlignment = NSTextAlignmentLeft;
            self.contactIdLabel_p.textColor = XBlack;
            self.contactIdLabel_p.backgroundColor = XBGAlpha;
            [self.contactIdLabel_p setFont:XFontBold_16];
            self.contactIdLabel_p.text = self.contactId;
            [self.selectedBackgroundView addSubview:self.contactIdLabel_p];
        }
    }
    
    if(self.callState&&self.callState.length>0){
        if(!self.callStateView){
            UIImageView *callStateView = [[UIImageView alloc] initWithFrame:CGRectMake(width-10-(height-LEFT_IMAGE_MARGIN*2)/2, LEFT_IMAGE_MARGIN, (height-LEFT_IMAGE_MARGIN*2)/2, (height-LEFT_IMAGE_MARGIN*2)/2)];
            
            UIImage *callStateImg = [UIImage imageNamed:self.callState];
            callStateView.image = callStateImg;
            callStateView.contentMode = UIViewContentModeScaleAspectFit;
            [self.backgroundView addSubview:callStateView];
            self.callStateView = callStateView;
            [callStateView release];
        }else{
            self.callStateView.frame = CGRectMake(width-10-(height-LEFT_IMAGE_MARGIN*2)/2, LEFT_IMAGE_MARGIN, (height-LEFT_IMAGE_MARGIN*2)/2, (height-LEFT_IMAGE_MARGIN*2)/2);
            UIImage *callStateImg = [UIImage imageNamed:self.callState];
            self.callStateView.image = callStateImg;
            self.callStateView.contentMode = UIViewContentModeScaleAspectFit;
            [self.backgroundView addSubview:self.callStateView];
        }
        
        if(!self.callStateView_p){
            UIImageView *callStateView_p = [[UIImageView alloc] initWithFrame:CGRectMake(width-10-(height-LEFT_IMAGE_MARGIN*2)/2, LEFT_IMAGE_MARGIN, (height-LEFT_IMAGE_MARGIN*2)/2, (height-LEFT_IMAGE_MARGIN*2)/2)];
            
            UIImage *callStateImg_p = [UIImage imageNamed:self.callState];
            callStateView_p.image = callStateImg_p;
            callStateView_p.contentMode = UIViewContentModeScaleAspectFit;
            [self.selectedBackgroundView addSubview:callStateView_p];
            self.callStateView_p = callStateView_p;
            [callStateView_p release];
        }else{
            self.callStateView_p.frame = CGRectMake(width-10-(height-LEFT_IMAGE_MARGIN*2)/2, LEFT_IMAGE_MARGIN, (height-LEFT_IMAGE_MARGIN*2)/2, (height-LEFT_IMAGE_MARGIN*2)/2);
            UIImage *callStateImg_p = [UIImage imageNamed:self.callState];
            self.callStateView_p.image = callStateImg_p;
            self.callStateView_p.contentMode = UIViewContentModeScaleAspectFit;
            [self.selectedBackgroundView addSubview:self.callStateView_p];
        }
    }
    
    if(self.time&&self.time.length>0){
        if(!self.timeLabel){
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+height-LEFT_IMAGE_MARGIN*2+5, LEFT_IMAGE_MARGIN+(height-LEFT_IMAGE_MARGIN*2)/2, width-(10+height-LEFT_IMAGE_MARGIN*2+5)-(10), (height-LEFT_IMAGE_MARGIN*2)/2)];
            
            textLabel.textAlignment = NSTextAlignmentRight;
            textLabel.textColor = XBlue;
            textLabel.backgroundColor = XBGAlpha;
            [textLabel setFont:XFontBold_16];
            textLabel.text = self.time;
            [self.backgroundView addSubview:textLabel];
            self.timeLabel = textLabel;
            [textLabel release];
        }else{
            self.timeLabel.frame = CGRectMake(10+height-LEFT_IMAGE_MARGIN*2+5, LEFT_IMAGE_MARGIN+(height-LEFT_IMAGE_MARGIN*2)/2, width-(10+height-LEFT_IMAGE_MARGIN*2+5)-(10), (height-LEFT_IMAGE_MARGIN*2)/2);
            self.timeLabel.textAlignment = NSTextAlignmentRight;
            self.timeLabel.textColor = XBlue;
            self.timeLabel.backgroundColor = XBGAlpha;
            [self.timeLabel setFont:XFontBold_16];
            self.timeLabel.text = self.time;
            [self.backgroundView addSubview:self.timeLabel];
        }
        
        if(!self.timeLabel_p){
            UILabel *textLabel_p = [[UILabel alloc] initWithFrame:CGRectMake(10+height-LEFT_IMAGE_MARGIN*2+5, LEFT_IMAGE_MARGIN+(height-LEFT_IMAGE_MARGIN*2)/2, width-(10+height-LEFT_IMAGE_MARGIN*2+5)-(10), (height-LEFT_IMAGE_MARGIN*2)/2)];
            
            textLabel_p.textAlignment = NSTextAlignmentRight;
            textLabel_p.textColor = XBlue;
            textLabel_p.backgroundColor = XBGAlpha;
            [textLabel_p setFont:XFontBold_16];
            textLabel_p.text = self.time;
            [self.selectedBackgroundView addSubview:textLabel_p];
            self.timeLabel_p = textLabel_p;
            [textLabel_p release];
        }else{
            self.timeLabel_p.frame = CGRectMake(10+height-LEFT_IMAGE_MARGIN*2+5, LEFT_IMAGE_MARGIN+(height-LEFT_IMAGE_MARGIN*2)/2, width-(10+height-LEFT_IMAGE_MARGIN*2+5)-(10), (height-LEFT_IMAGE_MARGIN*2)/2);
            self.timeLabel_p.textAlignment = NSTextAlignmentRight;
            self.timeLabel_p.textColor = XBlue;
            self.timeLabel_p.backgroundColor = XBGAlpha;
            [self.timeLabel_p setFont:XFontBold_16];
            self.timeLabel_p.text = self.time;
            [self.selectedBackgroundView addSubview:self.timeLabel_p];
        }
    }
}


@end
