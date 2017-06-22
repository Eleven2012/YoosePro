//
//  RemoteSettingController.h
//  Yoosee
//
//  Created by guojunyi on 14-5-16.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Contact;
@interface RemoteSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) Contact *contact;
    
@property(assign) BOOL isLoadingRemoteDefence;
@property(assign) BOOL isLoadingRemoteRecord;
    
@property(assign) NSInteger remoteDefenceState;
@property(assign) NSInteger remoteRecordState;
@property(assign) NSInteger lastRemoteDefenceState;
@property(assign) NSInteger lastRemoteRecordState;
@end
