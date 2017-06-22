//
//  AlarmHistoryCell.h
//  Yoosee
//
//  Created by Jie on 14-10-22.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Alarm.h"//addgroupItem

@protocol AlarmHistoryCellDelegate//deleteAalarmRecord

@optional
-(void)longPress:(NSIndexPath* )indexPath;

@end

@interface AlarmHistoryCell : UITableViewCell

@property (strong, nonatomic) UILabel *deviceLabel;
@property (strong, nonatomic) UILabel *typeLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *groupItemLabel;//addgroupItem

@property (strong, nonatomic) UILabel *deviceLabelText;
@property (strong, nonatomic) UILabel *typeLabelText;

@property (strong, nonatomic) Alarm *alarm;//addgroupItem
@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *alarmTime;
@property (nonatomic) int alarmType;

@property (strong,nonatomic) NSIndexPath* indexPath;//deleteAalarmRecord

@property (strong, nonatomic) id<AlarmHistoryCellDelegate> delegate;//deleteAalarmRecord

@end
