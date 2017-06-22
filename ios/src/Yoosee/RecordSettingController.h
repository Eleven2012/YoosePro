//
//  RecordSettingController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-16.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P2PRecordTimeCell.h"
@class Contact;
@class RadioButton;
@class PlanTimePickView;
@interface RecordSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate,P2PRecordTimeCellDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;
    
@property(assign) BOOL isFirstCompoleteLoadRecordType;
@property(assign) BOOL isLoadingRecordType;
@property(assign) BOOL isLoadingRecordTime;
@property(assign) BOOL isLoadingRecordPlanTime;
    
@property(assign) NSInteger recordType;
@property(assign) NSInteger lastRecordType;

@property(assign) NSInteger recordTime;
@property(assign) NSInteger lastRecordTime;

@property(assign) NSInteger planTime;
@property(assign) NSInteger lastPlanTime;

@property (strong,nonatomic) RadioButton *radioRecordType1;
@property (strong,nonatomic) RadioButton *radioRecordType2;
@property (strong,nonatomic) RadioButton *radioRecordType3;

@property (strong,nonatomic) RadioButton *radioRecordTime1;
@property (strong,nonatomic) RadioButton *radioRecordTime2;
@property (strong,nonatomic) RadioButton *radioRecordTime3;

@property (strong,nonatomic) PlanTimePickView *planPicker1;
@property (strong,nonatomic) PlanTimePickView *planPicker2;



@property(assign) NSInteger remoteRecordState;
@property(assign) NSInteger lastRemoteRecordState;
@property(assign) BOOL isLoadingRemoteRecord;
@end
