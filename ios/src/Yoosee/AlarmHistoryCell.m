//
//  AlarmHistoryCell.m
//  Yoosee
//
//  Created by Jie on 14-10-22.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "AlarmHistoryCell.h"
#import "Constants.h"

@implementation AlarmHistoryCell

-(void)dealloc{
    [self.typeLabel release];
    [self.typeLabelText release];
    [self.deviceLabel release];
    [self.deviceLabelText release];
    [self.timeLabel release];
    [self.groupItemLabel release];//addgroupItem
    [self.alarm release];//addgroupItem
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

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#define LABEL_WIDTH 165
#define TYPE_LABEL_WIDTH 160
#define LABEL_HEIGHT 25
#define TIME_LABEL_WIDTH 150
#define TEXT_LABERL_WIDTH 150

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.backgroundView.frame.size.width;
    //CGFloat height = self.backgroundView.frame.size.height;
    
    //设备
    if (!self.deviceLabel) {
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 3, LABEL_WIDTH, LABEL_HEIGHT)];
        
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_device", nil),self.deviceId];
        
        
        [self.contentView addSubview:textLabel];
        self.deviceLabel = textLabel;
        [textLabel release];
    }else{
        self.deviceLabel.frame = CGRectMake(5, 3, LABEL_WIDTH, LABEL_HEIGHT);
        self.deviceLabel.textAlignment = NSTextAlignmentLeft;
        self.deviceLabel.textColor = XBlack;
        self.deviceLabel.backgroundColor = XBGAlpha;
        [self.deviceLabel setFont:XFontBold_16];
        self.deviceLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_device", nil),self.deviceId];
        
        [self.contentView addSubview:self.deviceLabel];
    }
    
    //类型
    if (!self.typeLabel) {
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 3+LABEL_HEIGHT+10, TYPE_LABEL_WIDTH, LABEL_HEIGHT)];
        
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        if (self.alarmType==1){
            textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"extern_alarm", nil)];
        }else if (self.alarmType==2){
            textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"motion_dect_alarm", nil)];
            
        }else if (self.alarmType==3){
            textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"emergency_alarm", nil)];
            
        }else if (self.alarmType==4){
            textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"debug_alarm", nil)];
            
        }else if (self.alarmType==5){
            textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"ext_line_alarm", nil)];
            
        }else if (self.alarmType==6){
            textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"low_vol_alarm", nil)];
            
        }else if (self.alarmType==7){
            textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"pir_alarm", nil)];
            
        }else if (self.alarmType==8){
            textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"defence_alarm", nil)];
            
        }else if (self.alarmType==9){
            textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"defence_disable_alarm", nil)];
            
        }else if (self.alarmType==10){
            textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"battery_low_vol", nil)];
            
        }else if (self.alarmType==11){
            textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"update_to_ser", nil)];
            
        }else if (self.alarmType==13){
            textLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"somebody_visit", nil)];
            
        }

        
        [self.contentView addSubview:textLabel];
        self.typeLabel = textLabel;
        [textLabel release];
    }else{
        self.typeLabel.frame = CGRectMake(5, 3+LABEL_HEIGHT+10, TYPE_LABEL_WIDTH, LABEL_HEIGHT);
        self.typeLabel.textAlignment = NSTextAlignmentLeft;
        self.typeLabel.textColor = XBlack;
        self.typeLabel.backgroundColor = XBGAlpha;
        [self.typeLabel setFont:XFontBold_16];
        if (self.alarmType==1){
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"extern_alarm", nil)];
        }else if (self.alarmType==2){
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"motion_dect_alarm", nil)];
            
        }else if (self.alarmType==3){
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"emergency_alarm", nil)];
            
        }else if (self.alarmType==4){
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"debug_alarm", nil)];
            
        }else if (self.alarmType==5){
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"ext_line_alarm", nil)];
            
        }else if (self.alarmType==6){
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"low_vol_alarm", nil)];
            
        }else if (self.alarmType==7){
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"pir_alarm", nil)];
            
        }else if (self.alarmType==8){
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"defence_alarm", nil)];
            
        }else if (self.alarmType==9){
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"defence_disable_alarm", nil)];
            
        }else if (self.alarmType==10){
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"battery_low_vol", nil)];
            
        }else if (self.alarmType==11){
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"update_to_ser", nil)];
            
        }else if (self.alarmType==13){
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_type", nil),NSLocalizedString(@"somebody_visit", nil)];
            
        }

        
        [self.contentView addSubview:self.typeLabel];
    }
    
    //防区通道
    if (self.alarmType == 1) {//addgroupItem
        if (!self.groupItemLabel) {
            UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(width-LABEL_WIDTH+10, 3+LABEL_HEIGHT+10, TYPE_LABEL_WIDTH, LABEL_HEIGHT)];
            
            textLabel.textAlignment = NSTextAlignmentLeft;
            textLabel.textColor = XBlack;
            textLabel.backgroundColor = XBGAlpha;
            [textLabel setFont:XFontBold_16];
            [self.contentView addSubview:textLabel];
            self.groupItemLabel = textLabel;
            [textLabel release];
        }
        if (self.alarm.alarmGroup>=1 && self.alarm.alarmGroup<=8) {
            NSString *message = [NSString stringWithFormat:@"%@:%@  %@:%d",NSLocalizedString(@"defence_group", nil),[self groupName:self.alarm.alarmGroup],NSLocalizedString(@"defence_item", nil),self.alarm.alarmItem+1];
            self.groupItemLabel.text = message;
        }
        
    }else{//防止复用问题
        self.groupItemLabel.text = @"";
    }

    //时间
    if (!self.timeLabel) {
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(width-LABEL_WIDTH+10, 3, TIME_LABEL_WIDTH, LABEL_HEIGHT)];//addgroupItem
        textLabel.textAlignment = NSTextAlignmentLeft;//addgroupItem
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.alarmTime;
        
        [self.contentView addSubview:textLabel];
        self.timeLabel = textLabel;
        [textLabel release];
    }else{
        self.timeLabel.frame = CGRectMake(width-LABEL_WIDTH+10, 3, TIME_LABEL_WIDTH, LABEL_HEIGHT);//addgroupItem
        self.timeLabel.textAlignment = NSTextAlignmentLeft;//addgroupItem
        self.timeLabel.textColor = XBlack;
        self.timeLabel.backgroundColor = XBGAlpha;
        [self.timeLabel setFont:XFontBold_16];
        self.timeLabel.text = self.alarmTime;
        
        [self.contentView addSubview:self.timeLabel];
    }
    
    UILongPressGestureRecognizer* longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureToLongPress:)];
    [longPressGes setMinimumPressDuration:1.0f];
    [self.contentView addGestureRecognizer:longPressGes];
    [longPressGes release];//deleteAalarmRecord

//    if (!self.deviceLabelText) {
//        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.deviceLabel.frame.origin.x+LABEL_WIDTH+3, 3+LABEL_HEIGHT+10, TEXT_LABERL_WIDTH, LABEL_HEIGHT)];
//        
//        textLabel.textAlignment = NSTextAlignmentLeft;
//        textLabel.textColor = XBlack;
//        textLabel.backgroundColor = XBGAlpha;
//        [textLabel setFont:XFontBold_16];
//        textLabel.text = self.deviceId;
//        
//        [self.contentView addSubview:textLabel];
//        self.deviceLabelText = textLabel;
//        [textLabel release];
//    }else{
//        self.deviceLabelText.frame = CGRectMake(self.deviceLabel.frame.origin.x+LABEL_WIDTH+3, 3+LABEL_HEIGHT+10, TEXT_LABERL_WIDTH, LABEL_HEIGHT);
//        self.deviceLabelText.textAlignment = NSTextAlignmentLeft;
//        self.deviceLabelText.textColor = XBlack;
//        self.deviceLabelText.backgroundColor = XBGAlpha;
//        [self.deviceLabelText setFont:XFontBold_16];
//        self.deviceLabelText.text = self.deviceId;
//        
//        [self.contentView addSubview:self.deviceLabelText];
//    }
    
//    if (!self.typeLabelText) {
//        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.typeLabel.frame.origin.x+LABEL_WIDTH+3, 3+LABEL_HEIGHT+10, TEXT_LABERL_WIDTH, LABEL_HEIGHT)];
//        
//        textLabel.textAlignment = NSTextAlignmentLeft;
//        textLabel.textColor = XBlack;
//        textLabel.backgroundColor = XBGAlpha;
//        [textLabel setFont:XFontBold_16];
//        if (self.alarmType==1){
//            textLabel.text = NSLocalizedString(@"extern_alarm", nil);
//            
//        }else if (self.alarmType==2){
//            textLabel.text = NSLocalizedString(@"motion_dect_alarm", nil);
//            
//        }else if (self.alarmType==3){
//            textLabel.text = NSLocalizedString(@"emergency_alarm", nil);
//            
//        }else if (self.alarmType==5){
//            textLabel.text = NSLocalizedString(@"ext_line_alarm", nil);
//            
//        }else if (self.alarmType==6){
//            textLabel.text = NSLocalizedString(@"low_vol_alarm", nil);
//            
//        }else if (self.alarmType==7){
//            textLabel.text = NSLocalizedString(@"pir_alarm", nil);
//            
//        }
//        
//        [self.contentView addSubview:textLabel];
//        self.typeLabelText = textLabel;
//        [textLabel release];
//    }else{
//        self.typeLabelText.frame = CGRectMake(self.typeLabel.frame.origin.x+LABEL_WIDTH+3, 3+LABEL_HEIGHT+10, TEXT_LABERL_WIDTH, LABEL_HEIGHT);
//        self.typeLabelText.textAlignment = NSTextAlignmentLeft;
//        self.typeLabelText.textColor = XBlack;
//        self.typeLabelText.backgroundColor = XBGAlpha;
//        [self.typeLabelText setFont:XFontBold_16];
//        if (self.alarmType==1){
//            self.typeLabelText.text = NSLocalizedString(@"extern_alarm", nil);
//            
//        }else if (self.alarmType==2){
//            self.typeLabelText.text = NSLocalizedString(@"motion_dect_alarm", nil);
//            
//        }else if (self.alarmType==3){
//            self.typeLabelText.text = NSLocalizedString(@"emergency_alarm", nil);
//            
//        }else if (self.alarmType==5){
//            self.typeLabelText.text = NSLocalizedString(@"ext_line_alarm", nil);
//
//        }else if (self.alarmType==6){
//            self.typeLabelText.text = NSLocalizedString(@"low_vol_alarm", nil);
//
//        }else if (self.alarmType==7){
//            self.typeLabelText.text = NSLocalizedString(@"pir_alarm", nil);
//
//        }
//        
//        [self.contentView addSubview:self.typeLabelText];
//    }

}

-(void)gestureToLongPress:(UILongPressGestureRecognizer* )ges{//deleteAalarmRecord
    switch (ges.state) {
        case UIGestureRecognizerStateEnded:
        {
            
        }
            break;
        case UIGestureRecognizerStateBegan:
        {
            [self.delegate longPress:self.indexPath];
        }
            break;
        default:
            break;
    }
}

-(NSString *)groupName:(int)group{//addgroupItem
    NSString *groupName = @"";
    switch(group){
        case 1:
        {
            groupName = NSLocalizedString(@"hall", nil);
        }
            break;
        case 2:
        {
            groupName = NSLocalizedString(@"window", nil);
        }
            break;
        case 3:
        {
            groupName = NSLocalizedString(@"balcony", nil);
        }
            break;
        case 4:
        {
            groupName = NSLocalizedString(@"bedroom", nil);
        }
            break;
        case 5:
        {
            groupName = NSLocalizedString(@"kitchen", nil);
        }
            break;
        case 6:
        {
            groupName = NSLocalizedString(@"courtyard", nil);
        }
            break;
        case 7:
        {
            groupName = NSLocalizedString(@"door_lock", nil);
        }
            break;
        case 8:
        {
            groupName = NSLocalizedString(@"other", nil);
        }
            break;
    }
    return groupName;
}

@end
