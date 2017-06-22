//
//  ChatCell.m
//  Yoosee
//
//  Created by guojunyi on 14-5-29.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ChatCell.h"
#import "Utils.h"
#import "Message.h"
#import "Contact.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "Constants.h"
#import "ContactDAO.h"
@implementation ChatCell

-(void)dealloc{
    [self.headerView release];
    [self.timeLabel release];
    [self.nameLabel release];
    [self.messageView release];
    [self.message release];
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


#define HEADER_VIEW_HEIGHT 60
#define TIME_LABEL_HEIGHT 20
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.backgroundView.frame.size.width;
    //CGFloat height = self.backgroundView.frame.size.height;
    LoginResult *loginResult = [UDManager getLoginInfo];
    BOOL isLeft = NO;
    if([self.message.fromId isEqualToString:loginResult.contactId]){
        isLeft = YES;
    }else{
        isLeft = NO;
    }
    
    
    
    if(!self.timeLabel){
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, 5, width, TIME_LABEL_HEIGHT);
        
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
        label.font = XFontBold_14;
        label.backgroundColor = XBGAlpha;
        if(self.message.state==MESSAGE_STATE_SENDING){
            label.text = NSLocalizedString(@"message_sending", nil);
        }else if(self.message.state==MESSAGE_STATE_SEND_FAILURE){
            label.text = NSLocalizedString(@"message_send_failure", nil);
        }else{
            label.text = [Utils convertTimeByInterval:self.message.time];
        }
        
        
        [self.contentView addSubview:label];
        self.timeLabel = label;
        [label release];
    }else{
        self.timeLabel.frame = CGRectMake(0, 5, width, TIME_LABEL_HEIGHT);
        
        if(self.message.state==MESSAGE_STATE_SENDING){
            self.timeLabel.text = NSLocalizedString(@"message_sending", nil);
        }else if(self.message.state==MESSAGE_STATE_SEND_FAILURE){
            self.timeLabel.text = NSLocalizedString(@"message_send_failure", nil);
        }else{
            self.timeLabel.text = [Utils convertTimeByInterval:self.message.time];
        }
        
        
        [self.contentView addSubview:self.timeLabel];
        
    }
    
    if(!self.headerView){
        UIImageView *headerView = [[UIImageView alloc] init];
        
        if(isLeft){
            headerView.frame = CGRectMake(10, self.timeLabel.frame.origin.x+self.timeLabel.frame.size.height+20, HEADER_VIEW_HEIGHT*4/3, HEADER_VIEW_HEIGHT);
        }else{
            headerView.frame = CGRectMake(width-10-HEADER_VIEW_HEIGHT*4/3, self.timeLabel.frame.origin.x+self.timeLabel.frame.size.height+20, HEADER_VIEW_HEIGHT*4/3, HEADER_VIEW_HEIGHT);
        }
        NSString *filePath = [Utils getHeaderFilePathWithId:self.message.fromId];
        UIImage *headerViewImg = [UIImage imageWithContentsOfFile:filePath];
        if(headerViewImg==nil){
            headerViewImg = [UIImage imageNamed:@"ic_header.png"];
        }
        
        
        headerView.image = headerViewImg;
        [self.contentView addSubview:headerView];
        self.headerView = headerView;
        [headerView release];
    }else{
        if(isLeft){
            self.headerView.frame = CGRectMake(10, self.timeLabel.frame.origin.x+self.timeLabel.frame.size.height+20, HEADER_VIEW_HEIGHT*4/3, HEADER_VIEW_HEIGHT);
        }else{
            self.headerView.frame = CGRectMake(width-10-HEADER_VIEW_HEIGHT*4/3, self.timeLabel.frame.origin.x+self.timeLabel.frame.size.height+20, HEADER_VIEW_HEIGHT*4/3, HEADER_VIEW_HEIGHT);
        }
        
        NSString *filePath = [Utils getHeaderFilePathWithId:self.message.fromId];
        UIImage *headerViewImg = [UIImage imageWithContentsOfFile:filePath];
        if(headerViewImg==nil){
            headerViewImg = [UIImage imageNamed:@"ic_header.png"];
        }
        
        
        self.headerView.image = headerViewImg;
        [self.contentView addSubview:self.headerView];
    }
    
    ContactDAO *contactDAO = [[ContactDAO alloc] init];
    
    Contact *contact = [contactDAO isContact:self.message.fromId];
    [contactDAO release];
    
    CGFloat nameLabelHeight = [Utils getStringHeightWithString:NSLocalizedString(@"me", nil) font:XFontBold_14 maxWidth:self.headerView.frame.size.width];
    
    if(!self.nameLabel){
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y+self.headerView.frame.size.height+5, self.headerView.frame.size.width, nameLabelHeight);
        
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = XBlack;
        label.font = XFontBold_14;
        label.backgroundColor = XBGAlpha;
        
        
        if(isLeft){
            label.text = NSLocalizedString(@"me", nil);
        }else{
            if(contact!=nil){
                label.text = contact.contactName;
            }else{
                label.text = self.message.fromId;
            }
        }
        
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        [self.contentView addSubview:label];
        self.nameLabel = label;
        [label release];
    }else{
        self.nameLabel.frame = CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y+self.headerView.frame.size.height+5, self.headerView.frame.size.width, nameLabelHeight);
        
        if(isLeft){
            self.nameLabel.text = NSLocalizedString(@"me", nil);
        }else{
            if(contact!=nil){
                self.nameLabel.text = contact.contactName;
            }else{
                self.nameLabel.text = self.message.fromId;
            }
        }
        
        [self.contentView addSubview:self.nameLabel];
    }
    CGFloat messageViewWidth;
    CGFloat messageViewHeight;
    
    if(isLeft){
        messageViewWidth = [Utils getStringWidthWithString:self.message.message font:XFontBold_16 maxWidth:(width-(self.headerView.frame.origin.x+self.headerView.frame.size.width)-80)];
        messageViewHeight = [Utils getStringHeightWithString:self.message.message font:XFontBold_16 maxWidth:(width-(self.headerView.frame.origin.x+self.headerView.frame.size.width)-80)];
    }else{
        messageViewWidth = [Utils getStringWidthWithString:self.message.message font:XFontBold_16 maxWidth:(self.headerView.frame.origin.x-80)];
        messageViewHeight = [Utils getStringHeightWithString:self.message.message font:XFontBold_16 maxWidth:(self.headerView.frame.origin.x-80)];
    }
    
    
    
    
    if(!self.messageView){
        UIButton *messageView = [UIButton buttonWithType:UIButtonTypeCustom];
        if(isLeft){
            messageView.frame = CGRectMake(self.headerView.frame.origin.x+self.headerView.frame.size.width, self.headerView.frame.origin.y, messageViewWidth+60, messageViewHeight+30);
            
            UIImage *backImg = [UIImage imageNamed:@"bg_chat_left"];
            backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.3 topCapHeight:backImg.size.height*0.7];
            
            UIImage *backImg_p = [UIImage imageNamed:@"bg_chat_left_p"];
            backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.3 topCapHeight:backImg_p.size.height*0.7];
            
            [messageView setBackgroundImage:backImg forState:UIControlStateNormal];
            [messageView setBackgroundImage:backImg_p forState:UIControlStateHighlighted];
        }else{
            messageView.frame = CGRectMake(self.headerView.frame.origin.x-messageViewWidth-60, self.headerView.frame.origin.y, messageViewWidth+60, messageViewHeight+30);
            
            UIImage *backImg = [UIImage imageNamed:@"bg_chat_right"];
            backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.3 topCapHeight:backImg.size.height*0.7];
            
            UIImage *backImg_p = [UIImage imageNamed:@"bg_chat_right_p"];
            backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.3 topCapHeight:backImg_p.size.height*0.7];
            
            [messageView setBackgroundImage:backImg forState:UIControlStateNormal];
            [messageView setBackgroundImage:backImg_p forState:UIControlStateHighlighted];
        }
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 7, messageViewWidth, messageViewHeight)];
        
        if(isLeft){
            label.textAlignment = NSTextAlignmentLeft;
            label.frame = CGRectMake(30, 7, messageViewWidth, messageViewHeight);
            
        }else{
            label.textAlignment = NSTextAlignmentLeft;
            label.frame = CGRectMake(25, 7, messageViewWidth, messageViewHeight);
            
        }
        label.tag = 100;
        label.font = XFontBold_16;
        label.textColor = XBlack;
        label.backgroundColor = XBGAlpha;
        label.text = self.message.message;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        [messageView addSubview:label];
        [label release];
        [self.contentView addSubview:messageView];
        self.messageView = messageView;
    }else{
        if(isLeft){
            self.messageView.frame = CGRectMake(self.headerView.frame.origin.x+self.headerView.frame.size.width, self.headerView.frame.origin.y, messageViewWidth+60, messageViewHeight+30);
            
            UIImage *backImg = [UIImage imageNamed:@"bg_chat_left"];
            backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.3 topCapHeight:backImg.size.height*0.7];
            
            UIImage *backImg_p = [UIImage imageNamed:@"bg_chat_left_p"];
            backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.3 topCapHeight:backImg_p.size.height*0.7];
            
            [self.messageView setBackgroundImage:backImg forState:UIControlStateNormal];
            [self.messageView setBackgroundImage:backImg_p forState:UIControlStateHighlighted];
        }else{
            self.messageView.frame = CGRectMake(self.headerView.frame.origin.x-messageViewWidth-60, self.headerView.frame.origin.y, messageViewWidth+60, messageViewHeight+30);
            
            UIImage *backImg = [UIImage imageNamed:@"bg_chat_right"];
            backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.3 topCapHeight:backImg.size.height*0.7];
            
            UIImage *backImg_p = [UIImage imageNamed:@"bg_chat_right_p"];
            backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.3 topCapHeight:backImg_p.size.height*0.7];
            
            [self.messageView setBackgroundImage:backImg forState:UIControlStateNormal];
            [self.messageView setBackgroundImage:backImg_p forState:UIControlStateHighlighted];
            
        }
        
        UILabel *label = (UILabel *)[self.messageView viewWithTag:100];
        if(isLeft){
            label.textAlignment = NSTextAlignmentLeft;
            label.frame = CGRectMake(30, 7, messageViewWidth, messageViewHeight);
            
        }else{
            label.textAlignment = NSTextAlignmentLeft;
            label.frame = CGRectMake(25, 7, messageViewWidth, messageViewHeight);
            
        }
        label.text = self.message.message;
        DLog(@"%@",self.message.message);
        
        [self.contentView addSubview:self.messageView];
    }
}
@end
