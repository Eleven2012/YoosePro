//
//  ContactCell.m
//  Yoosee
//
//  Created by guojunyi on 14-4-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ContactCell.h"
#import "Utils.h"
#import "Constants.h"
#import "Contact.h"
#import "P2PClient.h"
#import "FListManager.h"
@implementation ContactCell

-(void)dealloc{
    [self.headView release];
    [self.typeView release];
    [self.nameLabel release];
    [self.stateLabel release];
    [self.weakPwdImageView release];
    [self.contact release];
    [self.messageCountView release];
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
        
        NSString *filePath = [Utils getHeaderFilePathWithId:self.contact.contactId];
        
        UIImage *headImg = [UIImage imageWithContentsOfFile:filePath];
        if(headImg==nil){
            
            headImg = [UIImage imageNamed:@"ic_header.png"];
        }
        
        headImg = [headImg stretchableImageWithLeftCapWidth:headImg.size.width*0.5 topCapHeight:headImg.size.height*0.5];
        
        headImageView.image = headImg;
        
        headImageView.contentMode = UIViewContentModeScaleAspectFit;
        [headButton addSubview:headImageView];
        
        UIImageView *headIconView = [[UIImageView alloc] initWithFrame:CGRectMake((headButton.frame.size.width-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, (headButton.frame.size.height-HEADER_ICON_VIEW_HEIGHT_WIDTH)/2, HEADER_ICON_VIEW_HEIGHT_WIDTH, HEADER_ICON_VIEW_HEIGHT_WIDTH)];
        headIconView.image = [UIImage imageNamed:@"ic_header_play.png"];
        [headButton addSubview:headIconView];
        if(self.contact.contactType==CONTACT_TYPE_UNKNOWN||self.contact.contactType==CONTACT_TYPE_PHONE){
            [headIconView setHidden:YES];
        }else{
            [headIconView setHidden:NO];
        }
        [headIconView release];
        
        [self.contentView addSubview:headButton];
        self.headView = headButton;
        [headButton release];
        [headImageView release];
    }else{
        
        self.headView.frame = CGRectMake(10, CONTACT_HEADER_VIEW_MARGIN, (height-CONTACT_HEADER_VIEW_MARGIN*2)*4/3, height-CONTACT_HEADER_VIEW_MARGIN*2);
        
        NSString *filePath = [Utils getHeaderFilePathWithId:self.contact.contactId];
        UIImage *headImg = [UIImage imageWithContentsOfFile:filePath];
        if(headImg==nil){
            headImg = [UIImage imageNamed:@"ic_header.png"];
        }
        
        UIImageView *headImageView = [[self.headView subviews] objectAtIndex:0];
        headImageView.image = headImg;
        headImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImageView *headIconView = [[self.headView subviews] objectAtIndex:1];
        if(self.contact.contactType==CONTACT_TYPE_UNKNOWN||self.contact.contactType==CONTACT_TYPE_PHONE){
            [headIconView setHidden:YES];
        }else{
            [headIconView setHidden:NO];
        }
        
        [self.contentView addSubview:self.headView];
        
    }
    
    [self.headView addTarget:self action:@selector(onHeadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if(!self.typeView){
        UIImageView *typeView = [[UIImageView alloc] initWithFrame:CGRectMake(self.headView.frame.origin.x+self.headView.frame.size.width+CONTACT_HEADER_VIEW_MARGIN, height/2+CONTACT_HEADER_VIEW_MARGIN, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT)];
        if(self.contact.contactType==CONTACT_TYPE_NPC){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_npc.png"];
            typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_IPC){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_ipc.png"];
            typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_PHONE){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_phone.png"];
            typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_DOORBELL){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_doorbell.png"];
            typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_UNKNOWN){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_unknown.png"];
            typeView.image = typeImg;
        }
        
        [self.contentView addSubview:typeView];
        self.typeView = typeView;

    }else{
        self.typeView.frame = CGRectMake(self.headView.frame.origin.x+self.headView.frame.size.width+CONTACT_HEADER_VIEW_MARGIN, height/2+CONTACT_HEADER_VIEW_MARGIN, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT);
       
        if(self.contact.contactType==CONTACT_TYPE_NPC){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_npc.png"];
            self.typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_IPC){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_ipc.png"];
            self.typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_PHONE){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_phone.png"];
            self.typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_DOORBELL){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_doorbell.png"];
            self.typeView.image = typeImg;
        }else if(self.contact.contactType==CONTACT_TYPE_UNKNOWN){
            UIImage *typeImg = [UIImage imageNamed:@"ic_contact_type_unknown.png"];
            self.typeView.image = typeImg;
        }
        
        [self.contentView addSubview:self.typeView];
    }
    
    if(!self.stateLabel){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.typeView.frame.origin.x+self.typeView.frame.size.width+5,self.typeView.frame.origin.y,50.0,20)];
        
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_14];
        if (self.contact.isGettingOnLineState) {//isGettingOnLineState
            textLabel.text = @"";
        }else{
            if(self.contact.onLineState==STATE_ONLINE){
                
                textLabel.textColor = XBlue;
                textLabel.text = NSLocalizedString(@"online", nil);
            }else{
                textLabel.textColor = XBlack;
                textLabel.text = NSLocalizedString(@"offline", nil);
            }
        }
        
        [self.contentView addSubview:textLabel];
        self.stateLabel = textLabel;
        [textLabel release];
    }else{
        self.stateLabel.frame = CGRectMake(self.typeView.frame.origin.x+self.typeView.frame.size.width+5,self.typeView.frame.origin.y,50.0,20);
        self.stateLabel.textAlignment = NSTextAlignmentLeft;
        self.stateLabel.backgroundColor = XBGAlpha;
        [self.stateLabel setFont:XFontBold_14];
        
        if (self.contact.isGettingOnLineState) {//isGettingOnLineState
            self.stateLabel.text = @"";
        }else{
            if(self.contact.onLineState==STATE_ONLINE){
                
                self.stateLabel.textColor = XBlue;
                self.stateLabel.text = NSLocalizedString(@"online", nil);
            }else{
                self.stateLabel.textColor = XBlack;
                self.stateLabel.text = NSLocalizedString(@"offline", nil);
            }
        }
        
        [self.contentView addSubview:self.stateLabel];
    }
    
    //弱密码的图标提示
    if(!self.weakPwdImageView){
        UIImageView *weakPwdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.stateLabel.frame.origin.x+self.stateLabel.frame.size.width, height/2+CONTACT_HEADER_VIEW_MARGIN,CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT, CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT)];
        weakPwdImageView.image = [UIImage imageNamed:@"ic_contact_weak_pwd.png"];
        [self.contentView addSubview:weakPwdImageView];
        self.weakPwdImageView = weakPwdImageView;
    }
    if(self.contact.defenceState == DEFENCE_STATE_ON || self.contact.defenceState == DEFENCE_STATE_OFF){
        //此设备的密码过于简单
        int pwdStrength = [self pwdStrengthWithPwd:self.contact.contactPassword];
        if (pwdStrength == 0) {//弱（红）
            [self.weakPwdImageView setHidden:NO];
            
        }else{
            [self.weakPwdImageView setHidden:YES];
        }
        
    }else{
        [self.weakPwdImageView setHidden:YES];
    }
    
    
    if(!self.nameLabel){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+(height-CONTACT_HEADER_VIEW_MARGIN*2)*4/3+10,CONTACT_HEADER_VIEW_MARGIN,width-(height-CONTACT_HEADER_VIEW_MARGIN*2)*4/3-10*2-CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT-10*2,height/2-CONTACT_HEADER_VIEW_MARGIN)];
        
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_18];
        
        textLabel.text = self.contact.contactName;
        
        [self.contentView addSubview:textLabel];
        self.nameLabel = textLabel;
        [textLabel release];
    }else{
        self.nameLabel.frame = CGRectMake(10+(height-CONTACT_HEADER_VIEW_MARGIN*2)*4/3+10,CONTACT_HEADER_VIEW_MARGIN,width-(height-CONTACT_HEADER_VIEW_MARGIN*2)*4/3-10*2-CONTACT_TYPE_ICON_WIDTH_AND_HEIGHT-10*2,height/2-CONTACT_HEADER_VIEW_MARGIN);
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = XBlack;
        self.nameLabel.backgroundColor = XBGAlpha;
        [self.nameLabel setFont:XFontBold_18];
        
        self.nameLabel.text = self.contact.contactName;
        
        [self.contentView addSubview:self.nameLabel];
    }
    
    if(!self.messageCountView){
        UIImageView *messageCountView = [[UIImageView alloc] initWithFrame:CGRectMake(self.headView.frame.origin.x+self.headView.frame.size.width, self.headView.frame.origin.y+3, MESSAHE_COUNT_VIEW_WIDTH_AND_HEIGHT, MESSAHE_COUNT_VIEW_WIDTH_AND_HEIGHT)];
        messageCountView.image = [UIImage imageNamed:@"bg_message_count.png"];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, messageCountView.frame.size.width, messageCountView.frame.size.height-5)];
        if(self.contact.messageCount>10){
            label.text = @"10+";
        }else{
           label.text = [NSString stringWithFormat:@"%i",self.contact.messageCount];
        }
        
        label.textAlignment = NSTextAlignmentCenter;
        label.font = XFontBold_12;
        label.backgroundColor = XBGAlpha;
        label.textColor = XWhite;
        [messageCountView addSubview:label];
        [label release];
        
        self.messageCountView = messageCountView;
        [self.contentView addSubview:messageCountView];
        [messageCountView release];
        
        if(self.contact.messageCount>0){
            [self.messageCountView setHidden:NO];
        }else{
            [self.messageCountView setHidden:YES];
        }
    }else{
        self.messageCountView.frame = CGRectMake(self.headView.frame.origin.x+self.headView.frame.size.width, self.headView.frame.origin.y+3, MESSAHE_COUNT_VIEW_WIDTH_AND_HEIGHT, MESSAHE_COUNT_VIEW_WIDTH_AND_HEIGHT);
        
        UILabel *label = [self.messageCountView.subviews objectAtIndex:0];
        label.frame = CGRectMake(0, 0, self.messageCountView.frame.size.width, self.messageCountView.frame.size.height-5);
        if(self.contact.messageCount>10){
            label.text = @"10+";
        }else{
            label.text = [NSString stringWithFormat:@"%i",self.contact.messageCount];
        }
        
        
        [self.contentView addSubview:self.messageCountView];
        if(self.contact.messageCount>0){
            [self.messageCountView setHidden:NO];
        }else{
            [self.messageCountView setHidden:YES];
        }
    }
    
    
    if(!self.defenceStateView){
        UIButton *defenceStateView = [UIButton buttonWithType:UIButtonTypeCustom];
        defenceStateView.frame = CGRectMake(width-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20, (height-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20)/2, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, defenceStateView.frame.size.width-20, defenceStateView.frame.size.height-20)];
        
        
        switch(self.contact.defenceState){
            case DEFENCE_STATE_ON:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_on.png"];
            }
                break;
                
            case DEFENCE_STATE_OFF:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_off.png"];
            }
                break;
                
            case DEFENCE_STATE_LOADING:
            {
                
            }
                break;
                
            case DEFENCE_STATE_WARNING_NET:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_warning.png"];
            }
                break;
                
            case DEFENCE_STATE_WARNING_PWD:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_warning.png"];
            }
                break;
            case DEFENCE_STATE_NO_PERMISSION:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_limit.png"];
            }
                break;
        }
        
        
        [defenceStateView addSubview:imageView];
        [imageView release];
        self.defenceStateView = defenceStateView;
        [self.contentView addSubview:self.defenceStateView];
        
        
    }else{
        self.defenceStateView.frame = CGRectMake(width-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20, (height-DEFENCE_STATE_VIEW_WIDTH_HEIGHT-20)/2, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20, DEFENCE_STATE_VIEW_WIDTH_HEIGHT+20);
        UIImageView *imageView = [[self.defenceStateView subviews] objectAtIndex:0];
        imageView.frame = CGRectMake(10, 10, self.defenceStateView.frame.size.width-20, self.defenceStateView.frame.size.height-20);

        switch(self.contact.defenceState){
            case DEFENCE_STATE_ON:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_on.png"];
            }
                break;
                
            case DEFENCE_STATE_OFF:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_off.png"];
            }
                break;
                
            case DEFENCE_STATE_LOADING:
            {
                
            }
                break;
                
            case DEFENCE_STATE_WARNING_NET:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_warning.png"];
            }
                break;
                
            case DEFENCE_STATE_WARNING_PWD:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_warning.png"];
            }
                break;
            case DEFENCE_STATE_NO_PERMISSION:
            {
                imageView.image = [UIImage imageNamed:@"ic_defence_limit.png"];
            }
                break;
        }
       
        [self.contentView addSubview:self.defenceStateView];
        
    }
    
    if(!self.defenceProgressView){
        YProgressView *progressView = [[YProgressView alloc] initWithFrame:CGRectMake(width-10-DEFENCE_STATE_VIEW_WIDTH_HEIGHT, (height-DEFENCE_STATE_VIEW_WIDTH_HEIGHT)/2, DEFENCE_STATE_VIEW_WIDTH_HEIGHT, DEFENCE_STATE_VIEW_WIDTH_HEIGHT)];
        progressView.backgroundView.image = [UIImage imageNamed:@"ic_progress_arrow.png"];
        
        self.defenceProgressView = progressView;
        [progressView release];
        [self.contentView addSubview:self.defenceProgressView];
        
        
    }else{
        self.defenceProgressView.frame = CGRectMake(width-10-DEFENCE_STATE_VIEW_WIDTH_HEIGHT, (height-DEFENCE_STATE_VIEW_WIDTH_HEIGHT)/2, DEFENCE_STATE_VIEW_WIDTH_HEIGHT, DEFENCE_STATE_VIEW_WIDTH_HEIGHT);
        self.defenceProgressView.backgroundView.image = [UIImage imageNamed:@"ic_progress_arrow.png"];
        [self.contentView addSubview:self.defenceProgressView];
    }
    
    
    
    [self updateDefenceStateView];
    [self.defenceStateView addTarget:self action:@selector(onDefencePress:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)onHeadClick:(id)sender{
    DLog(@"HEAD CLICK");
    if (self.delegate) {
        [self.delegate onClick:self.position contact:self.contact];
    }
}

-(void)onDefencePress:(UIButton*)button{
    //UIImageView *imageView = [[button subviews] objectAtIndex:0];
    [[FListManager sharedFList] setIsClickDefenceStateBtnWithId:self.contact.contactId isClick:YES];
    if(self.contact.defenceState==DEFENCE_STATE_WARNING_NET||self.contact.defenceState==DEFENCE_STATE_WARNING_PWD){
        self.contact.defenceState = DEFENCE_STATE_LOADING;
        [self updateDefenceStateView];
        [[P2PClient sharedClient] getDefenceState:self.contact.contactId password:self.contact.contactPassword];
        
    }else if(self.contact.defenceState==DEFENCE_STATE_ON){
        self.contact.defenceState = DEFENCE_STATE_LOADING;
        [self updateDefenceStateView];
        [[P2PClient sharedClient] setRemoteDefenceWithId:self.contact.contactId password:self.contact.contactPassword state:SETTING_VALUE_REMOTE_DEFENCE_STATE_OFF];
    }else if(self.contact.defenceState==DEFENCE_STATE_OFF){
        self.contact.defenceState = DEFENCE_STATE_LOADING;
        [self updateDefenceStateView];
        [[P2PClient sharedClient] setRemoteDefenceWithId:self.contact.contactId password:self.contact.contactPassword state:SETTING_VALUE_REMOTE_DEFENCE_STATE_ON];
    }
}

-(void)updateDefenceStateView{
    if(self.contact.onLineState==STATE_ONLINE){
        if(self.contact.defenceState==DEFENCE_STATE_LOADING){
            [self.defenceStateView setHidden:YES];
            [self.defenceProgressView setHidden:NO];
            [self.defenceProgressView start];
            
        }else{
            [self.defenceStateView setHidden:NO];
            [self.defenceProgressView setHidden:YES];
            [self.defenceProgressView stop];
        }
        
    }else{
        [self.defenceStateView setHidden:YES];
        [self.defenceProgressView setHidden:YES];
        [self.defenceProgressView stop];
    }
}

-(int)pwdStrengthWithPwd:(NSString *)pwd{//弱密码的图标提示
    int weakPwd = 0;//弱密码
    int midPwd = 1;//中密码
    int strongPwd = 2;//强密码
    int otherSt = 3;//密码框为空
    
    BOOL isWeak = [self isWeakPasswordStrengthWithPWD:pwd];
    if ((pwd.length > 0 && pwd.length < 6) || isWeak){
        return weakPwd;
        
    }else if (pwd.length >= 6 && pwd.length <= 9){
        return midPwd;
        
    }else if (pwd.length > 9){
        return strongPwd;
        
    }else{
        return otherSt;
    }
}

-(BOOL)isWeakPasswordStrengthWithPWD:(NSString *)pwd{//弱密码的图标提示
    BOOL isWeak = NO;
    
    //连号
    if (pwd.length >= 6) {
        int temp1 = (int)[pwd characterAtIndex:0];
        int temp2 = (int)[pwd characterAtIndex:1];
        int sub = abs(temp1 - temp2);
        for (int i = 1; i < pwd.length; i++) {
            int temp = (int)[pwd characterAtIndex:i]-(int)[pwd characterAtIndex:i-1];
            if (abs(temp) != sub) {
                isWeak = NO;
                break;
            }
            isWeak = YES;
        }
    }
    if (isWeak) {
        return isWeak;
    }
    
    //同号
    if (pwd.length >= 6) {
        int pwd0 = (int)[pwd characterAtIndex:0];
        for (int i = 0; i < pwd.length; i++) {
            if (pwd0 == (int)[pwd characterAtIndex:i]) {
                isWeak = YES;
            }else{
                isWeak = NO;
                break;
            }
        }
    }
    
    return isWeak;
}

@end
