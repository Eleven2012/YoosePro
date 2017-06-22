//
//  ChatController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-29.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ChatController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "TopBar.h"
#import "Contact.h"
#import "Message.h"
#import "MessageDAO.h"
#import "ChatCell.h"
#import "Utils.h"
#import "LoginResult.h"
#import "P2PClient.h"
#import "Toast+UIView.h"
#import "UDManager.h"
#import "FListManager.h"
@interface ChatController ()

@end

@implementation ChatController

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
    [self refreshMessage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessage) name:@"refreshMessage" object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshMessage" object:nil];
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

#define ITEM_HEIGHT 150
#define BOTTOM_HEIGHT 49
#define SEND_BUTTON_WIDTH 60

-(void)initComponent{
    
    [self.view setBackgroundColor:XBgColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setTitle:self.contact.contactName];
    [topBar setRightButtonIcon:[UIImage imageNamed:@"ic_bar_btn_clear.png"]];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.rightButton addTarget:self action:@selector(onClearPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    [topBar release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT-BOTTOM_HEIGHT) style:UITableViewStylePlain];
    [tableView setBackgroundColor:XBgColor];
    if(CURRENT_VERSION>=7.0){
        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }
    
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.frame.origin.y+self.tableView.frame.size.height, width, BOTTOM_HEIGHT)];
    bottomView.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    
    
    UITextField *messageField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, bottomView.frame.size.width-10*2-SEND_BUTTON_WIDTH-10, bottomView.frame.size.height-10*2)];
    if(CURRENT_VERSION>=7.0){
        messageField.layer.borderWidth = 1;
        messageField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        messageField.layer.cornerRadius = 5.0;
    }
    
    messageField.textAlignment = NSTextAlignmentLeft;
    
    messageField.borderStyle = UITextBorderStyleRoundedRect;
    messageField.returnKeyType = UIReturnKeyDone;
    messageField.placeholder = NSLocalizedString(@"input_message", nil);
    messageField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    messageField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [messageField addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [bottomView addSubview:messageField];
    self.messageField = messageField;
    [messageField release];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(bottomView.frame.size.width-10-SEND_BUTTON_WIDTH, 10, SEND_BUTTON_WIDTH, bottomView.frame.size.height-10*2);
    sendButton.layer.borderColor = [[UIColor grayColor] CGColor];
    sendButton.layer.borderWidth = 1;
    sendButton.layer.cornerRadius = 2.0;
    sendButton.backgroundColor = [UIColor whiteColor];
    UILabel *sendLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sendButton.frame.size.width, sendButton.frame.size.height)];
    sendLabel.textAlignment = NSTextAlignmentCenter;
    sendLabel.textColor = XBlack;
    sendLabel.backgroundColor = XBGAlpha;
    sendLabel.text = NSLocalizedString(@"send", nil);
    sendLabel.font = XFontBold_14;
    [sendButton addSubview:sendLabel];
    [sendLabel release];
    [sendButton addTarget:self action:@selector(onSendButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton addTarget:self action:@selector(lightButton:) forControlEvents:UIControlEventTouchDown];
    [sendButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchCancel];
    [sendButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
    [sendButton addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
    
    
    [bottomView addSubview:sendButton];
    
    [self.view addSubview:bottomView];
    [bottomView release];
    
    UIButton *hideKeyBoardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hideKeyBoardButton addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventTouchDown];
    
    hideKeyBoardButton.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-BOTTOM_HEIGHT);
    [self.view addSubview:hideKeyBoardButton];
    [hideKeyBoardButton setHidden:YES];
    self.hideKeyBoardButton = hideKeyBoardButton;
    
}

#pragma mark - 监听键盘
#pragma mark 键盘将要显示，调用
-(void)onKeyBoardWillShow:(NSNotification*)notification{
    DLog(@"onKeyBoardWillShow");
    
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    DLog(@"%f",rect.size.height);
    
    
    [self.hideKeyBoardButton setHidden:NO];
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, -rect.size.height);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

#pragma mark 键盘将要收起，调用
-(void)onKeyBoardWillHide:(NSNotification*)notification{
    DLog(@"onKeyBoardWillHide");
    [self.hideKeyBoardButton setHidden:YES];
    //NSDictionary *userInfo = [notification userInfo];
    //CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //DLog(@"%f",rect.size.height);
    
    [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
                    }
                    completion:^(BOOL finished) {
                        
                    }
     ];
}

-(void)onKeyBoardDown:(id)sender{
    [self.messageField resignFirstResponder];
}

-(void)onBackPress{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)lightButton:(UIView*)view{
    view.backgroundColor = XBlue;
}

-(void)normalButton:(UIView*)view{
    view.backgroundColor = XWhite;
}

-(void)onSendButtonPress:(UIButton*)button{
    [self normalButton:button];
    [self.messageField resignFirstResponder];
    NSString *messageStr = self.messageField.text;
    if(!messageStr||messageStr.length==0){
        [self.view makeToast:NSLocalizedString(@"input_message", nil)];
        return;
    }
    
    if(messageStr.length>1024){
        [self.view makeToast:NSLocalizedString(@"message_too_long", nil)];
        return;
    }
    LoginResult *loginResult = [UDManager getLoginInfo];
    
    if([self.contact.contactId isEqualToString:loginResult.contactId]){
        [self.view makeToast:NSLocalizedString(@"can_not_send_message_to_myself", nil)];
        return;
    }
    
    int result = [[P2PClient sharedClient] sendMessageToFriend:self.contact.contactId message:[NSString stringWithFormat:@"%@",messageStr]];
    
    if(result==-1){
        [self.view makeToast:NSLocalizedString(@"send_failure", nil)];
        return;
    }
        
    
    MessageDAO *messageDAO = [[MessageDAO alloc] init];
    Message *message = [[Message alloc] init];
    
    message.fromId = loginResult.contactId;
    message.toId = self.contact.contactId;
    message.message = [NSString stringWithFormat:@"%@",messageStr];
    message.state = MESSAGE_STATE_SENDING;
    message.time = [NSString stringWithFormat:@"%ld",[Utils getCurrentTimeInterval]];
    message.flag = result;
    [messageDAO insert:message];
    [message release];
    [messageDAO release];
    [self refreshMessage];
    
}

-(void)refreshMessage{
    [[FListManager sharedFList] setMessageCountWithId:self.contact.contactId count:0];
    MessageDAO *messageDAO = [[MessageDAO alloc] init];
    
    NSMutableArray *data = [messageDAO findAllWithId:self.contact.contactId];
    self.messages = [[[NSMutableArray alloc] initWithArray:data] autorelease];
    
    
    for(Message *message in self.messages){
        if(message.state==MESSAGE_STATE_NO_READ){
            message.state=MESSAGE_STATE_READED;
            [messageDAO update:message];
        }
        
        
    }
    [messageDAO release];
    if(self.tableView){
        [self.tableView reloadData];
    }
    
    
    if([self.messages count]>0){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
}

-(void)onClearPress{
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
                MessageDAO *messageDAO = [[MessageDAO alloc] init];
                [messageDAO clearWithId:self.contact.contactId];
                [messageDAO release];
                [self.messages removeAllObjects];
                [self.tableView reloadData];
            }
        }
            break;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.messages count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Message *message = [self.messages objectAtIndex:indexPath.row];
    CGFloat height = [Utils getStringHeightWithString:message.message font:XFontBold_16 maxWidth:150];
    if(height<ITEM_HEIGHT-60){
        return ITEM_HEIGHT;
    }else{
        return height+100;
    }
   
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ChatCell";
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    Message *message = [self.messages objectAtIndex:indexPath.row];
    DLog(@"%i:%i",message.flag,message.state);
    
    cell.message = message;
    
        
    UIImageView *backImageView = [[UIImageView alloc] init];
    UIImageView *backImageView_p = [[UIImageView alloc] init];
    backImageView.backgroundColor = XBgColor;
    backImageView_p.backgroundColor = XBgColor;
    [cell setBackgroundView:backImageView];
    [cell setSelectedBackgroundView:backImageView_p];
    [backImageView release];
    [backImageView_p release];
    
    return cell;
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
