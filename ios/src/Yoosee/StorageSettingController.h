//
//  StorageSettingController.h
//  Yoosee
//
//  Created by gwelltime on 14-11-8.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contact;
@class  MBProgressHUD;

@interface StorageSettingController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(strong, nonatomic) Contact *contact;
@property (strong, nonatomic) MBProgressHUD *progressAlert;

@property(strong, nonatomic) UITableView *tableView;
@property (nonatomic, assign) int storageCount;
@property (nonatomic, assign) int storageType;
@property (nonatomic, assign) int sdCardID;
@property (strong, nonatomic) NSString * sdTotalStorage;
@property (strong, nonatomic) NSString * sdFreeStorage;
@property (strong, nonatomic) NSString * usbTotalStorage;
@property (strong, nonatomic) NSString * usbFreeStorage;

@property(assign) BOOL isLoadingStorageInfo;
@property(assign) BOOL isLoadingStorageFormat;
@end
