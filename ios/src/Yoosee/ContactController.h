//
//  ContactController.h
//  Yoosee
//
//  Created by guojunyi on 14-3-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactCell.h"
#import "PopoverView.h"
#define ALERT_TAG_DELETE 0

#define kOperatorViewTag 15236
#define kBarViewTag 32536
#define kButtonsViewTag 32533


#define kOperatorBtnTag_Chat 23581
#define kOperatorBtnTag_Message 23582
#define kOperatorBtnTag_Modify 23583
#define kOperatorBtnTag_Monitor 23584
#define kOperatorBtnTag_Playback 23585
#define kOperatorBtnTag_Control 23586

@class  Contact;
@class TopBar;
@class DXPopover;
@interface ContactController : UIViewController<UITableViewDataSource,UITableViewDelegate,OnClickDelegate,PopoverViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *contacts;
@property (retain, nonatomic) NSMutableArray *localDevices;
@property (nonatomic) BOOL isInitPull;
@property (strong, nonatomic) NSIndexPath *curDelIndexPath;
@property (strong, nonatomic) Contact *selectedContact;

@property (strong, nonatomic) UIView *netStatusBar;

@property (strong, nonatomic) UIButton *localDevicesView;
@property (strong, nonatomic) UILabel *localDevicesLabel;
@property (nonatomic) CGFloat tableViewOffset;
@property (nonatomic,strong) UIView *emptyView;

@property (strong, nonatomic) TopBar *topBar;
@property (strong, nonatomic) DXPopover *popover;

@end
