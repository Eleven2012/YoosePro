//
//  TempContactCell.m
//  Yoosee
//
//  Created by guojunyi on 14-8-2.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "TempContactCell.h"
#import "Utils.h"
#import "Constants.h"
#import "Contact.h"
#import "P2PClient.h"
#import "FListManager.h"
#import "LocalDevice.h"
@implementation TempContactCell

-(void)dealloc{
    [self.headView release];
    [self.typeView release];
    [self.nameLabel release];
    [self.localDevice release];
    [self.defenceStateView release];
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

#define CONTACT_HEADER_VIEW_MARGIN 6
#define CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT 16
#define CONTACT_STATE_LABEL_WIDTH 50
#define MESSAHE_COUNT_VIEW_WIDTH_AND_HEIGHT 24
#define HEADER_ICON_VIEW_HEIGHT_WIDTH 50
#define DEFENCE_STATE_VIEW_WIDTH_HEIGHT 24
-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.backgroundView.frame.size.width;
    CGFloat height = self.backgroundView.frame.size.height;
    
    if(!self.headView){
        UIButton *headButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CONTACT_HEADER_VIEW_MARGIN, (height-CONTACT_HEADER_VIEW_MARGIN*2)*4/3, height-CONTACT_HEADER_VIEW_MARGIN*2)];
        
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (height-CONTACT_HEADER_VIEW_MARGIN*2)*4/3, height-CONTACT_HEADER_VIEW_MARGIN*2)];
        
        UIImage *headImg = [UIImage imageNamed:@"ic_header.png"];
        
        headImg = [headImg stretchableImageWithLeftCapWidth:headImg.size.width*0.5 topCapHeight:headImg.size.height*0.5];
        
        headImageView.image = headImg;
        
        headImageView.contentMode = UIViewContentModeScaleAspectFit;
        [headButton addSubview:headImageView];
        
        UIImageView *headIconView = [[UIImageView alloc] initWithFrame:CGRectMake((headButton.frame.size.width-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, (headButton.frame.size.height-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, HEADER_ICON_VIEW_HEIGHT_WIDTH, HEADER_ICON_VIEW_HEIGHT_WIDTH)];
        headIconView.image = [UIImage imageNamed:@"ic_header_play.png"];
        [headButton addSubview:headIconView];
        [headIconView setHidden:YES];
        [headIconView release];
        
        [self.contentView addSubview:headButton];
        self.headView = headButton;
        [headButton release];
        [headImageView release];
    }else{
        
        self.headView.frame = CGRectMake(10, CONTACT_HEADER_VIEW_MARGIN, (height-CONTACT_HEADER_VIEW_MARGIN*2)*4/3, height-CONTACT_HEADER_VIEW_MARGIN*2);

        UIImage *headImg = headImg = [UIImage imageNamed:@"ic_header.png"];
        
        
        UIImageView *headImageView = [[self.headView subviews] objectAtIndex:0];
        headImageView.image = headImg;
        headImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImageView *headIconView = [[self.headView subviews] objectAtIndex:1];
        [headIconView setHidden:YES];
        
        [self.contentView addSubview:self.headView];
        
    }

    
    if(!self.typeView){
        UIImageView *typeView = [[UIImageView alloc] initWithFrame:CGRectMake(self.headView.frame.origin.x+self.headView.frame.size.width+CONTACT_HEADER_VIEW_MARGIN, height/2+CONTACT_HEADER_VIEW_MARGIN, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT)];
        if(self.localDevice.contactType==CONTACT_TYPE_NPC){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_npc.png"];
            typeView.image = typeImg;
        }else if(self.localDevice.contactType==CONTACT_TYPE_IPC){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_ipc.png"];
            typeView.image = typeImg;
        }if(self.localDevice.contactType==CONTACT_TYPE_PHONE){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_phone.png"];
            typeView.image = typeImg;
        }if(self.localDevice.contactType==CONTACT_TYPE_UNKNOWN){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_unknown.png"];
            typeView.image = typeImg;
        }
        
        [self.contentView addSubview:typeView];
        self.typeView = typeView;
        
    }else{
        self.typeView.frame = CGRectMake(self.headView.frame.origin.x+self.headView.frame.size.width+CONTACT_HEADER_VIEW_MARGIN, height/2+CONTACT_HEADER_VIEW_MARGIN, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT);
        
        if(self.localDevice.contactType==CONTACT_TYPE_NPC){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_npc.png"];
            self.typeView.image = typeImg;
        }else if(self.localDevice.contactType==CONTACT_TYPE_IPC){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_ipc.png"];
            self.typeView.image = typeImg;
        }if(self.localDevice.contactType==CONTACT_TYPE_PHONE){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_phone.png"];
            self.typeView.image = typeImg;
        }if(self.localDevice.contactType==CONTACT_TYPE_UNKNOWN){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_unknown.png"];
            self.typeView.image = typeImg;
        }
        
        [self.contentView addSubview:self.typeView];
    }
    
    
    if(!self.nameLabel){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+(height-CONTACT_HEADER_VIEW_MARGIN*2)*4/3+10,CONTACT_HEADER_VIEW_MARGIN,width-(height-CONTACT_HEADER_VIEW_MARGIN*2)*4/3-10*2-CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT-10*2,height/2-CONTACT_HEADER_VIEW_MARGIN)];
        
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_18];
        
        textLabel.text = self.localDevice.contactId;
        
        [self.contentView addSubview:textLabel];
        self.nameLabel = textLabel;
        [textLabel release];
    }else{
        self.nameLabel.frame = CGRectMake(10+(height-CONTACT_HEADER_VIEW_MARGIN*2)*4/3+10,CONTACT_HEADER_VIEW_MARGIN,width-(height-CONTACT_HEADER_VIEW_MARGIN*2)*4/3-10*2-CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT-10*2,height/2-CONTACT_HEADER_VIEW_MARGIN);
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = XBlack;
        self.nameLabel.backgroundColor = XBGAlpha;
        [self.nameLabel setFont:XFontBold_18];
        
        self.nameLabel.text = self.localDevice.contactId;
        
        [self.contentView addSubview:self.nameLabel];
    }
    
    
    if(!self.defenceStateView){
        UIButton *defenceStateView = [UIButton buttonWithType:UIButtonTypeCustom];
        defenceStateView.frame = CGRectMake(width-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20, (height-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20)/2, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, defenceStateView.frame.size.width-20, defenceStateView.frame.size.height-20)];
        
        imageView.image = [UIImage imageNamed:@"ic_add_alarm_id.png"];
        
        
        [defenceStateView addSubview:imageView];
        [imageView release];
        self.defenceStateView = defenceStateView;
        [self.contentView addSubview:self.defenceStateView];
        
        
    }else{
        self.defenceStateView.frame = CGRectMake(width-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20, (height-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20)/2, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20);
        UIImageView *imageView = [[self.defenceStateView subviews] objectAtIndex:0];
        imageView.frame = CGRectMake(10, 10, self.defenceStateView.frame.size.width-20, self.defenceStateView.frame.size.height-20);
        imageView.image = [UIImage imageNamed:@"ic_add_alarm_id.png"];
        
        [self.contentView addSubview:self.defenceStateView];
        
    }
    
}

@end
