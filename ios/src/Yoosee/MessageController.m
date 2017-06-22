//
//  MessageController.m
//  Yoosee
//
//  Created by gwelltime on 15-1-15.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "MessageController.h"
//#import "MainController.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "Alarm.h"
#import "AlarmDAO.h"
#import "UDManager.h"
#import "NetManager.h"
#import "LoginResult.h"
#import "GetAlarmRecordResult.h"
#import "AlarmHistoryCell.h"
#import "RecommendInfoListCell.h"
#import "Utils.h"
#import "Toast+UIView.h"
#import "MBProgressHUD.h"
#import "SVPullToRefresh.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"
#import "RecommendInfo.h"
#import "RecommendInfoDAO.h"
#import "WebViewController.h"
#import "ContactDAO.h"
#import "Contact.h"

#define ALERT_TAG_CLEAR 1
#define HEADVIEW_HEIGHT 40
#define ALERT_LONG_PRESS_DELETE 1314520//deleteAalarmRecord
@interface MessageController ()<MJRefreshBaseViewDelegate>
{
    CGFloat _width;
    CGFloat _height;
    
    //
    BOOL isLocalAlarmRecord;
    
    //上拉
    MJRefreshFooterView *footerView;
}
@end

@implementation MessageController
-(void)dealloc{
    [self.topBar release];
    [self.headlineArr release];
    [self.headView release];
    [self.animationView release];
    [self.bottomScrollView release];
    [self.alarmMsgTableView release];
    [self.systemMsgTableView release];
    [self.alarmHistory release];
    [self.recommendInfoList release];
    [footerView free];
    [self.progressAlert release];
    [self.deleteIndexPath release];//deleteAalarmRecord
    [super dealloc];
}

- (void)initFooterView
{
    footerView = [[MJRefreshFooterView alloc] initWithScrollView:self.alarmMsgTableView];
    footerView.delegate = self;
}

#pragma mark -MJRefreshBaseViewDelegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView == footerView)
    {
        LoginResult * login = [UDManager getLoginInfo];
        
        Alarm * alarm = self.alarmHistory[self.alarmHistory.count-1];
        NSString * index = alarm.msgIndex;
        [[NetManager sharedManager] getAlarmRecordWithUsername:login.contactId  sessionId:login.sessionId option:@"1" msgIndex:index senderList:@"1069721" checkLevelType:@"1" vKey:@"123" callBack:^(id JSON) {
            
            GetAlarmRecordResult * alarmRecordResult = (GetAlarmRecordResult *)JSON;
            
            for (Alarm * alarm in alarmRecordResult.alarmRecord) {
                [self.alarmHistory addObject:alarm];
            }
            
            int error_code = alarmRecordResult.error_code;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //整理报警记录，刷新表格
                [footerView endRefreshing];
                if (error_code == NET_RET_NO_RECORD) {
                    //无记录,显示提示信息
                    [self.view makeToast:NSLocalizedString(@"no_more_record", nil)];
                }else if (error_code == NET_RET_NO_PERMISSION){
                    [self.view makeToast:NSLocalizedString(@"no_permission", nil)];
                }else if (error_code == NET_RET_UNKNOWN_ERROR){
                    [self.view makeToast:NSLocalizedString(@"unknown_error", nil)];
                }
                if (self.alarmMsgTableView) {
                    [self.alarmMsgTableView reloadData];
                }
            });
        }];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.headlineArr = [NSMutableArray arrayWithObjects:NSLocalizedString(@"alarm_message",nil),NSLocalizedString(@"system_message",nil),nil];
        self.recommendInfoList = [NSMutableArray arrayWithCapacity:0];

    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    [mainController setBottomBarHidden:NO];
    
    if (!isLocalAlarmRecord) {//加载服务器报警数据
        self.progressAlert.dimBackground = YES;
        [self.progressAlert show:YES];
    }
    
    //阅读完返回时，刷新表格，
    [self.systemMsgTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [self updateTableView];
    
    //YES表示点击系统消息推送通知，将显示系统消息表
    if ([AppDelegate sharedDefault].isNotificationBeClicked) {
        [self.topBar setRightButtonHidden:YES];
        [UIView animateWithDuration:0.0 animations:^{
            CGRect rect = self.animationView.frame;
            rect.origin.x = _width/2;
            self.animationView.frame = rect;
        }];
        [self.bottomScrollView scrollRectToVisible:CGRectMake(_width, NAVIGATION_BAR_HEIGHT+HEADVIEW_HEIGHT, _width, _height-NAVIGATION_BAR_HEIGHT-HEADVIEW_HEIGHT) animated:NO];
        [AppDelegate sharedDefault].isNotificationBeClicked = NO;
        
        //取数据库的数据  获取推荐内容列表
        [self.recommendInfoList removeAllObjects];
        RecommendInfoDAO *recoDAO = [[RecommendInfoDAO alloc] init];
        [self.recommendInfoList addObjectsFromArray:[recoDAO findAll]];
        [recoDAO release];
        [self.systemMsgTableView reloadData];
    }
}

-(void)updateTableView{
    if (isLocalAlarmRecord) {
        //从本地获取报警记录
        AlarmDAO * alarmDAO = [[AlarmDAO alloc]init];
        self.alarmHistory = [NSMutableArray arrayWithArray:[alarmDAO findAll]];
        [alarmDAO release];
        if (self.alarmMsgTableView) {
            [self.alarmMsgTableView reloadData];
        }
    }else{
        //向服务器请求报警记录
        LoginResult * login = [UDManager getLoginInfo];
        
        [[NetManager sharedManager] getAlarmRecordWithUsername:login.contactId  sessionId:login.sessionId option:@"2" msgIndex:nil senderList:@"1069721" checkLevelType:@"1" vKey:@"123" callBack:^(id JSON) {
            
            GetAlarmRecordResult * alarmRecordResult = (GetAlarmRecordResult *)JSON;
            self.alarmHistory = [NSMutableArray arrayWithArray:alarmRecordResult.alarmRecord];
            
            int error_code = alarmRecordResult.error_code;
            if (self.alarmHistory.count == 0) {
                [footerView setHidden:YES];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressAlert hide:YES];
                //整理报警记录，刷新表格
                if (error_code == NET_RET_NO_RECORD) {
                    //无记录,显示提示信息
                    [self.view makeToast:NSLocalizedString(@"no_record", nil)];
                }else if (error_code == NET_RET_NO_PERMISSION){
                    [self.view makeToast:NSLocalizedString(@"no_permission", nil)];
                }else if (error_code == NET_RET_UNKNOWN_ERROR){
                    [self.view makeToast:NSLocalizedString(@"unknown_error", nil)];
                }
                if (self.alarmMsgTableView) {
                    [self.alarmMsgTableView reloadData];
                }
            });
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initComponent];
    
    //must be after initComponent
    if (!isLocalAlarmRecord) {
        [self initFooterView];
    }
}


#define ALARM_HISTORY_CELL_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 120:90)
#define RECOMMEND_INFO_CELL_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 250:220)

//取服务器的数据  获取推荐内容列表
-(void)getRecommendInfoList{
    
    // get storeID
    NSString *storeID = nil;
    
    //get isManualStoreID from Common-Configuration.plist
    NSString * plist = [[NSBundle mainBundle] pathForResource:@"Common-Configuration" ofType:@"plist"];
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
    BOOL isManualStoreID = [dic[@"isManualStoreID"] boolValue];
    if (isManualStoreID) {
        //get ManualStoreID from Common-Configuration.plist
        storeID = dic[@"ManualStoreID"];
        if ([storeID isEqualToString:@""]) {
            storeID = nil;
        }
    }else{
        //get storeID from local
        storeID = [[NSUserDefaults standardUserDefaults] objectForKey:@"StoreID"];
    }
    if (!storeID) {
        //要提示一下呢（请求添加设备，获取商城ID,或者在.plist文件添加商城ID）
        
        [self.view makeToast:NSLocalizedString(@"mall_id_unexist", nil)];
        return ;
    }
    
    //取出最新的一条记录的Index传给服务器，获取最新的推荐列表信息（本地没有的）
    RecommendInfoDAO *recoDAO = [[RecommendInfoDAO alloc] init];
    NSArray *arr = [recoDAO findAll];
    NSInteger index = 0;
    if (arr.count > 0) {
        RecommendInfo *m = arr[0];//最新的一条记录
        index = m.messageID;
    }
    [recoDAO release];
    LoginResult * login = [UDManager getLoginInfo];
    NSInteger userID = login.contactId.integerValue | 0x80000000;
    NSString *sessionID = login.sessionId;
    NSString *urlString = [NSString stringWithFormat:@"http://192.168.1.231/Business/Seller/RecommendInfo.ashx?UserID=%d&SessionID=%@&StoreID=%@&Index=%d&PageIndex=1&PageSize=100",userID,sessionID,storeID,index];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue ] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if ((!error)) {//发送请求成功
            NSError *parseError;
            id dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
            
            int error_code = [[dictionary objectForKey:@"error_code"] intValue];
            if (error_code == 0) {//成功获取到数据
                NSString *RL = [dictionary objectForKey:@"RL"];
                
                NSArray *array = [RL componentsSeparatedByString:@";"];
                
                for(NSString *record in array){
                    if([record isEqualToString:@""]){
                        continue;
                    }
                    
                    NSArray *detailArray = [record componentsSeparatedByString:@","];
                    RecommendInfo * recommendInfo = [[RecommendInfo alloc] init];
                    
                    for (int i = 0; i < detailArray.count; i++) {
                        switch (i) {
                            case 0://database key
                            {
                                recommendInfo.messageID = [detailArray[i] integerValue];
                            }
                                break;
                            case 1:
                            {
                                NSString *title = [Utils getNormalStringByDecodedBase64String:detailArray[i]];
                                recommendInfo.titleString = title;
                            }
                                break;
                            case 2:
                            {
                                NSString *content = [Utils getNormalStringByDecodedBase64String:detailArray[i]];
                                recommendInfo.contentString = content;
                            }
                                break;
                            case 3:
                            {
                                recommendInfo.imageURLString = detailArray[i];
                            }
                                break;
                            case 4:
                            {
                                NSString *imageLinkURLString = [Utils getNormalStringByDecodedBase64String:detailArray[i]];
                                recommendInfo.imageLinkURLString = imageLinkURLString;
                            }
                                break;
                            case 5:
                            {
                                //预览ID
                            }
                                break;
                            case 6:
                            {
                                recommendInfo.timeString = detailArray[i];
                            }
                                break;
                            case 7:
                            {
                                //状态
                            }
                                break;
                        }
                    }
                    recommendInfo.isRead = NO;//YES表示已读
                    
                    //数据库的主键是唯一的，与主键相同的数据当然也插入不了。
                    RecommendInfoDAO *recoDAO = [[RecommendInfoDAO alloc] init];
                    [recoDAO insert:recommendInfo];
                    [recoDAO release];
                    [recommendInfo release];
                }
                
                //取数据库的数据  获取推荐内容列表 刷新表格
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.recommendInfoList removeAllObjects];
                    RecommendInfoDAO *recoDAO = [[RecommendInfoDAO alloc] init];
                    [self.recommendInfoList addObjectsFromArray:[recoDAO findAll]];
                    [recoDAO release];
                    [self.systemMsgTableView reloadData];
                });
            }else{//获取数据失败
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:NSLocalizedString(@"get_data_fail", nil)];
                });
            }
        }else{//发送请求失败
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:NSLocalizedString(@"send_request_fail", nil)];
            });
        }
    }];
}

-(void)initComponent{
    //显示server OR local的alarmRecords(.plist)
    NSString * plist = [[NSBundle mainBundle] pathForResource:@"Common-Configuration" ofType:@"plist"];
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plist];
    isLocalAlarmRecord = [dic[@"isLocalAlarmRecord"] boolValue];
    
    [self.view setBackgroundColor:XBgColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    _width = rect.size.width;
    _height = rect.size.height;
    
    //navigation bar
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, _width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"message_item",nil)];
    if (isLocalAlarmRecord) {//显示清除本地报警记录按钮
        [topBar setRightButtonHidden:NO];
    }else{
        [topBar setRightButtonHidden:YES];
    }
    [topBar setRightButtonIcon:[UIImage imageNamed:@"ic_bar_btn_clear.png"]];
    [topBar.rightButton addTarget:self action:@selector(clearPress) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:topBar];
    self.topBar = topBar;
    [topBar release];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //headline
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, _width, HEADVIEW_HEIGHT)];
    headView.layer.borderWidth = 1.0;
    headView.layer.borderColor = XBlue.CGColor;
    
    CGFloat headlineW = _width/2;
    for (int i = 0; i < self.headlineArr.count; i++) {
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(headlineW*i, 0, headlineW, HEADVIEW_HEIGHT)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = self.headlineArr[i];
        label.textColor = [UIColor blackColor];
        [headView addSubview:label];
        
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myTap:)];
        [label addGestureRecognizer:tap];
        [tap release];
        [label release];
    }
    
    //slider block
    UIView* animationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headlineW, HEADVIEW_HEIGHT)];
    animationView.backgroundColor = UIColorFromRGBA(0x5ab8ffff);
    animationView.alpha = 0.3;
    [headView addSubview:animationView];
    self.animationView = animationView;
    [animationView release];
    //[self.view addSubview:headView];//不要自定义segment
    self.headView = headView;
    [headView release];
    
    //
    UIScrollView* bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, _width, _height-NAVIGATION_BAR_HEIGHT-TAB_BAR_HEIGHT)];
    bottomScrollView.contentSize = CGSizeMake(_width*1, _height-NAVIGATION_BAR_HEIGHT-TAB_BAR_HEIGHT);
    bottomScrollView.showsHorizontalScrollIndicator = NO;
    bottomScrollView.bounces = NO;
    bottomScrollView.pagingEnabled = YES;
    //bottomScrollView.delegate = self;//去掉代理
    [self.view addSubview:bottomScrollView];
    self.bottomScrollView = bottomScrollView;
    [bottomScrollView release];
    
    for (int i = 0; i < self.headlineArr.count; i++) {
        
        UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(_width*i, 0, _width, self.bottomScrollView.frame.size.height) style:UITableViewStylePlain];
        [tableView setBackgroundColor:XBgColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.bottomScrollView addSubview:tableView];
        
        if (i == 0) {
            self.alarmMsgTableView = tableView;
            if (!isLocalAlarmRecord) {
                [tableView addPullToRefreshWithActionHandler:^{
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        sleep(1.0);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self updateTableView];
                            [self.alarmMsgTableView.pullToRefreshView stopAnimating];
                        });
                    });
                    
                }];
            }
            
            if (!isLocalAlarmRecord) {
                MBProgressHUD *progress = [[MBProgressHUD alloc]initWithView:self.view];
                self.progressAlert = progress;
                self.progressAlert.labelText = NSLocalizedString(@"loading", nil);
                [self.view addSubview:self.progressAlert];
                [progress release];
            }
        }else{
            self.systemMsgTableView = tableView;
            
            //下拉刷新，获取最新的推荐列表信息（本地没有的，其实是预览推荐信息）
            [tableView addPullToRefreshWithActionHandler:^{
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    sleep(1.0);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self getRecommendInfoList];
                        [self.systemMsgTableView.pullToRefreshView stopAnimating];
                    });
                });
                
            }];
        }
        [tableView release];
    }
}

-(void)clearPress{
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sure_to_clear", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
    deleteAlert.tag = ALERT_TAG_CLEAR;
    [deleteAlert show];
    [deleteAlert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_CLEAR:
        {
            if(buttonIndex==1){
                AlarmDAO *alarmDAO = [[AlarmDAO alloc] init];
                [alarmDAO clear];
                [self updateTableView];
                [alarmDAO release];
                [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
            }
        }
            break;
        case ALERT_LONG_PRESS_DELETE://deleteAalarmRecord
        {
            if(buttonIndex==1){
                if ([self.alarmHistory count] > 0) {
                    //删除本地保存的报警记录
                    Alarm * alarm = [self.alarmHistory objectAtIndex:self.deleteIndexPath.row];
                    AlarmDAO * alarmDAO = [[AlarmDAO alloc] init];
                    [alarmDAO delete:alarm];
                    [alarmDAO release];
                    
                    //删除table显示的报警记录
                    [self.alarmHistory removeObjectAtIndex:self.deleteIndexPath.row];
                    
                    [self.alarmMsgTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.deleteIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.alarmMsgTableView reloadData];
                    
                }else{
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                    return;
                }
            }
        }
            break;
    }
}

//不执行
- (void)myTap:(UITapGestureRecognizer *)tap
{
    [UIView animateWithDuration:0.1 animations:^{
        // 点击哪个Label就将动画的滑块移动到对应的Label之上
        self.animationView.frame = CGRectMake(tap.view.frame.origin.x, 0, _width/2, HEADVIEW_HEIGHT);
    } completion:^(BOOL finished) {
        self.curPage = tap.view.frame.origin.x / (_width/2);
        [self.bottomScrollView scrollRectToVisible:CGRectMake(_width*self.curPage, NAVIGATION_BAR_HEIGHT+HEADVIEW_HEIGHT, _width, _height-NAVIGATION_BAR_HEIGHT-HEADVIEW_HEIGHT) animated:YES];
        if(self.curPage == 0 && isLocalAlarmRecord){
            [self.topBar setRightButtonHidden:NO];
        }else{
            [self.topBar setRightButtonHidden:YES];
            
   
            //取数据库的数据  获取推荐内容列表
            [self.recommendInfoList removeAllObjects];
            RecommendInfoDAO *recoDAO = [[RecommendInfoDAO alloc] init];
            [self.recommendInfoList addObjectsFromArray:[recoDAO findAll]];
            [recoDAO release];
            [self.systemMsgTableView reloadData];
        }
    }];
}

#pragma mark - UIScrollViewDelegate
//不执行，因为未设置代理
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView != self.alarmMsgTableView && scrollView != self.systemMsgTableView){
        self.curPage = scrollView.contentOffset.x / _width;
        [UIView animateWithDuration:0.1 animations:^{
            CGRect rect = self.animationView.frame;
            rect.origin.x = (_width/2)*self.curPage;
            self.animationView.frame = rect;
        }];
        if(self.curPage == 0 && isLocalAlarmRecord){
            [self.topBar setRightButtonHidden:NO];
        }else{
            [self.topBar setRightButtonHidden:YES];
            
            if (self.curPage != self.lastPage) {//在最后一页往左滑动时，则不刷新
                
                
                //取数据库的数据  获取推荐内容列表
                [self.recommendInfoList removeAllObjects];
                RecommendInfoDAO *recoDAO = [[RecommendInfoDAO alloc] init];
                [self.recommendInfoList addObjectsFromArray:[recoDAO findAll]];
                [recoDAO release];
                [self.systemMsgTableView reloadData];
            }
        }
        
        self.lastPage = self.curPage;
    }
    
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.alarmMsgTableView == tableView) {//报警消息
        return [self.alarmHistory count];
    }else{//系统消息
        return self.recommendInfoList.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.alarmMsgTableView == tableView) {
        return ALARM_HISTORY_CELL_HEIGHT;
    }else{//动态调整cell高度
        RecommendInfo *recommendInfo = self.recommendInfoList[indexPath.row];
        CGFloat titleTextHeight = [Utils getStringHeightWithString:recommendInfo.titleString font:XFontBold_16 maxWidth:_width-10];
        CGFloat timeTextHeight = [Utils getStringHeightWithString:recommendInfo.timeString font:XFontBold_16 maxWidth:_width-10];
        CGFloat contentTextHeight = [Utils getStringHeightWithString:recommendInfo.contentString font:XFontBold_16 maxWidth:_width-10];
        return titleTextHeight+timeTextHeight+170+contentTextHeight+50;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.alarmMsgTableView == tableView) {//报警消息
        static NSString *identifier = @"AlarmHistoryCell";
        
        
        AlarmHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if(cell==nil){
            cell = [[[AlarmHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
            [cell setBackgroundColor:XBGAlpha];
            
        }
        
        Alarm * alarm = [self.alarmHistory objectAtIndex:indexPath.row];
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:alarm.deviceId];
        NSString *contactName = contact.contactName;
        if ([alarm.deviceId isEqualToString:contactName] || contactName == nil) {
            [cell setDeviceId:alarm.deviceId];
        }else{
            [cell setDeviceId:contactName];
        }
        [contactDAO release];
        [cell setAlarmTime:[Utils convertTimeByInterval:alarm.alarmTime]];
        [cell setAlarmType:alarm.alarmType];
        [cell setAlarm:alarm];//addgroupItem
        
        [cell setIndexPath:indexPath];
        cell.delegate = self;//deleteAalarmRecord
        
        UIImage *backImg = [UIImage imageNamed:@"bg_normal_cell.png"];
        UIImage *backImg_p = [UIImage imageNamed:@"bg_normal_cell_p.png"];
        UIImageView *backImageView = [[UIImageView alloc] init];
        UIImageView *backImageView_p = [[UIImageView alloc] init];
        
        backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
        backImageView.image = backImg;
        [cell setBackgroundView:backImageView];
        
        backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.5 topCapHeight:backImg_p.size.height*0.5];
        backImageView_p.image = backImg_p;
        [cell setSelectedBackgroundView:backImageView_p];
        
        [backImageView release];
        [backImageView_p release];
        
        return cell;
    }else{//系统消息
        static NSString *identifier = @"RecommendInfoListCell";
        
        
        RecommendInfoListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(cell==nil){
            cell = [[[RecommendInfoListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
            [cell setBackgroundColor:XBGAlpha];
            
        }
        
        //
        RecommendInfo *recommendInfo = self.recommendInfoList[indexPath.row];
        cell.titleString = recommendInfo.titleString;
        cell.timeString = recommendInfo.timeString;
        cell.imageURLString = recommendInfo.imageURLString;
        cell.contentString = recommendInfo.contentString;
        cell.isReadCell = recommendInfo.isRead;
        
        UIImage *backImg = [UIImage imageNamed:@"bg_normal_cell.png"];
        UIImage *backImg_p = [UIImage imageNamed:@"bg_normal_cell_p.png"];
        UIImageView *backImageView = [[UIImageView alloc] init];
        UIImageView *backImageView_p = [[UIImageView alloc] init];
        
        backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
        backImageView.image = backImg;
        [cell setBackgroundView:backImageView];
        
        backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.5 topCapHeight:backImg_p.size.height*0.5];
        backImageView_p.image = backImg_p;
        [cell setSelectedBackgroundView:backImageView_p];
        
        [backImageView release];
        [backImageView_p release];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.systemMsgTableView) {
        RecommendInfo * m = self.recommendInfoList[indexPath.row];
        if (!m.isRead) {
            m.isRead = YES;
            RecommendInfoDAO *recoDAO = [[RecommendInfoDAO alloc] init];
            [recoDAO updateDBWithKey:m.messageID modify:m];
            
            
            //每阅读一个未读的系统消息，遍历数据库，判断所有的系统消息是否全已读，若全已读，则隐藏角标
            //每次遍历都遍历所有的
            NSArray *arr = [recoDAO findAll];
            BOOL isAllRecommendInfoBeRead = NO;
            for (RecommendInfo *recInfo in arr) {
                if (!recInfo.isRead) {
                    isAllRecommendInfoBeRead = NO;
                    break;
                }
                isAllRecommendInfoBeRead = YES;
            }
            if (isAllRecommendInfoBeRead) {//所有的系统消息全已读，隐藏角标
                MainController *mainController = [AppDelegate sharedDefault].mainController;
                mainController.bottomBar.isHavingNewInfo = NO;//隐藏角标
                [mainController.bottomBar setNeedsLayout];
            }
            [recoDAO release];
        }
        
        
        RecommendInfo *recommendInfo = self.recommendInfoList[indexPath.row];
        WebViewController *webViewController = [[WebViewController alloc] init];
        webViewController.imgURLLinkString = recommendInfo.imageLinkURLString;
        webViewController.isFirstLoading = YES;
        if ([webViewController.imgURLLinkString isEqualToString:@""]) {
            [self.view makeToast:NSLocalizedString(@"invalid_link", nil)];
            [self.systemMsgTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }else{
            [self.navigationController pushViewController:webViewController animated:YES];
        }
        [webViewController release];
    }
}

#pragma mark - 长按删除报警记录
-(void)longPress:(NSIndexPath *)indexPath{//deleteAalarmRecord
    self.deleteIndexPath = indexPath;
   
    
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sure_to_delete", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
    deleteAlert.tag = ALERT_LONG_PRESS_DELETE;
    [deleteAlert show];
    [deleteAlert release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interface {
    return (interface == UIInterfaceOrientationPortrait );
}

#ifdef IOS6

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
#endif

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

@end
