//
//  LocalDeviceListController.m
//  Yoosee
//
//  Created by guojunyi on 14-7-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "LocalDeviceListController.h"
#import "TopBar.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "FListManager.h"
#import "LocalDeviceCell.h"
#import "LocalDevice.h"
#import "Contact.h"
#import "ContactDAO.h"
#import "AddContactNextController.h"
#import "CreateInitPasswordController.h"
@interface LocalDeviceListController ()

@end

@implementation LocalDeviceListController
-(void)dealloc{
    [self.tableView release];
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

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    [mainController setBottomBarHidden:YES];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLocalDevices) name:@"refreshLocalDevices" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshLocalDevices" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initComponent];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define LOCAL_DEVICE_ITEM_HEIGHT 68
-(void)initComponent{
    
    [self.view setBackgroundColor:XBgColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:NSLocalizedString(@"local_device_list",nil)];
    
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setBackgroundColor:XBgColor];
    if(CURRENT_VERSION>=7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshLocalDevices{
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[FListManager sharedFList] getLocalDevices] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return LOCAL_DEVICE_ITEM_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"LocalDeviceCell";
    LocalDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[LocalDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
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
    
    LocalDevice *localDevice = [[[FListManager sharedFList] getLocalDevices] objectAtIndex:indexPath.row];
    cell.rightImage = @"ic_local_device_add.png";
    cell.contentText = [NSString stringWithFormat:@"%@      %@",localDevice.contactId,localDevice.address];//显示设备ID、IP
    switch (localDevice.contactType) {
        case CONTACT_TYPE_IPC:
        {
            cell.leftImage = @"ic_contact_type_ipc.png";
        }
            break;
        case CONTACT_TYPE_NPC:
        {
            cell.leftImage = @"ic_contact_type_npc.png";
        }
            break;
        case CONTACT_TYPE_DOORBELL:
        {
            cell.leftImage = @"ic_contact_type_doorbell.png";
        }
            break;
        default:
        {
            cell.leftImage = @"ic_contact_type_unknown.png";
        }
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LocalDevice *localDevice = [[[FListManager sharedFList] getLocalDevices] objectAtIndex:indexPath.row];
    int contactFlag = localDevice.flag;
    if(contactFlag==1){
        //self.isNotNeedReloadData = YES;
        AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
        addContactNextController.isPopRoot = NO;//isPopRoot
        addContactNextController.isInFromLocalDeviceList = YES;
        [addContactNextController setContactId:localDevice.contactId];
        [self.navigationController pushViewController:addContactNextController animated:YES];
        [addContactNextController release];
        
    }else if(contactFlag==0){
        //self.isNotNeedReloadData = YES;
        CreateInitPasswordController *createInitPasswordController = [[CreateInitPasswordController alloc] init];
        createInitPasswordController.isPopRoot = NO;//isPopRoot
        [createInitPasswordController setContactId:localDevice.contactId];
        [createInitPasswordController setAddress:localDevice.address];
        [self.navigationController pushViewController:createInitPasswordController animated:YES];
        [createInitPasswordController release];
    }
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
