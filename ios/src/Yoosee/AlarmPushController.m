//
//  AlarmPushController.m
//  2cu
//
//  Created by 高琦 on 15/3/12.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//
#define ALARMVIEW_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 300:200)
#define REJECTVIEW_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 40:30)
#define TOUCHBTNVIEW_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 100:80)
#define LEFT_DOOLBELL_WIDTH_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 100:100)

#import "AlarmPushController.h"
#import "mesg.h"
#import "MainController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "ContactDAO.h"
#import "Contact.h"
#import "Toast+UIView.h"
#import "ContactDAO.h"
//#import "DefenceDao.h"

#define KYL_HEADER_VIEW_HEIGHT 75

@interface AlarmPushController ()

@end

@implementation AlarmPushController

-(void)dealloc{
     //{{--kongyulu at 20150920
    self.alarmSnapImageView = nil;
    self.touchbtnview = nil;
    self.downlineview  = nil;
    self.acceptview  = nil;
    self.rejectview  = nil;
    self.contactId  = nil;
    self.contactName  = nil;
    //}}--kongyulu at 20150920
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated{
    self.isshow = YES;
    self.isbreathe = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(back) userInfo:nil repeats:NO];
    
    NSString *filePath = [Utils getHeaderFilePathWithId:self.contactId];
    UIImage *headerViewImg = [UIImage imageWithContentsOfFile:filePath];
    self.alarmSnapImageView.image = headerViewImg;
    //{{--kongyulu at 20150920
    [super viewWillAppear:animated];
    //}}--kongyulu at 20150920
}

-(void)viewWillDisappear:(BOOL)animated{
    self.isshow = NO;
    self.isbreathe = NO;
    [self.timer setFireDate:[NSDate distantFuture]];
    
    [AppDelegate sharedDefault].isShowingDoorBellAlarm = NO;
    
    //{{--kongyulu at 20150920
    [super viewWillDisappear:animated];
    //}}--kongyulu at 20150920
}

#pragma mark - 15秒后自动退出门铃推送界面
-(void)back{
    self.isshow = NO;
    AppDelegate * appDdelegate = [AppDelegate sharedDefault];
    appDdelegate.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
    MainController * mainController = [AppDelegate sharedDefault].mainController;
    appDdelegate.window.rootViewController = mainController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initComponent];
}

-(void)initComponent{
    self.isbreathe = YES;
    self.view.layer.contents = (id)[UIImage imageNamed:@"alarmpush_bg.png"].CGImage;
    CGFloat  fWidth = self.view.frame.size.width-20;
    CGFloat fHeight = fWidth * 0.75;
//    self.alarmSnapImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 10, self.view.frame.origin.y + 90, fWidth, fHeight)] autorelease];
//    [self.view addSubview:_alarmSnapImageView];
    //{{--kongyulu at 20150920
    
    
    
    CGFloat headerViewWidth = KYL_HEADER_VIEW_HEIGHT*4/3;
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-headerViewWidth)/2, ((self.view.frame.size.height/2)-KYL_HEADER_VIEW_HEIGHT)/2-30, headerViewWidth, KYL_HEADER_VIEW_HEIGHT)];
    
    NSString *filePath = [NSString stringWithFormat:@"%@",[Utils getHeaderFilePathWithId:self.contactId]];
    UIImage *headerViewImg = [UIImage imageWithContentsOfFile:filePath];
    
    if(headerViewImg==nil){
        headerViewImg = [UIImage imageNamed:@"ic_header.png"];
    }
    
    headerView.image = headerViewImg;
    headerView.contentMode = UIViewContentModeScaleAspectFit;
    self.alarmSnapImageView = headerView;
    [self.view addSubview:headerView];
    [headerView release];

    //}}--kongyulu at 20150920
    self.alarmSnapImageView.image = self.imgCurrentCameraCover;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    
    //设备名...
    if (self.contactName) {
        CGSize labelSize = [self.contactName sizeWithFont:XFontBold_18];
        UILabel* lableName = [[UILabel alloc] initWithFrame:CGRectMake((width-labelSize.width)/2, 15, labelSize.width, 40)];
        lableName.backgroundColor = [UIColor clearColor];
        lableName.textColor = XWhite;
        lableName.text = self.contactName;
        lableName.textAlignment = NSTextAlignmentCenter;
        lableName.font = XFontBold_18;
        [self.view addSubview:lableName];
        [lableName release];
    }

    //设备id
    NSString* textDevice = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"alarm_device", nil),self.contactId];
    CGSize labelSize = [textDevice sizeWithFont:XFontBold_14];
    UILabel* alarmarealabel = [[UILabel alloc] initWithFrame:CGRectMake((width-labelSize.width)/2, 40, labelSize.width, 40)];
    alarmarealabel.backgroundColor = [UIColor clearColor];
    alarmarealabel.textColor = XWhite;
    alarmarealabel.text = textDevice;
    alarmarealabel.textAlignment = NSTextAlignmentCenter;
    alarmarealabel.font = XFontBold_14;
    [self.view addSubview:alarmarealabel];
    [alarmarealabel release];
    
    
    UIImageView * alarmview = [[UIImageView alloc] initWithFrame:CGRectMake(width/2-ALARMVIEW_WIDTH_HEIGHT/2, 150, ALARMVIEW_WIDTH_HEIGHT, ALARMVIEW_WIDTH_HEIGHT)];
    alarmview.image = [UIImage imageNamed:@"em_alarm.png"];
    alarmview.contentMode = UIViewContentModeScaleAspectFit;
    NSArray *imagesArray = nil;//[NSArray arrayWithObjects:[UIImage imageNamed:@"em_alarm.png"],[UIImage imageNamed:@"em_alarm_d.png"],nil];
    //门铃
    imagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"doorbell_l.png"],[UIImage imageNamed:@"doorbell_m.png"],[UIImage imageNamed:@"doorbell_r.png"], nil];
    alarmview.frame = CGRectMake(width/2-ALARMVIEW_WIDTH_HEIGHT/4, 150, ALARMVIEW_WIDTH_HEIGHT/2, ALARMVIEW_WIDTH_HEIGHT/2);
    
    UIImageView * dbbackview = [[UIImageView alloc] initWithFrame:CGRectMake(40, CGRectGetMidY(alarmview.frame)-alarmview.frame.size.height/2, width-40*2, TOUCHBTNVIEW_WIDTH_HEIGHT)];
    dbbackview.contentMode = UIViewContentModeScaleAspectFit;
    NSArray * dbbackimgArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"alarm_doorbell_left1.png"],[UIImage imageNamed:@"alarm_doorbell_left2.png"],[UIImage imageNamed:@"alarm_doorbell_left3.png"], nil];
    dbbackview.animationImages = dbbackimgArray;
    dbbackview.animationDuration = ((CGFloat)[imagesArray count])*200.0f/1000.0f;
    dbbackview.animationRepeatCount = 0;
    [dbbackview startAnimating];
    [self.view addSubview:dbbackview];
    [dbbackview release];
    
    alarmview.animationImages = imagesArray;
    alarmview.animationDuration = ((CGFloat)[imagesArray count])*200.0f/1000.0f;
    alarmview.animationRepeatCount = 0;
    [alarmview startAnimating];
    [self.view addSubview:alarmview];
    [alarmview release];
    
    //报警类型。。。
    NSString* alarmTest = NSLocalizedString(@"somebody_visit", nil);
    labelSize = [alarmTest sizeWithFont:XFontBold_16];
    UILabel * typelabel = [[UILabel alloc] initWithFrame:CGRectMake((width-labelSize.width)/2, height-TOUCHBTNVIEW_WIDTH_HEIGHT-70, labelSize.width, labelSize.height)];
    typelabel.backgroundColor = [UIColor clearColor];
    typelabel.text = alarmTest;
    typelabel.font = XFontBold_16;
    typelabel.textColor = XWhite;
    typelabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:typelabel];
    [typelabel release];
    
    
    //红色x
    UIImageView * rejectview = [[UIImageView alloc] initWithFrame:CGRectMake(10, height-REJECTVIEW_WIDTH_HEIGHT-40, REJECTVIEW_WIDTH_HEIGHT, REJECTVIEW_WIDTH_HEIGHT)];
    rejectview.contentMode = UIViewContentModeScaleAspectFit;
    rejectview.image = [UIImage imageNamed:@"down_reject.png"];
    [self.view addSubview:rejectview];
    rejectview.hidden = NO;
    self.rejectview = rejectview;
    [rejectview release];
    
    //白色圈圈按钮
    UIImageView* touchbtnview = [[UIImageView alloc] initWithFrame:CGRectMake(width/2-TOUCHBTNVIEW_WIDTH_HEIGHT/2, rejectview.frame.origin.y+REJECTVIEW_WIDTH_HEIGHT/2-TOUCHBTNVIEW_WIDTH_HEIGHT/2, TOUCHBTNVIEW_WIDTH_HEIGHT, TOUCHBTNVIEW_WIDTH_HEIGHT)];
    touchbtnview.contentMode = UIViewContentModeScaleAspectFit;
    touchbtnview.image = [UIImage imageNamed:@"down_btn.png"];
    [self.view addSubview:touchbtnview];
    self.touchbtnview = touchbtnview;
    [touchbtnview release];
    
    self.touchbtnframe = self.touchbtnview.frame;
    dispatch_async(dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while (self.isshow) {
                while(self.isbreathe){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:0.75 animations:^{
                            self.touchbtnview.transform = CGAffineTransformMakeScale(0.6, 0.6);
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.75 animations:^{
                                self.touchbtnview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                            } completion:^(BOOL finished) {
                                
                            }];
                        }];
                    });
                    usleep(1000000);
                }
            }
        });
    });
    
    
    UIImageView * leftLineview = [[UIImageView alloc] initWithFrame:CGRectMake(10+REJECTVIEW_WIDTH_HEIGHT, rejectview.frame.origin.y, width/2-TOUCHBTNVIEW_WIDTH_HEIGHT/2-REJECTVIEW_WIDTH_HEIGHT-10, rejectview.frame.size.height)];
    leftLineview.contentMode = UIViewContentModeScaleAspectFit;
    NSArray * leftLineviewArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"point_right1.png"],[UIImage imageNamed:@"point_right2.png"],[UIImage imageNamed:@"point_right3.png"],[UIImage imageNamed:@"point_right4.png"],[UIImage imageNamed:@"point_right5.png"], nil];
    leftLineview.animationImages = leftLineviewArray;
    leftLineview.animationDuration = ((CGFloat)[leftLineviewArray count])*200.0f/1000.0f;
    leftLineview.animationRepeatCount = 0;
    [leftLineview startAnimating];
    [self.view addSubview:leftLineview];
    self.downlineview = leftLineview;
    [leftLineview release];
    self.touchlineframe = leftLineview.frame;
    
    UIImageView * rightLineview = [[UIImageView alloc] initWithFrame:CGRectMake(width/2-TOUCHBTNVIEW_WIDTH_HEIGHT/2+TOUCHBTNVIEW_WIDTH_HEIGHT, rejectview.frame.origin.y, width/2-TOUCHBTNVIEW_WIDTH_HEIGHT/2-REJECTVIEW_WIDTH_HEIGHT-10, rejectview.frame.size.height)];
    rightLineview.contentMode = UIViewContentModeScaleAspectFit;
    NSArray * rightLineviewArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"point_left1.png"],[UIImage imageNamed:@"point_left2.png"],[UIImage imageNamed:@"point_left3.png"],[UIImage imageNamed:@"point_left4.png"],[UIImage imageNamed:@"point_left5.png"], nil];
    rightLineview.animationImages = rightLineviewArray;
    rightLineview.animationDuration = ((CGFloat)[rightLineviewArray count])*200.0f/1000.0f;
    rightLineview.animationRepeatCount = 0;
    [rightLineview startAnimating];
    [self.view addSubview:rightLineview];
    [rightLineview release];
    
    
    UIImageView * acceptview = [[UIImageView alloc] initWithFrame:CGRectMake(width-10-REJECTVIEW_WIDTH_HEIGHT, rejectview.frame.origin.y, REJECTVIEW_WIDTH_HEIGHT, REJECTVIEW_WIDTH_HEIGHT)];
    acceptview.contentMode = UIViewContentModeScaleAspectFit;
    acceptview.image = [UIImage imageNamed:@"down_accept.png"];
    [self.view addSubview:acceptview];
    self.acceptview = acceptview;
    acceptview.hidden = NO;
    [acceptview release];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.touchbtnview.transform = CGAffineTransformMakeScale(1.0, 1.0);
    self.isbreathe = NO;
    self.iscanmove = NO;
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:self.view];
    int originx = self.touchbtnview.frame.origin.x;
    int originy = self.touchbtnview.frame.origin.y;
    int widthmax = CGRectGetMaxX(self.touchbtnview.frame);
    int heightmax = CGRectGetMaxY(self.touchbtnview.frame);
    if (point.x>originx&&point.x<widthmax&&point.y>originy&&point.y<heightmax) {
        self.downlineview.hidden = NO;
        self.rejectview.hidden = NO;
        self.acceptview.hidden = NO;
        self.touchbtnview.image = [UIImage imageNamed:@"down_btn_d.png"];
        self.iscanmove = YES;
    }
}

#pragma mark - 左滑、右滑
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:self.view];
    int heightmin = self.touchlineframe.origin.y;
    int heightmax = CGRectGetMaxY(self.touchlineframe);
    if (self.iscanmove) {
        if (point.y>=heightmin&&point.y<=heightmax) {
            self.touchbtnview.center = point;
        }
    }
    if (point.x<=CGRectGetMaxX(self.rejectview.frame)) {//左滑取消
        AppDelegate * appDdelegate = [AppDelegate sharedDefault];
        appDdelegate.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
//        appDdelegate.isShowAlarmTip = NO;
        MainController * mainController = [AppDelegate sharedDefault].mainController;
        appDdelegate.window.rootViewController = mainController;
        
//        NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
//        NSInteger intertime =  [manager integerForKey:@"Local alarm interval"];
        
//        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
//        NSString* text = nil;
//        if ([language isEqualToString:@"zh-Hans"])
//        {
//            text = [NSString stringWithFormat:@"%d秒内不弹出报警界面", intertime];
//        }
//        else if ([language isEqualToString:@"zh-Hant"])
//        {
//            text = [NSString stringWithFormat:@"%d秒內不彈出報警界面", intertime];
//        }
//        else if ([language isEqualToString:@"en"])
//        {
//            text = [NSString stringWithFormat:@"will no longer pop alarm page within %d seconds", intertime];
//        }
//        [mainController.view makeToast:text];//不显示
        //{{--kongyulu 20150918
        //停止播放铃声
        [[RingPlayer defaultRingPlayer] ringStop];
        //}}--kongyulu 20150918
        
    }
    if (point.x>=self.acceptview.frame.origin.x) {
        AppDelegate * appDdelegate = [AppDelegate sharedDefault];
        ContactDAO *contactDAO = [[ContactDAO alloc] init];
        Contact *contact = [contactDAO isContact:appDdelegate.alarmContactId];
        [contactDAO release];
        MainController * mainController = [AppDelegate sharedDefault].mainController;
        appDdelegate.window.rootViewController = mainController;
        //{{--kongyulu 20150918
        //停止播放铃声
        [[RingPlayer defaultRingPlayer] ringStop];
        //}}--kongyulu 20150918
        if(nil!=contact){
            appDdelegate.mainController.contactName = contact.contactName;//昵称显示不对
            [AppDelegate sharedDefault].contact = nil;
            appDdelegate.mainController.contact = contact;
            [appDdelegate.mainController setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
            appDdelegate.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
//            appDdelegate.isShowAlarmTip = NO;
        }else{
            UIAlertView *inputAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"input_device_password", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
            inputAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
            UITextField *passwordField = [inputAlert textFieldAtIndex:0];
            passwordField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            [inputAlert show];
            [inputAlert release];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    AppDelegate * appDdelegate = [AppDelegate sharedDefault];
    
    if(buttonIndex==1){//确定
        UITextField *passwordField = [alertView textFieldAtIndex:0];
        
        NSString *inputPwd = passwordField.text;
        if(!inputPwd||inputPwd.length==0){
            [appDdelegate.mainController.view makeToast:NSLocalizedString(@"input_device_password", nil)];
        }
        else
        {
            MainController *mainController = appDdelegate.mainController;
            mainController.contactName = self.contactId;
            
            Contact* contact = [[Contact alloc]init];
            contact.contactId = appDdelegate.alarmContactId;
            contact.contactName = appDdelegate.alarmContactId;
            contact.contactPassword = inputPwd;
            [AppDelegate sharedDefault].contact = contact;
            [AppDelegate sharedDefault].mainController.contact = nil;
            [[P2PClient sharedClient] getDefenceState:contact.contactId password:contact.contactPassword];
            [[P2PClient sharedClient] getContactsStates:[NSArray arrayWithObject:contact.contactId]];//在这为了获取设备类型,在监控界面区分门铃设备与其他设备
            [contact release];
            [appDdelegate.mainController setUpCallWithId:appDdelegate.alarmContactId password:inputPwd callType:P2PCALL_TYPE_MONITOR];
        }
    }
    appDdelegate.lastShowAlarmTimeInterval = [Utils getCurrentTimeInterval];
//    appDdelegate.isShowAlarmTip = NO;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    self.isbreathe = YES;
    self.downlineview.hidden = NO;
    self.rejectview.hidden = NO;
    self.acceptview.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.touchbtnview.frame = self.touchbtnframe;
    }];
    self.touchbtnview.image = [UIImage imageNamed:@"down_btn.png"];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.isbreathe = YES;
    self.downlineview.hidden = NO;
    self.rejectview.hidden = NO;
    self.acceptview.hidden = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.touchbtnview.frame = self.touchbtnframe;
    }];
    self.touchbtnview.image = [UIImage imageNamed:@"down_btn.png"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
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
