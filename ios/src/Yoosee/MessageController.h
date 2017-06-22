//
//  MessageController.h
//  Yoosee
//
//  Created by gwelltime on 15-1-15.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmHistoryCell.h"//deleteAalarmRecord
@class  MBProgressHUD;
@class TopBar;

@interface MessageController : UIViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,AlarmHistoryCellDelegate>
@property (nonatomic,strong) NSMutableArray * headlineArr;

@property (nonatomic,strong) TopBar * topBar;
@property (nonatomic,strong) UIView * headView;
@property (nonatomic,strong) UIView * animationView;
@property (nonatomic,strong) UIScrollView * bottomScrollView;

@property (nonatomic) NSInteger curPage;
@property (nonatomic) NSInteger lastPage;

@property (nonatomic,strong) UITableView * alarmMsgTableView;
@property (nonatomic,strong) UITableView * systemMsgTableView;

@property (strong, nonatomic) NSMutableArray *alarmHistory;
@property (nonatomic,strong) NSIndexPath *deleteIndexPath;//deleteAalarmRecord
@property (strong, nonatomic) NSMutableArray *recommendInfoList;

@property (strong, nonatomic) MBProgressHUD *progressAlert;

@end
