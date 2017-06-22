//
//  MoreController.m
//  Yoosee
//
//  Created by gwelltime on 15-1-16.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "MoreController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "UDManager.h"
#import "LoginResult.h"
#import "LoginController.h"
#import "P2PClient.h"
#import "AutoNavigation.h"
#import "CustomCell.h"
#import "QRCodeSetWIFIController.h"
#import "TopBar.h"
#import "FListManager.h"
#import "AccountController.h"
#import "GlobalThread.h"
#import "YLLabel.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

@interface MoreController ()

@end

@implementation MoreController
-(void)dealloc{
    //{{--kongyulu at 20150920
    self.ic_net_type_view = nil;
    //}}--kongyulu at 20150920
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetWorkChange:) name:NET_WORK_CHANGE object:nil];
    if([[AppDelegate sharedDefault] networkStatus]==ReachableViaWiFi){
        self.ic_net_type_view.image = [UIImage imageNamed:@"ic_net_type_wifi.png"];
    }else{
        self.ic_net_type_view.image = [UIImage imageNamed:@"ic_net_type_3g.png"];
    }
    
    //{{--kongyulu at 20150920
    [super viewDidAppear:animated];
    //}}--kongyulu at 20150920
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NET_WORK_CHANGE object:nil];
    
    //{{--kongyulu at 20150920
    [super viewWillDisappear:animated];
    //}}--kongyulu at 20150920
}

- (void)onNetWorkChange:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int status = [[parameter valueForKey:@"status"] intValue];
    if(status==ReachableViaWiFi){
        self.ic_net_type_view.image = [UIImage imageNamed:@"ic_net_type_wifi.png"];
    }else{
        self.ic_net_type_view.image = [UIImage imageNamed:@"ic_net_type_3g.png"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initComponent];
}

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    
    [mainController setBottomBarHidden:NO];
    
    //{{--kongyulu at 20150920
    [super viewWillAppear:animated];
    //}}--kongyulu at 20150920
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define SETTING_IC_HEAD_IMG_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80:50)
#define SETTING_IC_HEAD_IMG_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80:50)
-(void)initComponent{
    [self.view setBackgroundColor:XBgColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height-TAB_BAR_HEIGHT;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"more_item",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    //ic phone
    UIImageView *ic_phone_view = [[UIImageView alloc] initWithFrame:CGRectMake(10, NAVIGATION_BAR_HEIGHT+10, SETTING_IC_HEAD_IMG_WIDTH, SETTING_IC_HEAD_IMG_HEIGHT)];
    UIImage *ic_phone = [UIImage imageNamed:@"ic_setting_phone.png"];
    ic_phone_view.image = ic_phone;
    ic_phone_view.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:ic_phone_view];
    [ic_phone_view release];
    
    //current id
    UILabel *curIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(SETTING_IC_HEAD_IMG_WIDTH+20, NAVIGATION_BAR_HEIGHT+10, width-(SETTING_IC_HEAD_IMG_WIDTH+20)-(SETTING_IC_HEAD_IMG_WIDTH+10), SETTING_IC_HEAD_IMG_HEIGHT)];
    
    curIDLabel.textAlignment = NSTextAlignmentLeft;
    LoginResult *loginResult = [UDManager getLoginInfo];
    if([loginResult.contactId isEqual:@"0517400"]){
        curIDLabel.text = NSLocalizedString(@"anonymous", nil);
    }else{
        curIDLabel.text = loginResult.contactId;
    }
    
    
    curIDLabel.textColor = XBlack;
    curIDLabel.backgroundColor = XBGAlpha;
    [curIDLabel setFont:XFontBold_18];
    [self.view addSubview:curIDLabel];
    [curIDLabel release];
    
    
    //ic net type
    UIImageView *ic_net_type_view = [[UIImageView alloc] initWithFrame:CGRectMake(width-SETTING_IC_HEAD_IMG_WIDTH-10, NAVIGATION_BAR_HEIGHT+10, SETTING_IC_HEAD_IMG_WIDTH, SETTING_IC_HEAD_IMG_HEIGHT)];
    
    if([[AppDelegate sharedDefault] networkStatus]==ReachableViaWiFi){
        ic_net_type_view.image = [UIImage imageNamed:@"ic_net_type_wifi.png"];
    }else{
        ic_net_type_view.image = [UIImage imageNamed:@"ic_net_type_3g.png"];
    }
    
    
    ic_net_type_view.contentMode = UIViewContentModeScaleAspectFit;
    self.ic_net_type_view = ic_net_type_view;
    [self.view addSubview:self.ic_net_type_view];
    [ic_net_type_view release];
    
    UIImageView *sep_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+20+SETTING_IC_HEAD_IMG_HEIGHT, width, 1)];
    UIImage *sep = [UIImage imageNamed:@"separator_horizontal.png"];
    sep_view.image = sep;
    [self.view addSubview:sep_view];
    [sep_view release];
    
    //table
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+SETTING_IC_HEAD_IMG_HEIGHT+1+20, width, height-(NAVIGATION_BAR_HEIGHT+SETTING_IC_HEAD_IMG_HEIGHT+20+1)) style:UITableViewStyleGrouped];
    [tableView setBackgroundColor:XBGAlpha];
    tableView.backgroundView = nil;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView release];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        LoginResult *loginResult = [UDManager getLoginInfo];
        if([loginResult.contactId isEqual:@"0517400"]){
            return 1;
        }else{
            return 2;
        }
        
    }else if(section == 1){
        return 1;
    }else if (section == 2){
        return 1;
    }
    return 0;
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"SettingCell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        [cell setBackgroundColor:XBGAlpha];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UIImage *backImg = nil;
    UIImage *backImg_p = nil;

    [cell setRightIcon:@"ic_arrow.png"];
    
    
    switch (section) {
        case 0:
        {
            LoginResult *loginResult = [UDManager getLoginInfo];
            if([loginResult.contactId isEqual:@"0517400"]){
                if(row==0){
                    backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
                    [cell setLeftIcon:@"ic_setting_about.png"];
                    [cell setLabelText:NSLocalizedString(@"about_us", nil)];
//                    backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
//                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
//                    [cell setLeftIcon:@"ic_setting_update.png"];
//                    [cell setLabelText:NSLocalizedString(@"check_update", nil)];
                    
                }
//                else {
//                    backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
//                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
//                    [cell setLeftIcon:@"ic_setting_about.png"];
//                    [cell setLabelText:NSLocalizedString(@"about_us", nil)];
//                }
            }else{
                if(row==0){
                    backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                    [cell setLeftIcon:@"ic_setting_account.png"];
                    [cell setLabelText:NSLocalizedString(@"account_info", nil)];
                    
                }else if(row==1){
                    backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
                    [cell setLeftIcon:@"ic_setting_about.png"];
                    [cell setLabelText:NSLocalizedString(@"about_us", nil)];
//                    backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
//                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];
//                    [cell setLeftIcon:@"ic_setting_update.png"];
//                    [cell setLabelText:NSLocalizedString(@"check_update", nil)];
                }
//                else {
//                    backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
//                    backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
//                    [cell setLeftIcon:@"ic_setting_about.png"];
//                    [cell setLabelText:NSLocalizedString(@"about_us", nil)];
//                }
            }
            
        }
            break;
        case 1:
        {
            
            backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
            [cell setLeftIcon:@"ic_qr_code.png"];
            [cell setLabelText:NSLocalizedString(@"qrcode", nil)];
 
        }
            break;
        case 2:
        {
            backImg = [UIImage imageNamed:@"bg_bar_btn_single.png"];
            backImg_p = [UIImage imageNamed:@"bg_bar_btn_single_p.png"];
            
            [cell setLeftIcon:@"ic_setting_logout.png"];
            [cell setLabelText:NSLocalizedString(@"logout", nil)];
            
        }
            break;
    }
    
    
    
    UIImageView *backImageView = [[UIImageView alloc] init];
    
    //{{--kongyulu at 20150920
    if(backImg && [backImg isKindOfClass:[UIImage class]])
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backImageView.image = backImg;
    [cell setBackgroundView:backImageView];
    [backImageView release];
    
    UIImageView *backImageView_p = [[UIImageView alloc] init];
    
    if(backImg_p && [backImg_p isKindOfClass:[UIImage class]])
    backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.5 topCapHeight:backImg_p.size.height*0.5];
    backImageView_p.image = backImg_p;
    [cell setSelectedBackgroundView:backImageView_p];
    [backImageView_p release];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch(section){
        case 0:
        {
            
            LoginResult *loginResult = [UDManager getLoginInfo];
            if([loginResult.contactId isEqual:@"0517400"]){
                if(row==0){
//                    MBProgressHUD * hud = [[MBProgressHUD alloc]initWithView:self.view];
//                    hud.labelText = NSLocalizedString(@"loading", nil);
//                    [self.view addSubview:hud];
//                    hud.delegate  = self;
//                    [hud show:YES];
//                    
//                    
//                    
//                    NSString *urlString = [[NSString alloc] initWithFormat:@"http://itunes.apple.com/lookup?id=680995913"];
//                    NSURL *url = [[NSURL alloc] initWithString:urlString];
//                    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
//                    DLog(@"%@", urlString);
//                    
//                    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue ] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                        if ((!error)) {
//                            NSError *parseError;
//                            id appMetaDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
//                            if (appMetaDataDictionary) {
//                                NSArray *results = [appMetaDataDictionary objectForKey:@"results"];
//                                NSArray *remoteVersionArr = [results valueForKey:@"version"];
//                                [hud hide:YES];
//                                
//                                if([remoteVersionArr count]==0){
//                                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"latest_version", nil)
//                                                                                    message:nil
//                                                                                   delegate:self
//                                                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
//                                                                          otherButtonTitles:nil, nil];
//                                    [alert show];
//                                    [alert release];
//                                    return;
//                                }
//                                NSString *remoteVersion = [remoteVersionArr objectAtIndex:0];
//                                NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"];
//                                [hud hide:YES];
//                                
//                                
//                                
//                                UIAlertView *updataAlertDiag;
//                                
//                                if ( remoteVersion && ([localVersion floatValue]<[remoteVersion floatValue]) ) {
//                                    updataAlertDiag = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"release_new_version", nil)
//                                                                                 message:NSLocalizedString(@"ask_update_immediately", nil)
//                                                                                delegate:self
//                                                                       cancelButtonTitle:NSLocalizedString(@"remain_me", nil)
//                                                                       otherButtonTitles:NSLocalizedString(@"update_me", nil),NSLocalizedString(@"rate_me", nil), nil];
//                                } else {
//                                    updataAlertDiag = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"latest_version", nil)
//                                                                                 message:nil
//                                                                                delegate:nil
//                                                                       cancelButtonTitle:NSLocalizedString(@"ok", nil)
//                                                                       otherButtonTitles: nil];
//                                }
//                                [updataAlertDiag setTag:ALERT_TAG_UPDATE];
//                                [updataAlertDiag show];
//                                [updataAlertDiag release];
//                                [hud release];
//                            }
//                        }
//                        
//                    }];
                    
                    [self showAboutDialog];
                }
//                else if(row==1){
//                    [self showAboutDialog];
//                }
            }else{
                if(row==0){
                    AccountController *accountController = [[AccountController alloc] init];
                    [self.navigationController pushViewController:accountController animated:YES];
                    [accountController release];
                }else if(row==1){
//                    MBProgressHUD * hud = [[MBProgressHUD alloc]initWithView:self.view];
//                    hud.labelText = NSLocalizedString(@"loading", nil);
//                    [self.view addSubview:hud];
//                    hud.delegate  = self;
//                    [hud show:YES];
//                    
//                    
//                    
//                    NSString *urlString = [[NSString alloc] initWithFormat:@"http://itunes.apple.com/lookup?id=680995913"];
//                    NSURL *url = [[NSURL alloc] initWithString:urlString];
//                    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
//                    DLog(@"%@", urlString);
//                    
//                    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue ] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                        if ((!error)) {
//                            NSError *parseError;
//                            id appMetaDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
//                            if (appMetaDataDictionary) {
//                                NSArray *results = [appMetaDataDictionary objectForKey:@"results"];
//                                NSArray *remoteVersionArr = [results valueForKey:@"version"];
//                                [hud hide:YES];
//                                
//                                if([remoteVersionArr count]==0){
//                                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"latest_version", nil)
//                                                                                    message:nil
//                                                                                   delegate:self
//                                                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
//                                                                          otherButtonTitles:nil, nil];
//                                    [alert show];
//                                    [alert release];
//                                    return;
//                                }
//                                NSString *remoteVersion = [remoteVersionArr objectAtIndex:0];
//                                NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)@"CFBundleShortVersionString"];
//                                [hud hide:YES];
//                                
//                                
//                                UIAlertView *updataAlertDiag;
//                                
//                                if ( remoteVersion && ([localVersion floatValue]<[remoteVersion floatValue]) ) {
//                                    updataAlertDiag = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"release_new_version", nil)
//                                                                                 message:NSLocalizedString(@"ask_update_immediately", nil)
//                                                                                delegate:self
//                                                                       cancelButtonTitle:NSLocalizedString(@"remain_me", nil)
//                                                                       otherButtonTitles:NSLocalizedString(@"update_me", nil),NSLocalizedString(@"rate_me", nil), nil];
//                                } else {
//                                    updataAlertDiag = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"latest_version", nil)
//                                                                                 message:nil
//                                                                                delegate:nil
//                                                                       cancelButtonTitle:NSLocalizedString(@"ok", nil)
//                                                                       otherButtonTitles: nil];
//                                }
//                                [updataAlertDiag setTag:ALERT_TAG_UPDATE];
//                                [updataAlertDiag show];
//                                [updataAlertDiag release];
//                                [hud release];
//                            }
//                        }
//                        
//                    }];
                    
                    [self showAboutDialog];
                }
//                else if(row==2){
//                    [self showAboutDialog];
//                }
            }
            
        }
            break;
        case 1:
        {

            QRCodeSetWIFIController *qecodeController = [[QRCodeSetWIFIController alloc] init];
            [self.navigationController pushViewController:qecodeController animated:YES];
            [qecodeController release];
            
        }
            break;
        case 2:
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"logout_prompt", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
            alert.tag = ALERT_TAG_LOGOUT;
            [alert show];
            [alert release];
        }
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BAR_BUTTON_HEIGHT;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_EXIT:
        {
            if(buttonIndex==1){
                
            }
        }
            break;
        case ALERT_TAG_LOGOUT:
        {
            if(buttonIndex==1){
                [UDManager setIsLogin:NO];
                
                [[GlobalThread sharedThread:NO] kill];
                [[FListManager sharedFList] setIsReloadData:YES];
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
                LoginController *loginController = [[LoginController alloc] init];
                AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
                
                self.view.window.rootViewController = mainController;
                [loginController release];
                [mainController release];
                
                dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
                dispatch_async(queue, ^{
                    [[P2PClient sharedClient] p2pDisconnect];
                    DLog(@"p2pDisconnect.");
                });
                
            }
        }
            break;
        case ALERT_TAG_UPDATE:
        {
            if (buttonIndex==1) {
                NSString *iTunesUrl = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=680995913&mt=8"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesUrl]];
                DLog(@"%@", iTunesUrl);
            }else if (buttonIndex==2){
                NSString *iTunesUrl = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=680995913"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesUrl]];
                DLog(@"%@", iTunesUrl);
            }
        }
            break;
    }
}

#define CONNECT_VIEW_LEFT_RIGHT_MARGIN 20
#define CONNECT_VIEW_TITLE_HEIGHT 32

-(void)showAboutDialog{
    
    if(self.aboutView==nil){
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        UIView *view = [[UIView alloc] init];
        view.tag = 100;
        [view setBackgroundColor:XBlack_128];
        [view.layer setShadowOffset:CGSizeMake(1, 1)];
        [view.layer setShadowColor:[XBlack CGColor]];
        [view.layer setShadowOpacity:1.0];
        
        view.layer.cornerRadius = 5.0;
        [view setClipsToBounds:NO];
        CGFloat viewHeight = 0;
        if([language hasPrefix:@"zh"]){
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                viewHeight = 120;
            }else{
                viewHeight = 130;
            }
        }else{
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                viewHeight = 170;
            }else{
                viewHeight = 175;
            }
        }
        
        view.frame = CGRectMake(CONNECT_VIEW_LEFT_RIGHT_MARGIN, (self.view.frame.size.height-viewHeight)/2, self.view.frame.size.width-CONNECT_VIEW_LEFT_RIGHT_MARGIN*2, viewHeight);
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view.frame.size.width-10,CONNECT_VIEW_TITLE_HEIGHT)];
        
        title.textAlignment = NSTextAlignmentLeft;
        title.backgroundColor = XBGAlpha;
        title.textColor = XBlue;
        title.font = XFontBold_18;
        title.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"about", nil),APP_VERSION];
        
        [view addSubview:title];
        [title release];
        
        UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(0, CONNECT_VIEW_TITLE_HEIGHT, view.frame.size.width, 1)];
        [seperator setBackgroundColor:[UIColor grayColor]];
        [view addSubview:seperator];
        [seperator release];
        
        YLLabel *label = [[YLLabel alloc] initWithFrame:CGRectMake(0,CONNECT_VIEW_TITLE_HEIGHT+5,view.frame.size.width,view.frame.size.height-CONNECT_VIEW_TITLE_HEIGHT-10)];
        label.backgroundColor = XBGAlpha;
        label.textColor = XWhite;
        label.font = XFontBold_16;
        label.text = NSLocalizedString(@"about_text", nil);
        
        [view addSubview:label];
        
        UIView *layerView = [[UIView alloc] init];
        layerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        layerView.backgroundColor = XBGAlpha;
        [layerView addSubview:view];
        
        [self.view addSubview:layerView];
        
        
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAboutDialog)];
        [singleTap1 setNumberOfTapsRequired:1];
        [view addGestureRecognizer:singleTap1];
        
        UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAboutDialog)];
        [singleTap2 setNumberOfTapsRequired:1];
        [layerView addGestureRecognizer:singleTap2];
        
        
        [layerView release];
        [view release];
        [label release];
        
        
        self.aboutView = layerView;
        
        
    }
    
    
    [self.aboutView setHidden:NO];
    UIView *view = [self.aboutView viewWithTag:100];
    view.transform = CGAffineTransformMakeScale(1, 0.1);
    [UIView transitionWithView:view duration:0.1 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        CGAffineTransform transform1 = CGAffineTransformScale(view.transform, 1, 10);
                        view.transform = transform1;
                    }
                    completion:^(BOOL finished){
                        
                    }
     ];

}

-(void)hideAboutDialog{
    UIView *view = [self.aboutView viewWithTag:100];
    [UIView transitionWithView:view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        
                        CGAffineTransform transform1 = CGAffineTransformScale(view.transform, 1, 0.1);
                        view.transform = transform1;
                    }
                    completion:^(BOOL finished){
                        [self.aboutView setHidden:YES];
                    }
     ];
    
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
