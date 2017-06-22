//
//  ContactController.m
//  Yoosee
//
//  Created by guojunyi on 14-3-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ContactController.h"
#import "NetManager.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "BottomBar.h"
#import "SVPullToRefresh.h"
#import "ContactCell.h"
#import "AddContactNextController.h"
#import "ContactDAO.h"
#import "Contact.h"
#import "FListManager.h"
#import "GlobalThread.h"
#import "MainSettingController.h"
#import "P2PPlaybackController.h"
#import "ChatController.h"
#import "LocalDeviceListController.h"
#import "TempContactCell.h"
#import "CreateInitPasswordController.h"
#import "PopoverTableViewController.h"
#import "LocalDevice.h"
#import "Toast+UIView.h"
#import "DXPopover.h"
#import "PopoverTableView.h"
#import "CustomCell.h"
#import "PopoverView.h"
#import "QRCodeController.h"
#import "UDManager.h"
#import "LoginResult.h"

@interface ContactController ()

@end

@implementation ContactController

-(void)dealloc{
    [self.contacts release];
    [self.selectedContact release];
    [self.tableView release];
    [self.curDelIndexPath release];
    [self.netStatusBar release];
    [self.localDevicesLabel release];
    [self.localDevicesView release];
    [self.emptyView release];
    [self.topBar release];
    [self.popover release];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (Contact *contact in [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]]) {//isGettingOnLineState
        contact.isGettingOnLineState = YES;
    }
    
    [self initComponent];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetWorkChange:) name:NET_WORK_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimating) name:@"updateContactState" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContact) name:@"refreshMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLocalDevices) name:@"refreshLocalDevices" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];//获取设备报警推送帐号个数
    
    if([[AppDelegate sharedDefault] networkStatus]==NotReachable){
        [self.netStatusBar setHidden:NO];
    }else{
        [self.netStatusBar setHidden:YES];
    }

    
    if(!self.isInitPull){
        [[GlobalThread sharedThread:NO] start];
        
        //[[FListManager sharedFList] searchLocalDevices];
        self.isInitPull = !self.isInitPull;
    }
    [[GlobalThread sharedThread:NO] setIsPause:NO];
    [self refreshLocalDevices];
    [self refreshContact];
}



- (void)onNetWorkChange:(NSNotification *)notification{

    
    NSDictionary *parameter = [notification userInfo];
    int status = [[parameter valueForKey:@"status"] intValue];
    if(status==NotReachable){
        [self.netStatusBar setHidden:NO];
    }else{
        NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
        for(int i=0;i<[self.contacts count];i++){
            
            Contact *contact = [self.contacts objectAtIndex:i];
            [contactIds addObject:contact.contactId];
        }
        [[P2PClient sharedClient] getContactsStates:contactIds];
        
        [self.netStatusBar setHidden:YES];
    }
    [self refreshLocalDevices];
}

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    [mainController setBottomBarHidden:NO];
}


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NET_WORK_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateContactState" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshLocalDevices" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];//获取设备报警推送帐号个数
    
    [[GlobalThread sharedThread:NO] setIsPause:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define CONTACT_ITEM_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 120:90)
#define NET_WARNING_ICON_WIDTH_HEIGHT 24
#define LOCAL_DEVICES_VIEW_HEIGHT 52
#define LOCAL_DEVICES_ARROW_WIDTH 24
#define LOCAL_DEVICES_ARROW_HEIGHT 16
#define EMPTY_BUTTON_WIDTH 148
#define EMPTY_BUTTON_HEIGHT 42
#define EMPTY_LABEL_WIDTH 260
#define EMPTY_LABEL_HEIGHT 50
-(void)initComponent{
 
    
    [self.view setBackgroundColor:XBgColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height-TAB_BAR_HEIGHT;
    
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"contact",nil)];
    [topBar setRightButtonHidden:NO];
    [topBar setRightButtonIcon:[UIImage imageNamed:@"ic_bar_btn_add_contact.png"]];
    [topBar.rightButton addTarget:self action:@selector(onAddPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    self.topBar = topBar;
    [topBar release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    [tableView setBackgroundColor:XBgColor];
    
    UIView *footView = [[UIView alloc] init];
    [footView setBackgroundColor:[UIColor clearColor]];
    [tableView setTableFooterView:footView];
    [footView release];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    if(CURRENT_VERSION>=7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }
    [tableView addPullToRefreshWithActionHandler:^{
        
        NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
        for(int i=0;i<[self.contacts count];i++){
            
            Contact *contact = [self.contacts objectAtIndex:i];
            [contactIds addObject:contact.contactId];
            
        }
        [[P2PClient sharedClient] getContactsStates:contactIds];
        [[FListManager sharedFList] getDefenceStates];
        [[FListManager sharedFList] searchLocalDevices];
    }];
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    
    UIView *netStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, 49)];
    netStatusBar.backgroundColor = [UIColor yellowColor];
    UIImageView *barLeftIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (netStatusBar.frame.size.height-NET_WARNING_ICON_WIDTH_HEIGHT)/2, NET_WARNING_ICON_WIDTH_HEIGHT, NET_WARNING_ICON_WIDTH_HEIGHT)];
    barLeftIconView.image = [UIImage imageNamed:@"ic_net_warning.png"];
    [netStatusBar addSubview:barLeftIconView];
    
    UILabel *barLabel = [[UILabel alloc] initWithFrame:CGRectMake(barLeftIconView.frame.origin.x+barLeftIconView.frame.size.width+10, 0, netStatusBar.frame.size.width-(barLeftIconView.frame.origin.x+barLeftIconView.frame.size.width)-10, netStatusBar.frame.size.height)];
    barLabel.textAlignment = NSTextAlignmentLeft;
    barLabel.textColor = [UIColor redColor];
    barLabel.backgroundColor = XBGAlpha;
    barLabel.font = XFontBold_16;
    barLabel.lineBreakMode = NSLineBreakByWordWrapping;
    barLabel.numberOfLines = 0;
    barLabel.text = NSLocalizedString(@"net_warning_prompt", nil);
    [netStatusBar addSubview:barLabel];
    
    [barLabel release];
    [barLeftIconView release];
    
    
    
    if([[AppDelegate sharedDefault] networkStatus]==NotReachable){
        [netStatusBar setHidden:NO];
    }else{
        [netStatusBar setHidden:YES];
    }
    
    self.netStatusBar = netStatusBar;
    
    [self.view addSubview:netStatusBar];
    [netStatusBar release];
    
    UIButton *localDevicesView = [UIButton buttonWithType:UIButtonTypeCustom];
    [localDevicesView addTarget:self action:@selector(onLocalButtonPress) forControlEvents:UIControlEventTouchUpInside];
    
    localDevicesView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, LOCAL_DEVICES_VIEW_HEIGHT);
    localDevicesView.backgroundColor = UIColorFromRGBA(0x5ab8ffff);
    [self.view addSubview:localDevicesView];
    self.localDevicesView = localDevicesView;
    
    UILabel *localDevicesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, localDevicesView.frame.size.width, localDevicesView.frame.size.height)];
    localDevicesLabel.backgroundColor = [UIColor clearColor];
    localDevicesLabel.textAlignment = NSTextAlignmentCenter;
    localDevicesLabel.textColor = XWhite;
    localDevicesLabel.font = XFontBold_16;
    [localDevicesView addSubview:localDevicesLabel];
    self.localDevicesLabel = localDevicesLabel;
    
    UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(localDevicesLabel.frame.size.width-LOCAL_DEVICES_ARROW_WIDTH, (localDevicesLabel.frame.size.height-LOCAL_DEVICES_ARROW_HEIGHT)/2, LOCAL_DEVICES_ARROW_WIDTH, LOCAL_DEVICES_ARROW_HEIGHT)];
    arrowView.image = [UIImage imageNamed:@"ic_local_devices_arrow.png"];
    [localDevicesLabel addSubview:arrowView];
    [arrowView release];
    [localDevicesLabel release];
    [localDevicesView setHidden:YES];
    [localDevicesView release];
    
    
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    
    UIButton *emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emptyButton addTarget:self action:@selector(onAddPress) forControlEvents:UIControlEventTouchUpInside];
    emptyButton.frame = CGRectMake((emptyView.frame.size.width-EMPTY_BUTTON_WIDTH)/2, (emptyView.frame.size.height-EMPTY_BUTTON_HEIGHT)/2, EMPTY_BUTTON_WIDTH, EMPTY_BUTTON_HEIGHT);
    UIImage *emptyButtonImage = [UIImage imageNamed:@"bg_blue_button.png"];
    UIImage *emptyButtonImage_p = [UIImage imageNamed:@"bg_blue_button_p.png"];
    emptyButtonImage = [emptyButtonImage stretchableImageWithLeftCapWidth:emptyButtonImage.size.width*0.5 topCapHeight:emptyButtonImage.size.height*0.5];
    emptyButtonImage_p = [emptyButtonImage_p stretchableImageWithLeftCapWidth:emptyButtonImage_p.size.width*0.5 topCapHeight:emptyButtonImage_p.size.height*0.5];
    [emptyButton setBackgroundImage:emptyButtonImage forState:UIControlStateNormal];
    [emptyButton setBackgroundImage:emptyButtonImage_p forState:UIControlStateHighlighted];
    [emptyButton setTitle:NSLocalizedString(@"add_device", nil) forState:UIControlStateNormal];
    //[emptyView addSubview:emptyButton]; 隐藏“添加设备”按钮
    
    [self.tableView addSubview:emptyView];
    self.emptyView = emptyView;
    [emptyView release];
    [self.emptyView setHidden:YES];
    
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.emptyView.frame.size.width-EMPTY_LABEL_WIDTH)/2, emptyButton.frame.origin.y-EMPTY_LABEL_HEIGHT, EMPTY_LABEL_WIDTH, EMPTY_LABEL_HEIGHT)];
    emptyLabel.backgroundColor = [UIColor clearColor];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor redColor];
    emptyLabel.numberOfLines = 0;
    emptyLabel.lineBreakMode = NSLineBreakByCharWrapping;
    emptyLabel.font = XFontBold_16;
    emptyLabel.text = NSLocalizedString(@"empty_contact_prompt", nil);
    [self.emptyView addSubview:emptyLabel];
    [emptyLabel release];
}


-(void)refreshContact{
    self.contacts = [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]];
    
    if(self.tableView){
        [self.tableView reloadData];
    }
}


-(void)refreshLocalDevices{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height-TAB_BAR_HEIGHT;
    
    NSArray *array = [[NSArray alloc] initWithArray:[[FListManager sharedFList] getLocalDevices]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if([array count]>0){
            UILabel *localDevicesLabel = [[self.localDevicesView subviews] objectAtIndex:0];
            localDevicesLabel.text = [NSString stringWithFormat:@"%@ %i %@",NSLocalizedString(@"discovered", nil),[array count],NSLocalizedString(@"new_device", nil)];
            if([self.netStatusBar isHidden]){
                self.localDevicesView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, LOCAL_DEVICES_VIEW_HEIGHT);
                self.tableView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT+LOCAL_DEVICES_VIEW_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT-LOCAL_DEVICES_VIEW_HEIGHT);
                self.tableViewOffset = self.localDevicesLabel.frame.size.height;
            }else{
                self.localDevicesView.frame = CGRectMake(0, self.netStatusBar.frame.origin.y+self.netStatusBar.frame.size.height, width, LOCAL_DEVICES_VIEW_HEIGHT);
                
                self.tableView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT+self.netStatusBar.frame.size.height+self.localDevicesView.frame.size.height, width, height-NAVIGATION_BAR_HEIGHT-self.netStatusBar.frame.size.height-self.localDevicesView.frame.size.height);
                self.tableViewOffset = self.netStatusBar.frame.size.height+self.netStatusBar.frame.size.height;
            }
            
            [self.localDevicesView setHidden:NO];
            
        }else{
            if([self.netStatusBar isHidden]){
                self.tableView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT);
                self.tableViewOffset = 0;
            }else{
                self.tableView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT+self.netStatusBar.frame.size.height, width, height-NAVIGATION_BAR_HEIGHT-self.netStatusBar.frame.size.height);
                self.tableViewOffset = self.netStatusBar.frame.size.height;
            }
            
            [self.localDevicesView setHidden:YES];
        }
    });
    
    self.localDevices = [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getUnsetPasswordLocalDevices]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // self.localDevices&&[self.localDevices count]>0//有 没有设置过密码的device
    if(0){//不显示没设置过密码的device
        [self.emptyView setHidden:YES];
        [self.tableView setScrollEnabled:YES];
        return 2;
    }else{
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        if([self.contacts count]<=0){
//            if(self.localDevices&&[self.localDevices count]>0){
//                [self.emptyView setHidden:YES];
//                [self.tableView setScrollEnabled:YES];
//            }else{
            [self.emptyView setHidden:NO];
            [self.tableView setScrollEnabled:NO];
//            }
            
        }else{
            [self.emptyView setHidden:YES];
            [self.tableView setScrollEnabled:YES];
        }
        return [self.contacts count];
    }else if(section==1){
        if(self.localDevices&&[self.localDevices count]>0){
            [self.emptyView setHidden:YES];
            [self.tableView setScrollEnabled:YES];
            return [self.localDevices count];
        }else{
            return 0;
        }
    }else{
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CONTACT_ITEM_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier1 = @"ContactCell1";
    static NSString *identifier2 = @"ContactCell2";
    UITableViewCell *cell = nil;
    if(indexPath.section==0){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(cell==nil){
            cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
        }
        
        Contact *contact = [self.contacts objectAtIndex:indexPath.row];
        
        ContactCell *contactCell = (ContactCell*)cell;
        contactCell.delegate = self;
        [contactCell setPosition:indexPath.row];
        [contactCell setContact:contact];
        
        //第一次或者删除后添加设备到设备列表时，若设备的状态是在线，则绑定报警推送帐号；
        //绑定成功，isDeviceBindedUserID为YES,不再绑定
        if (contact.onLineState == STATE_ONLINE && contact.contactType == CONTACT_TYPE_DOORBELL) {
            [self willBindUserIDByContactWithContactId:contact.contactId contactPassword:contact.contactPassword];
        }
        
    }else if(indexPath.section==1){
        cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        if(cell==nil){
            cell = [[TempContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2];
        }
        LocalDevice *localDevice = [self.localDevices objectAtIndex:indexPath.row];
        TempContactCell *tempContactCell = (TempContactCell*)cell;
        [tempContactCell setLocalDevice:localDevice];
    }
    
    
    
    
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

#pragma mark - 设备绑定报警推送帐号(user id)
-(void)willBindUserIDByContactWithContactId:(NSString *)contactId contactPassword:(NSString *)contactPassword{
    LoginResult *loginResult = [UDManager getLoginInfo];
    NSString *key = [NSString stringWithFormat:@"KEY%@_%@",loginResult.contactId,contactId];
    BOOL isDeviceBindedUserID = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (isDeviceBindedUserID) {
        return ;
    }
    [[P2PClient sharedClient] getBindAccountWithId:contactId password:contactPassword];//获取设备报警推送帐号个数
}

#pragma mark - 获取设备报警推送帐号个数
- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
        case RET_GET_BIND_ACCOUNT:
        {
            NSInteger maxCount = [[parameter valueForKey:@"maxCount"] integerValue];
            NSArray *datas = [parameter valueForKey:@"datas"];
            
            NSMutableArray *bindIds = [NSMutableArray arrayWithArray:datas];
    
            
            if (bindIds.count < maxCount) {
                LoginResult *loginResult = [UDManager getLoginInfo];
                if (bindIds.count>0){
                    if (![bindIds containsObject:[NSNumber numberWithInt:loginResult.contactId.intValue]]) {
                        [bindIds addObject:[NSNumber numberWithInt:loginResult.contactId.intValue]];
                    }
                }else{
                    [bindIds addObject:[NSNumber numberWithInt:loginResult.contactId.intValue]];
                }
                
                NSString *contactId = [parameter valueForKey:@"contactId"];
                ContactDAO *contactDAO = [[ContactDAO alloc] init];
                Contact *contact = [contactDAO isContact:contactId];
                [contactDAO release];
                [[P2PClient sharedClient] setBindAccountWithId:contactId password:contact.contactPassword datas:bindIds];
            }else{
                NSString *contactId = [parameter valueForKey:@"contactId"];
                LoginResult *loginResult = [UDManager getLoginInfo];
                NSString *key = [NSString stringWithFormat:@"KEY%@_%@",loginResult.contactId,contactId];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:[NSString stringWithFormat:@"%@%@%@ %i %@",NSLocalizedString(@"device", nil),contactId,NSLocalizedString(@"add_bind_account_prompt1", nil),maxCount,NSLocalizedString(@"add_bind_account_prompt2", nil)]];
                });
            }
        }
            break;
        case RET_SET_BIND_ACCOUNT:
        {
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            NSString *contactId = [parameter valueForKey:@"contactId"];
            
            if(result==0){//绑定成功，isDeviceBindedUserID为YES,不再绑定
                LoginResult *loginResult = [UDManager getLoginInfo];
                NSString *key = [NSString stringWithFormat:@"KEY%@_%@",loginResult.contactId,contactId];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
//                dispatch_async(dispatch_get_main_queue(), ^{
//
//                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
//                });
            }else{
//                dispatch_async(dispatch_get_main_queue(), ^{
//
//                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
//                });
            }
        }
            break;
    }
}

//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    if(section==1){
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
//        label.backgroundColor = UIColorFromRGB(0xeff0f2);
//        label.textAlignment = NSTextAlignmentCenter;
//        label.textColor = XBlue;
//        label.font = XFontBold_14;
//        label.text = NSLocalizedString(@"no_init_password_device", nil);
//        return label;
//    }else{
//        return nil;
//    }
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if(section==1){
//        return 30;
//    }else{
//        return 0;
//    }
//}


#define OPERATOR_ITEM_WIDTH (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80:55)
#define OPERATOR_ITEM_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60:48)
#define OPERATOR_ARROW_WIDTH_AND_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 20:10)
#define OPERATOR_BAR_OFFSET (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 40:30)

-(UIButton*)getOperatorView:(CGFloat)offset itemCount:(NSInteger)count{
    offset += self.tableViewOffset;
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    UIButton *operatorView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height-TAB_BAR_HEIGHT)];
    operatorView.tag = kOperatorViewTag;
    
    
    
    UIView *barView = [[UIView alloc] init];
    barView.tag = kBarViewTag;
    
    UIImageView *arrowView = [[UIImageView alloc] init];
    UIView *buttonsView = [[UIView alloc] init];
    buttonsView.tag = kButtonsViewTag;
    if((offset>self.tableView.frame.size.height)||((self.tableView.frame.size.height-offset)<CONTACT_ITEM_HEIGHT)){
        barView.frame = CGRectMake((width-OPERATOR_ITEM_WIDTH*count), offset-OPERATOR_BAR_OFFSET, OPERATOR_ITEM_WIDTH*count, OPERATOR_ITEM_HEIGHT+OPERATOR_ARROW_WIDTH_AND_HEIGHT);
        
        arrowView.frame = CGRectMake((OPERATOR_ITEM_WIDTH*count-OPERATOR_ARROW_WIDTH_AND_HEIGHT)/2, OPERATOR_ITEM_HEIGHT, OPERATOR_ARROW_WIDTH_AND_HEIGHT, OPERATOR_ARROW_WIDTH_AND_HEIGHT);
        
        
        buttonsView.frame = CGRectMake(0, 0, OPERATOR_ITEM_WIDTH*count, OPERATOR_ITEM_HEIGHT);
        [arrowView setImage:[UIImage imageNamed:@"bg_operator_bar_arrow_bottom.png"]];
        
    }else{
        barView.frame = CGRectMake((width-OPERATOR_ITEM_WIDTH*count), offset+OPERATOR_BAR_OFFSET, OPERATOR_ITEM_WIDTH*count, OPERATOR_ITEM_HEIGHT+OPERATOR_ARROW_WIDTH_AND_HEIGHT);
        
        
        arrowView.frame = CGRectMake((OPERATOR_ITEM_WIDTH*count-OPERATOR_ARROW_WIDTH_AND_HEIGHT)/2, 0, OPERATOR_ARROW_WIDTH_AND_HEIGHT, OPERATOR_ARROW_WIDTH_AND_HEIGHT);
        
        buttonsView.frame = CGRectMake(0, OPERATOR_ARROW_WIDTH_AND_HEIGHT, OPERATOR_ITEM_WIDTH*count, OPERATOR_ITEM_HEIGHT);
        [arrowView setImage:[UIImage imageNamed:@"bg_operator_bar_arrow_top.png"]];
    }
    
    
    
    
    
    buttonsView.layer.borderColor = [[UIColor grayColor] CGColor];
    buttonsView.layer.borderWidth = 1;
    buttonsView.layer.cornerRadius = 5;
    [buttonsView.layer setMasksToBounds:YES];
    
    
    
    [barView addSubview:arrowView];
    [barView addSubview:buttonsView];
    [operatorView addSubview:barView];
    [buttonsView release];
    [arrowView release];
    [barView release];
    //[operatorView release];
    return operatorView;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==0){
        ContactCell *cell = (ContactCell*)[tableView cellForRowAtIndexPath:indexPath];
        Contact *contact = cell.contact;
        self.selectedContact = contact;
        CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
        CGFloat width = rect.size.width;
        CGFloat offset = cell.frame.origin.y-tableView.contentOffset.y+CONTACT_ITEM_HEIGHT;
        int count = 1;
        switch(contact.contactType){
            case CONTACT_TYPE_PHONE:
            {
                count = 3;
            }
                break;
            case CONTACT_TYPE_NPC:
            {
                count = 4;
            }
                break;
            case CONTACT_TYPE_IPC:
            {
                count = 3;
            }
                break;
            case CONTACT_TYPE_DOORBELL:
            {
                count = 3;
            }
                break;
            default:
            {
                if(self.selectedContact.contactId.intValue<256){//IP添加设备
                    count = 3;//IP添加设备
                }else{
                    count = 1;
                }
            }
        }
        
        
        UIButton *operatorView = [self getOperatorView:offset itemCount:count];
        
        [operatorView addTarget:self action:@selector(onOperatorViewSingleTap) forControlEvents:UIControlEventTouchUpInside];
        UIView *barView = [operatorView viewWithTag:kBarViewTag];
        UIView *buttonsView = [barView viewWithTag:kButtonsViewTag];
        switch(contact.contactType){
            case CONTACT_TYPE_PHONE:
            {
                for(int i=0;i<count;i++){
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(i*OPERATOR_ITEM_WIDTH, 0, OPERATOR_ITEM_WIDTH, OPERATOR_ITEM_HEIGHT);
                    [button setBackgroundColor:XBlack_128];
                    [button setBackgroundImage:[UIImage imageNamed:@"bg_normal_cell_p.png"] forState:UIControlStateHighlighted];
                    
                    [button addTarget:self action:@selector(onOperatorItemPress:) forControlEvents:UIControlEventTouchUpInside];
                    
                    if(i==0){
                        button.tag = kOperatorBtnTag_Chat;
                        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                        iconView.image = [UIImage imageNamed:@"ic_operator_item_chat.png"];
                        [button addSubview:iconView];
                        [iconView release];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                        label.textAlignment = NSTextAlignmentCenter;
                        label.textColor = XWhite;
                        label.backgroundColor = XBGAlpha;
                        [label setFont:XFontBold_12];
                        label.text = NSLocalizedString(@"chat", nil);
                        [button addSubview: label];
                        [label release];
                    }else if(i==1){
                        button.tag = kOperatorBtnTag_Message;
                        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                        iconView.image = [UIImage imageNamed:@"ic_operator_item_message.png"];
                        [button addSubview:iconView];
                        [iconView release];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                        label.textAlignment = NSTextAlignmentCenter;
                        label.textColor = XWhite;
                        label.backgroundColor = XBGAlpha;
                        [label setFont:XFontBold_12];
                        label.text = NSLocalizedString(@"message", nil);
                        [button addSubview: label];
                        [label release];
                    }else if(i==2){
                        button.tag = kOperatorBtnTag_Modify;
                        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                        iconView.image = [UIImage imageNamed:@"ic_operator_item_modify.png"];
                        [button addSubview:iconView];
                        [iconView release];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                        label.textAlignment = NSTextAlignmentCenter;
                        label.textColor = XWhite;
                        label.backgroundColor = XBGAlpha;
                        [label setFont:XFontBold_12];
                        label.text = NSLocalizedString(@"modify", nil);
                        [button addSubview: label];
                        [label release];
                    }
                    
                    
                    [buttonsView addSubview:button];
                }
            }
                break;
            case CONTACT_TYPE_NPC:
            {
                NSMutableArray * arr = [NSMutableArray arrayWithArray:[[FListManager sharedFList] getUnsetPasswordDevices]];
                for (LocalDevice *localDevic in arr) {
                    
                    if ([localDevic.contactId isEqualToString:self.selectedContact.contactId]) {
                        CreateInitPasswordController * createInitPwdCtl = [[CreateInitPasswordController alloc] init];
                        createInitPwdCtl.contactId = self.selectedContact.contactId;
                        createInitPwdCtl.address = localDevic.address;
                        [self.navigationController pushViewController:createInitPwdCtl animated:YES];
                        [createInitPwdCtl release];
                        return;
                    }
                }
                for(int i=0;i<count;i++){
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(i*OPERATOR_ITEM_WIDTH, 0, OPERATOR_ITEM_WIDTH, OPERATOR_ITEM_HEIGHT);
                    [button setBackgroundColor:XBlack_128];
                    [button setBackgroundImage:[UIImage imageNamed:@"bg_normal_cell_p.png"] forState:UIControlStateHighlighted];
                    
                    [button addTarget:self action:@selector(onOperatorItemPress:) forControlEvents:UIControlEventTouchUpInside];
                    
                    /*if(i==0){
                     button.tag = kOperatorBtnTag_Monitor;
                     UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                     iconView.image = [UIImage imageNamed:@"ic_operator_item_monitor.png"];
                     [button addSubview:iconView];
                     [iconView release];
                     
                     UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                     label.textAlignment = NSTextAlignmentCenter;
                     label.textColor = XWhite;
                     label.backgroundColor = XBGAlpha;
                     [label setFont:XFontBold_12];
                     label.text = NSLocalizedString(@"monitor", nil);
                     [button addSubview: label];
                     [label release];
                     }else*/ if(i==0){
                         button.tag = kOperatorBtnTag_Chat;
                         UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                         iconView.image = [UIImage imageNamed:@"ic_operator_item_chat.png"];
                         [button addSubview:iconView];
                         [iconView release];
                         
                         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                         label.textAlignment = NSTextAlignmentCenter;
                         label.textColor = XWhite;
                         label.backgroundColor = XBGAlpha;
                         [label setFont:XFontBold_12];
                         label.text = NSLocalizedString(@"chat", nil);
                         [button addSubview: label];
                         [label release];
                     }else if(i==1){
                         button.tag = kOperatorBtnTag_Playback;
                         UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                         iconView.image = [UIImage imageNamed:@"ic_operator_item_playback.png"];
                         [button addSubview:iconView];
                         [iconView release];
                         
                         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                         label.textAlignment = NSTextAlignmentCenter;
                         label.textColor = XWhite;
                         label.backgroundColor = XBGAlpha;
                         [label setFont:XFontBold_12];
                         label.text = NSLocalizedString(@"playback", nil);
                         [button addSubview: label];
                         [label release];
                     }else if(i==2){
                         button.tag = kOperatorBtnTag_Control;
                         UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                         iconView.image = [UIImage imageNamed:@"ic_operator_item_control.png"];
                         [button addSubview:iconView];
                         [iconView release];
                         
                         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                         label.textAlignment = NSTextAlignmentCenter;
                         label.textColor = XWhite;
                         label.backgroundColor = XBGAlpha;
                         [label setFont:XFontBold_12];
                         label.text = NSLocalizedString(@"control", nil);
                         [button addSubview: label];
                         [label release];
                     }else if(i==3){
                         button.tag = kOperatorBtnTag_Modify;
                         UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                         iconView.image = [UIImage imageNamed:@"ic_operator_item_modify.png"];
                         [button addSubview:iconView];
                         [iconView release];
                         
                         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                         label.textAlignment = NSTextAlignmentCenter;
                         label.textColor = XWhite;
                         label.backgroundColor = XBGAlpha;
                         [label setFont:XFontBold_12];
                         label.text = NSLocalizedString(@"modify", nil);
                         [button addSubview: label];
                         [label release];
                     }
                    
                    
                    [buttonsView addSubview:button];
                }
            }
                break;
            case CONTACT_TYPE_DOORBELL:
            case CONTACT_TYPE_IPC:
            {
                NSMutableArray * arr = [NSMutableArray arrayWithArray:[[FListManager sharedFList] getUnsetPasswordDevices]];
                for (LocalDevice *localDevic in arr) {
                    
                    if ([localDevic.contactId isEqualToString:self.selectedContact.contactId]) {
                        CreateInitPasswordController * createInitPwdCtl = [[CreateInitPasswordController alloc] init];
                        createInitPwdCtl.contactId = self.selectedContact.contactId;
                        createInitPwdCtl.address = localDevic.address;
                        [self.navigationController pushViewController:createInitPwdCtl animated:YES];
                        [createInitPwdCtl release];
                        return;
                    }
                }
                for(int i=0;i<count;i++){
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(i*OPERATOR_ITEM_WIDTH, 0, OPERATOR_ITEM_WIDTH, OPERATOR_ITEM_HEIGHT);
                    [button setBackgroundColor:XBlack_128];
                    [button setBackgroundImage:[UIImage imageNamed:@"bg_normal_cell_p.png"] forState:UIControlStateHighlighted];
                    
                    [button addTarget:self action:@selector(onOperatorItemPress:) forControlEvents:UIControlEventTouchUpInside];
                    
                    /*if(i==0){
                     button.tag = kOperatorBtnTag_Monitor;
                     UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                     iconView.image = [UIImage imageNamed:@"ic_operator_item_monitor.png"];
                     [button addSubview:iconView];
                     [iconView release];
                     
                     UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                     label.textAlignment = NSTextAlignmentCenter;
                     label.textColor = XWhite;
                     label.backgroundColor = XBGAlpha;
                     [label setFont:XFontBold_12];
                     label.text = NSLocalizedString(@"monitor", nil);
                     [button addSubview: label];
                     [label release];
                     }else*/ if(i==0){
                         button.tag = kOperatorBtnTag_Playback;
                         UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                         iconView.image = [UIImage imageNamed:@"ic_operator_item_playback.png"];
                         [button addSubview:iconView];
                         [iconView release];
                         
                         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                         label.textAlignment = NSTextAlignmentCenter;
                         label.textColor = XWhite;
                         label.backgroundColor = XBGAlpha;
                         [label setFont:XFontBold_12];
                         label.text = NSLocalizedString(@"playback", nil);
                         [button addSubview: label];
                         [label release];
                     }else if(i==1){
                         button.tag = kOperatorBtnTag_Control;
                         UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                         iconView.image = [UIImage imageNamed:@"ic_operator_item_control.png"];
                         [button addSubview:iconView];
                         [iconView release];
                         
                         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                         label.textAlignment = NSTextAlignmentCenter;
                         label.textColor = XWhite;
                         label.backgroundColor = XBGAlpha;
                         [label setFont:XFontBold_12];
                         label.text = NSLocalizedString(@"control", nil);
                         [button addSubview: label];
                         [label release];
                     }else if(i==2){
                         button.tag = kOperatorBtnTag_Modify;
                         UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                         iconView.image = [UIImage imageNamed:@"ic_operator_item_modify.png"];
                         [button addSubview:iconView];
                         [iconView release];
                         
                         UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                         label.textAlignment = NSTextAlignmentCenter;
                         label.textColor = XWhite;
                         label.backgroundColor = XBGAlpha;
                         [label setFont:XFontBold_12];
                         label.text = NSLocalizedString(@"modify", nil);
                         [button addSubview: label];
                         [label release];
                     }
                    
                    
                    [buttonsView addSubview:button];
                }
            }
                break;
                
            default:
            {
                for(int i=0;i<count;i++){
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(i*OPERATOR_ITEM_WIDTH, 0, OPERATOR_ITEM_WIDTH, OPERATOR_ITEM_HEIGHT);
                    [button setBackgroundColor:XBlack_128];
                    [button setBackgroundImage:[UIImage imageNamed:@"bg_normal_cell_p.png"] forState:UIControlStateHighlighted];
                    
                    [button addTarget:self action:@selector(onOperatorItemPress:) forControlEvents:UIControlEventTouchUpInside];
                    
                    if(count==1){
                        if(i==0){
                            button.tag = kOperatorBtnTag_Modify;
                            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                            iconView.image = [UIImage imageNamed:@"ic_operator_item_modify.png"];
                            [button addSubview:iconView];
                            [iconView release];
                            
                            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                            label.textAlignment = NSTextAlignmentCenter;
                            label.textColor = XWhite;
                            label.backgroundColor = XBGAlpha;
                            [label setFont:XFontBold_12];
                            label.text = NSLocalizedString(@"modify", nil);
                            [button addSubview: label];
                            [label release];
                        }
                    }else if (count==3){//IP添加设备
                        if(i==0){//IP添加设备
                            button.tag = kOperatorBtnTag_Playback;
                            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                            iconView.image = [UIImage imageNamed:@"ic_operator_item_playback.png"];
                            [button addSubview:iconView];
                            [iconView release];
                            
                            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                            label.textAlignment = NSTextAlignmentCenter;
                            label.textColor = XWhite;
                            label.backgroundColor = XBGAlpha;
                            [label setFont:XFontBold_12];
                            label.text = NSLocalizedString(@"playback", nil);
                            [button addSubview: label];
                            [label release];
                        }else if(i==1){//IP添加设备
                            button.tag = kOperatorBtnTag_Control;
                            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                            iconView.image = [UIImage imageNamed:@"ic_operator_item_control.png"];
                            [button addSubview:iconView];
                            [iconView release];
                            
                            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                            label.textAlignment = NSTextAlignmentCenter;
                            label.textColor = XWhite;
                            label.backgroundColor = XBGAlpha;
                            [label setFont:XFontBold_12];
                            label.text = NSLocalizedString(@"control", nil);
                            [button addSubview: label];
                            [label release];
                        }else if(i==2){//IP添加设备
                            button.tag = kOperatorBtnTag_Modify;
                            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((button.frame.size.width-button.frame.size.height*4/7)/2, 0, button.frame.size.height*4/7, button.frame.size.height*4/7)];
                            iconView.image = [UIImage imageNamed:@"ic_operator_item_modify.png"];
                            [button addSubview:iconView];
                            [iconView release];
                            
                            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.frame.size.height*4/7, button.frame.size.width, button.frame.size.height*3/7-5)];
                            label.textAlignment = NSTextAlignmentCenter;
                            label.textColor = XWhite;
                            label.backgroundColor = XBGAlpha;
                            [label setFont:XFontBold_12];
                            label.text = NSLocalizedString(@"modify", nil);
                            [button addSubview: label];
                            [label release];
                            
                        }
                        
                    }
                    
                    [buttonsView addSubview:button];
                }
            }
        }
        barView.alpha = 0;
        [UIView transitionWithView:barView duration:0.1 options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            
                            CGAffineTransform transform1 = CGAffineTransformMakeTranslation(-(width-OPERATOR_ITEM_WIDTH*count), 0);
                            barView.alpha = 0.5;
                            barView.transform = transform1;
                        }
                        completion:^(BOOL finished){
                            [UIView transitionWithView:barView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                                            animations:^{
                                                
                                                
                                                CGAffineTransform transform2 = CGAffineTransformMakeTranslation(-(width-OPERATOR_ITEM_WIDTH*count)/2, 0);
                                                barView.transform = transform2;
                                                barView.alpha = 1;
                                            }
                                            completion:^(BOOL finished){
                                                
                                            }
                             ];
                        }
         ];
        [self.view addSubview:operatorView];
        [operatorView release];
    }else{
        LocalDevice *localDevice = [self.localDevices objectAtIndex:indexPath.row];
        CreateInitPasswordController *createInitPasswordController = [[CreateInitPasswordController alloc] init];
        createInitPasswordController.isPopRoot = YES;
        [createInitPasswordController setAddress:localDevice.address];
        [createInitPasswordController setContactId:localDevice.contactId];
        [self.navigationController pushViewController:createInitPasswordController animated:YES];
        [createInitPasswordController release];
    }
    
}

-(void)onOperatorViewSingleTap{
    UIView *operatorView = [self.view viewWithTag:kOperatorViewTag];
    UIView *barView = [operatorView viewWithTag:kBarViewTag];
    [UIView transitionWithView:barView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
        animations:^{
            barView.alpha = 0.3;

        }
        completion:^(BOOL finished){
            [operatorView removeFromSuperview];
        }
     ];
    
}

-(void)onOperatorItemPress:(id)sender{
    UIView *operatorView = [self.view viewWithTag:kOperatorViewTag];
    UIView *barView = [operatorView viewWithTag:kBarViewTag];
    [UIView transitionWithView:barView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        barView.alpha = 0.3;
                        
                    }
                    completion:^(BOOL finished){
                        [operatorView removeFromSuperview];
                        UIButton *button = (UIButton*)sender;
                        switch(button.tag){
                            case kOperatorBtnTag_Modify:
                            {
                                AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
                                addContactNextController.inType = 0;
                                addContactNextController.isModifyContact = YES;
                                addContactNextController.contactId = self.selectedContact.contactId;
                                addContactNextController.modifyContact = self.selectedContact;
                                [self.navigationController pushViewController:addContactNextController animated:YES];
                                [addContactNextController release];
                                
                                
                            }
                                break;
                            case kOperatorBtnTag_Message:
                            {
                                ChatController *chatController = [[ChatController alloc] init];
                                
                                chatController.contact = self.selectedContact;
                                
                                [self.navigationController pushViewController:chatController animated:YES];
                                [chatController release];
                                
                                
                            }
                                break;
                            case kOperatorBtnTag_Monitor:
                            {
                                MainController *mainController = [AppDelegate sharedDefault].mainController;
                                [mainController setUpCallWithId:self.selectedContact.contactId password:self.selectedContact.contactPassword callType:P2PCALL_TYPE_MONITOR];
                            }
                                break;
                            case kOperatorBtnTag_Chat:
                            {
                                MainController *mainController = [AppDelegate sharedDefault].mainController;
                                [mainController setUpCallWithId:self.selectedContact.contactId password:@"0" callType:P2PCALL_TYPE_VIDEO];
                            }
                                break;
                            case kOperatorBtnTag_Playback:
                            {
                                if (self.selectedContact.defenceState==DEFENCE_STATE_NO_PERMISSION) {
                                    [self.view makeToast:NSLocalizedString(@"no_permission", nil)];
                                }else{
                                P2PPlaybackController *playbackController = [[P2PPlaybackController alloc] init];
                                playbackController.contact = self.selectedContact;
                                [self.navigationController pushViewController:playbackController animated:YES];
                                [playbackController release];
                                    
                                }
                            }
                                
                                break;
                            case kOperatorBtnTag_Control:
                            {
                                if (self.selectedContact.defenceState==DEFENCE_STATE_NO_PERMISSION) {
                                    [self.view makeToast:NSLocalizedString(@"no_permission", nil)];
                                }else{
                                    MainSettingController *mainSettingController = [[MainSettingController alloc] init];
                                    mainSettingController.contact = self.selectedContact;
                                    [self.navigationController pushViewController:mainSettingController animated:YES];
                                    [mainSettingController release];
                                    
                                }
                                
                            }
                                break;
                        }
                    }
     ];
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return YES;
    }else{
        return NO;
    }

}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    self.curDelIndexPath = indexPath;
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"sure_to_delete", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
    deleteAlert.tag = ALERT_TAG_DELETE;
    [deleteAlert show];
    [deleteAlert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(alertView.tag){
        case ALERT_TAG_DELETE:
        {
            if(buttonIndex==1){
                Contact *contact = [self.contacts objectAtIndex:self.curDelIndexPath.row];
                LoginResult *loginResult = [UDManager getLoginInfo];
                NSString *key = [NSString stringWithFormat:@"KEY%@_%@",loginResult.contactId,contact.contactId];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[FListManager sharedFList] delete:[self.contacts objectAtIndex:self.curDelIndexPath.row]];
                [self.contacts removeObjectAtIndex:self.curDelIndexPath.row];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.curDelIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
            }
        }
            break;
    }
}

-(void) onAddPress{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        PopoverTableViewController *popoverTableViewController = [[PopoverTableViewController alloc] init];
        popoverTableViewController.navigationController = self.navigationController;
        
        //内存泄漏
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverTableViewController];
        popoverController.popoverContentSize = CGSizeMake(200, 136);
        [popoverController presentPopoverFromRect:CGRectMake(self.topBar.rightButton.frame.size.width/2.0, self.topBar.rightButton.frame.size.height, 5, 5) inView:self.topBar.rightButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        popoverTableViewController.popover = popoverController;
        
        [popoverTableViewController release];
        //[popoverController release];//加此句会崩溃,??
        
//        UIImage *image = [UIImage imageNamed:@"popover_background_image.png"];
//        PopoverView *popoverView = [[PopoverView alloc] init];
//        popoverView.frame = CGRectMake(0, 0, 160, 160*(image.size.height/image.size.width));
//        popoverView.delegate = self;
//        popoverView.backgroundImage = image;
//        
//        DXPopover *popover = [DXPopover popover];
//        self.popover = popover;
//        popover.arrowSize = CGSizeMake(0.0, 0.0);
//        [popover showAtView:self.topBar.rightButton withContentView:popoverView];
//        
//        [popoverView release];
    }else{
//        PopoverTableView *popoverTableView = [[PopoverTableView alloc] initWithFrame:CGRectMake(0, 0, 160, 90)];
//        popoverTableView.navigationController = self.navigationController;
//        
//        DXPopover *popover = [DXPopover popover];
//        popover.cornerRadius = 12.0;
//        popover.arrowSize = CGSizeMake(10.0, 10.0);
//        [popover showAtView:self.topBar.rightButton withContentView:popoverTableView];
//        
//        popoverTableView.popover = popover;
//        [popoverTableView release];
        
        UIImage *image = [UIImage imageNamed:@"popover_background_image.png"];
        PopoverView *popoverView = [[PopoverView alloc] init];
        popoverView.frame = CGRectMake(0, 0, 160, 160*(image.size.height/image.size.width));
        popoverView.delegate = self;
        popoverView.backgroundImage = image;
        
        DXPopover *popover = [DXPopover popover];
        self.popover = popover;
        popover.arrowSize = CGSizeMake(0.0, 0.0);
        [popover showAtView:self.topBar.rightButton withContentView:popoverView];
        
        [popoverView release];
    }
}

-(void)didSelectedPopoverViewRow:(NSInteger)row{
    [self.popover dismiss];//去掉泡沫
    if (row == 1) {
        QRCodeController *qecodeController = [[QRCodeController alloc] init];
        
        [self.navigationController pushViewController:qecodeController animated:YES];
        [qecodeController release];
    }else{
        AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
        addContactNextController.inType = 1;
        addContactNextController.isInFromManuallAdd = YES;
        [self.navigationController pushViewController:addContactNextController animated:YES];
        [addContactNextController release];
    }
}

-(void)onLocalButtonPress{
    LocalDeviceListController *localDeviceListController = [[LocalDeviceListController alloc] init];
    [self.navigationController pushViewController:localDeviceListController animated:YES];
    [localDeviceListController release];
}

-(void)stopAnimating{
    DLog(@"stopAnimating");
    
    self.contacts = [[NSMutableArray alloc] initWithArray:[[FListManager sharedFList] getContacts]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1.0);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [self.tableView.pullToRefreshView stopAnimating];
            [self.tableView reloadData];
        });
    });
    

}

-(void)onClick:(NSInteger)position contact:(Contact *)contact{
    [AppDelegate sharedDefault].isDoorBellAlarm = NO;
    
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    mainController.contactName = contact.contactName;
    mainController.contact = contact;//重新调整监控画面
    [mainController setUpCallWithId:contact.contactId password:contact.contactPassword callType:P2PCALL_TYPE_MONITOR];
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
