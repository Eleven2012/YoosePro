//
//  BindAlarmEmailController.m
//  Yoosee
//
//  Created by guojunyi on 14-5-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "BindAlarmEmailController.h"
#import "Constants.h"
#import "Contact.h"
#import "TopBar.h"
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "AlarmSettingController.h"
#import "UITableView+DataSourceBlocks.h"
#import "TableViewWithBlock.h"

@interface BindAlarmEmailController ()

@end

@implementation BindAlarmEmailController

-(void)dealloc{
    [self.alarmSettingController release];
    [self.lastSetBindEmail release];
    [self.contact release];
    [self.progressAlert release];
    [self.field1 release];//delete
    [self.smtpTextField release];
    [self.senderTextField release];
    [self.reciTextField release];
    [self.pwdTextField release];
    [self.dropDownBtn release];
    [self.selectBtn release];
    [self.emailArray release];
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

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //write code here...
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.senderTextField];
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRemoteMessage:) name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ack_receiveRemoteMessage:) name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.senderTextField];//监听发件人编辑框
    
}

-(void)btnClickToTest:(UIButton *)button{//delete
    //模拟测试，获取发件人邮箱
    //获取发件人邮箱的结果：1.没有获取到；2.获取到的是默认邮箱；3.获取到的是非默认邮箱
    
#if 0
    //1.没有获取到,“请选择邮箱”状态:
    //发件人、密码、收件人正常显示；
    //邮局类型显示为“请选择邮箱”,并使用一个变量来记录当前是“请选择邮箱”状态,控制勾选按钮
    //勾选按钮为不可点击
    self.isSelectEmailState = YES;
#endif
    
    
#if 0
    //2.获取到的是默认邮箱:
    //邮局类型显示为“系统默认邮箱”
    //此时，发件人、密码都不可编辑、字体变灰色，内容清空
    //勾选框也不可以勾选
    self.isSystemDefaultEmail = YES;
    self.smtpTextField.text = self.emailArray[5];
    self.senderTextField.userInteractionEnabled = NO;
    self.pwdTextField.userInteractionEnabled = NO;
    UILabel *senderLeftLabel = (UILabel *)self.senderTextField.leftView;
    senderLeftLabel.textColor = [UIColor lightGrayColor];
    UILabel *pwdLeftLabel = (UILabel *)self.pwdTextField.leftView;
    pwdLeftLabel.textColor = [UIColor lightGrayColor];
    self.senderTextField.text = @"";
    self.pwdTextField.text = @"";
    
#endif
    
    
#if 0
    //3.获取到的是非默认邮箱:
    self.senderTextField.text = @"1587319688";
    self.smtpTextField.text = @"@qq.com";
    
#endif
}

- (void)receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    switch(key){
            
        case RET_SET_ALARM_EMAIL:
        {
            
            NSInteger result = [[parameter valueForKey:@"result"] intValue];
            
            if(result==0){
                
                self.alarmSettingController.bindEmail = self.lastSetBindEmail;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"operator_success", nil)];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        usleep(800000);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self onBackPress];
                        });
                    });
                });
                
            }else if(result==15){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"email_format_error", nil)];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"operator_failure", nil)];
                });
            }
        }
            break;
    }
    
}

- (void)ack_receiveRemoteMessage:(NSNotification *)notification{
    NSDictionary *parameter = [notification userInfo];
    int key   = [[parameter valueForKey:@"key"] intValue];
    int result   = [[parameter valueForKey:@"result"] intValue];
    switch(key){
        case ACK_RET_SET_ALARM_EMAIL:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result==1){
                    [self.progressAlert hide:YES];
                    [self.view makeToast:NSLocalizedString(@"original_password_error", nil)];
                    
                }else if(result==2){
                    DLog(@"resend set alarm email");
                    [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:self.lastSetBindEmail];
                }
                
                
            });
            
            
            
            
            
            DLog(@"ACK_RET_SET_ALARM_EMAIL:%i",result);
        }
            break;
            
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.emailArray = @[NSLocalizedString(@"请选择邮箱", nil),@"@163.com",@"@qq.com",@"@gmail.com",@"@hotmail.com",NSLocalizedString(@"系统默认邮箱", nil)];
    [self initComponent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define MARGIN_LEFT_RIGHT 5.0
-(void)initComponent{
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    //CGFloat height = rect.size.height;
    [self.view setBackgroundColor:XBgColor];
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar setRightButtonHidden:NO];
    [topBar setRightButtonText:NSLocalizedString(@"save", nil)];
    [topBar.rightButton addTarget:self action:@selector(onSavePress) forControlEvents:UIControlEventTouchUpInside];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [topBar setTitle:NSLocalizedString(@"bind_email",nil)];
    [self.view addSubview:topBar];
    [topBar release];
    
    
    //发件人
    UITextField *senderTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, NAVIGATION_BAR_HEIGHT+20, width-MARGIN_LEFT_RIGHT*2-140.0, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        senderTextField.layer.borderWidth = 1;
        senderTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        senderTextField.layer.cornerRadius = 5.0;
    }
    senderTextField.textAlignment = NSTextAlignmentLeft;
    senderTextField.placeholder = NSLocalizedString(@"input_email", nil);
    senderTextField.font = XFontBold_16;
    senderTextField.borderStyle = UITextBorderStyleRoundedRect;
    senderTextField.returnKeyType = UIReturnKeyDone;
    senderTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    senderTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [senderTextField addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    [self.view addSubview:senderTextField];
    //左边的view
    UILabel *senderLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 55.0, TEXT_FIELD_HEIGHT)];
    senderLeftLabel.backgroundColor = [UIColor clearColor];
    senderLeftLabel.text = NSLocalizedString(@"发件人:", nil);
    senderLeftLabel.textAlignment = NSTextAlignmentRight;
    senderLeftLabel.font = XFontBold_16;
    senderTextField.leftView = senderLeftLabel;
    senderTextField.leftViewMode = UITextFieldViewModeAlways;
    [senderLeftLabel release];
    self.senderTextField = senderTextField;
    [senderTextField release];
    
    //发件人邮局
    UITextField *smtpTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.senderTextField.frame.origin.x+self.senderTextField.frame.size.width+5.0, NAVIGATION_BAR_HEIGHT+20, 140.0-5.0, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        smtpTextField.layer.borderWidth = 1;
        smtpTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        smtpTextField.layer.cornerRadius = 5.0;
    }
    smtpTextField.userInteractionEnabled = NO;
    smtpTextField.font = XFontBold_16;
    smtpTextField.textAlignment = NSTextAlignmentLeft;
    smtpTextField.borderStyle = UITextBorderStyleRoundedRect;
    smtpTextField.returnKeyType = UIReturnKeyDone;
    smtpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    smtpTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    smtpTextField.text = self.emailArray[0];
//    [self.view addSubview:smtpTextField];
    self.smtpTextField = smtpTextField;
    [smtpTextField release];
    //下拉按钮
    UIButton *dropDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dropDownBtn.frame = CGRectMake(width-MARGIN_LEFT_RIGHT-TEXT_FIELD_HEIGHT, NAVIGATION_BAR_HEIGHT+20, TEXT_FIELD_HEIGHT, TEXT_FIELD_HEIGHT);
    [dropDownBtn setImage:[UIImage imageNamed:@"dropdown.png"] forState:UIControlStateNormal];
    [dropDownBtn addTarget:self action:@selector(changeOpenStatus:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:dropDownBtn];
    self.dropDownBtn = dropDownBtn;
    //下拉表格
    TableViewWithBlock *tableView = [[TableViewWithBlock alloc] initWithFrame:CGRectMake(self.smtpTextField.frame.origin.x, self.smtpTextField.frame.origin.y+TEXT_FIELD_HEIGHT, self.smtpTextField.frame.size.width, 0) style:UITableViewStylePlain];
//    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView release];
    [self.tableView initTableViewDataSourceAndDelegate:^(UITableView *tableView,NSInteger section){
        return (NSInteger)self.emailArray.count;//多少行
        
    } setCellForIndexPathBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        //生成cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectionCell"];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SelectionCell"] autorelease];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        
        [cell.textLabel setText:self.emailArray[indexPath.row]];
        return cell;
    } setDidSelectRowBlock:^(UITableView *tableView,NSIndexPath *indexPath){
        //选中cell回调
        UITableViewCell *cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        self.smtpTextField.text=cell.textLabel.text;
        
        
        if (indexPath.row == 0) {//当前是“请选择邮箱”状态
            //当前是“请选择邮箱”状态;
            //发件人、密码、收件人正常显示；
            //邮局类型显示为“请选择邮箱”,并使用一个变量来记录当前是“请选择邮箱”状态,控制勾选按钮
            //勾选按钮不可以勾选
            self.isSelectEmailState = YES;
            self.senderTextField.userInteractionEnabled = YES;
            self.pwdTextField.userInteractionEnabled = YES;
            UILabel *senderLeftLabel = (UILabel *)self.senderTextField.leftView;
            senderLeftLabel.textColor = XBlack;
            UILabel *pwdLeftLabel = (UILabel *)self.pwdTextField.leftView;
            pwdLeftLabel.textColor = XBlack;
            self.senderTextField.text = @"";
            self.pwdTextField.text = @"";
            
        }else if (indexPath.row == 5) {//第5行代表系统默认邮箱
            //表示当前的发送邮箱是系统默认的;
            //此时，发件人、密码都不可编辑、字体变灰色，内容清空
            //勾选框也不可以勾选
            self.isSelectEmailState = NO;
            self.isSystemDefaultEmail = YES;
            self.senderTextField.userInteractionEnabled = NO;
            self.pwdTextField.userInteractionEnabled = NO;
            UILabel *senderLeftLabel = (UILabel *)self.senderTextField.leftView;
            senderLeftLabel.textColor = [UIColor lightGrayColor];
            UILabel *pwdLeftLabel = (UILabel *)self.pwdTextField.leftView;
            pwdLeftLabel.textColor = [UIColor lightGrayColor];
            self.senderTextField.text = @"";
            self.pwdTextField.text = @"";
            
            
            //防止之前，先点了勾选按钮，再选中系统默认
            self.selectBtn.selected = NO;
            self.reciTextField.text = self.alarmSettingController.bindEmail;//收件人为bindEmail
            self.reciTextField.textColor = XBlack;
            self.reciTextField.userInteractionEnabled = YES;//收件框可编辑
        }else{
            self.isSelectEmailState = NO;
            self.isSystemDefaultEmail = NO;
            self.senderTextField.userInteractionEnabled = YES;
            self.pwdTextField.userInteractionEnabled = YES;
            UILabel *senderLeftLabel = (UILabel *)self.senderTextField.leftView;
            senderLeftLabel.textColor = XBlack;
            UILabel *pwdLeftLabel = (UILabel *)self.pwdTextField.leftView;
            pwdLeftLabel.textColor = XBlack;
            
            
            if (self.selectBtn.selected) {//为YES说明，勾选按钮已经勾选，收件人与发件人相同
                self.reciTextField.text = [NSString stringWithFormat:@"%@%@",self.senderTextField.text,self.smtpTextField.text];//收件人为发件人
            }
        }
        
        
        [self.dropDownBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.tableView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.tableView.layer setBorderWidth:1.0];
    
    
    //邮箱密码
    UITextField *pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.senderTextField.frame.origin.y+TEXT_FIELD_HEIGHT+20.0, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        pwdTextField.layer.borderWidth = 1;
        pwdTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        pwdTextField.layer.cornerRadius = 5.0;
    }
    pwdTextField.textAlignment = NSTextAlignmentLeft;
    pwdTextField.placeholder = NSLocalizedString(@"input_password", nil);
    pwdTextField.font = XFontBold_16;
    pwdTextField.borderStyle = UITextBorderStyleRoundedRect;
    pwdTextField.returnKeyType = UIReturnKeyDone;
    pwdTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    pwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [pwdTextField addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    pwdTextField.secureTextEntry = YES;
//    [self.view addSubview:pwdTextField];
    //左边的view
    UILabel *pwdLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, TEXT_FIELD_HEIGHT)];
    pwdLeftLabel.backgroundColor = [UIColor clearColor];
    pwdLeftLabel.text = NSLocalizedString(@"密码:", nil);
    pwdLeftLabel.textAlignment = NSTextAlignmentRight;
    pwdLeftLabel.font = XFontBold_16;
    pwdTextField.leftView = pwdLeftLabel;
    pwdTextField.leftViewMode = UITextFieldViewModeAlways;
    [pwdLeftLabel release];
    self.pwdTextField = pwdTextField;
    [pwdTextField release];
    
    
    //勾选按钮
    UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.pwdTextField.frame.origin.y+TEXT_FIELD_HEIGHT+40.0, width-MARGIN_LEFT_RIGHT*2, 30.0)];
//    [self.view addSubview:selectView];
    //按钮
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(10.0, (30.0-28.0)/2, 28.0, 28.0);
    [selectBtn setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
    [selectBtn setImage:[UIImage imageNamed:@"check_on.png"] forState:UIControlStateSelected];
    [selectBtn addTarget:self action:@selector(btnClickToSelect:) forControlEvents:UIControlEventTouchUpInside];
    [selectView addSubview:selectBtn];
    self.selectBtn = selectBtn;
    //文本
    UILabel *selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0+28.0+5.0, 0.0, selectView.frame.size.width-10.0-28.0, 30.0)];
    selectLabel.backgroundColor = [UIColor clearColor];
    selectLabel.text = NSLocalizedString(@"勾选选框，则发件人与收件人为同一人", nil);
    selectLabel.font = XFontBold_16;
    selectLabel.textColor = [UIColor lightGrayColor];
    [selectView addSubview:selectLabel];
    [selectLabel release];
    [selectView release];
    
    //收件人
    UITextField *reciTextField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, self.pwdTextField.frame.origin.y+TEXT_FIELD_HEIGHT+40.0+30.0, width-MARGIN_LEFT_RIGHT*2, TEXT_FIELD_HEIGHT)];
    if(CURRENT_VERSION>=7.0){
        reciTextField.layer.borderWidth = 1;
        reciTextField.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        reciTextField.layer.cornerRadius = 5.0;
    }
    reciTextField.textAlignment = NSTextAlignmentLeft;
    reciTextField.placeholder = NSLocalizedString(@"input_email", nil);
    reciTextField.font = XFontBold_16;
    reciTextField.borderStyle = UITextBorderStyleRoundedRect;
    reciTextField.returnKeyType = UIReturnKeyDone;
    reciTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    reciTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    reciTextField.text = self.alarmSettingController.bindEmail;
    [reciTextField addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    [self.view addSubview:reciTextField];
    //左边的view
    UILabel *reciLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 55.0, TEXT_FIELD_HEIGHT)];
    reciLeftLabel.backgroundColor = [UIColor clearColor];
    reciLeftLabel.text = NSLocalizedString(@"收件人:", nil);
    reciLeftLabel.textAlignment = NSTextAlignmentRight;
    reciLeftLabel.font = XFontBold_16;
    reciTextField.leftView = reciLeftLabel;
    reciTextField.leftViewMode = UITextFieldViewModeAlways;
    [reciLeftLabel release];
    self.reciTextField = reciTextField;
    [reciTextField release];
    
    [self.view bringSubviewToFront:self.tableView];
    
    
    //delete
    UITextField *field1 = [[UITextField alloc] initWithFrame:CGRectMake(BAR_BUTTON_MARGIN_LEFT_AND_RIGHT, NAVIGATION_BAR_HEIGHT+20, width-BAR_BUTTON_MARGIN_LEFT_AND_RIGHT*2, TEXT_FIELD_HEIGHT)];
    
    if(CURRENT_VERSION>=7.0){
        field1.layer.borderWidth = 1;
        field1.layer.borderColor = [[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0] CGColor];
        field1.layer.cornerRadius = 5.0;
    }
    field1.textAlignment = NSTextAlignmentLeft;
    field1.placeholder = NSLocalizedString(@"input_email", nil);
    field1.borderStyle = UITextBorderStyleRoundedRect;
    field1.returnKeyType = UIReturnKeyDone;
    field1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field1.text = self.alarmSettingController.bindEmail;
    [field1 addTarget:self action:@selector(onKeyBoardDown:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.field1 = field1;
    [self.view addSubview:field1];
    [field1 release];
    
    
    //指示器
    self.progressAlert = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    [self.view addSubview:self.progressAlert];
    
    
    //模拟测试，获取发件人邮箱//delete
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(60.0, 400.0, 200.0, 80.0);
    button.backgroundColor = [UIColor cyanColor];
    [button addTarget:self action:@selector(btnClickToTest:) forControlEvents:UIControlEventTouchUpInside];
    
    //[self.view addSubview:button];
}

#pragma mark - 勾选选框，收件人是否同步发件人的邮箱
-(void)btnClickToSelect:(UIButton *)button{
    //表示当前的发送邮箱是系统默认的;或是当前是“请选择邮箱”状态
    if (self.isSystemDefaultEmail || self.isSelectEmailState) {
        return;//勾选框不可以勾选
    }
    
    
    if (button.selected) {//当前为选中状态，则取消选中，并使收件框可编辑,且收件人为bindEmail
        button.selected = NO;
        self.reciTextField.text = self.alarmSettingController.bindEmail;//收件人为bindEmail
        self.reciTextField.textColor = XBlack;
        self.reciTextField.userInteractionEnabled = YES;//收件框可编辑
    }else{//当前为非选中状态，则置为选中状态，并使收件框不可编辑，且收件人为发件人
        button.selected = YES;
        self.reciTextField.text = [NSString stringWithFormat:@"%@%@",self.senderTextField.text,self.smtpTextField.text];//收件人为发件人
        self.reciTextField.textColor = [UIColor lightGrayColor];
        self.reciTextField.userInteractionEnabled = NO;//收件框不可编辑
    }
}

#pragma mark - UITextFieldTextDidChangeNotification
//发件人编辑框、邮局类型编辑框已经开始编辑，收件人动态同步发件人帐号
- (void)textFieldChanged:(id)sender{
    if (self.selectBtn.selected) {//为YES说明，勾选按钮已经勾选，收件人与发件人相同
        self.reciTextField.text = [NSString stringWithFormat:@"%@%@",self.senderTextField.text,self.smtpTextField.text];//收件人为发件人
    }
}

#pragma mark - 下拉按钮触发调用函数
- (void)changeOpenStatus:(id)sender {
    if (isOpened) {
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *closeImage=[UIImage imageNamed:@"dropdown.png"];
            [self.dropDownBtn setImage:closeImage forState:UIControlStateNormal];
            
            CGRect frame=self.tableView.frame;
            
            frame.size.height=0.0;
            [self.tableView setFrame:frame];
            
        } completion:^(BOOL finished){
            
            isOpened=NO;
        }];
        
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            UIImage *openImage=[UIImage imageNamed:@"dropup.png"];
            [self.dropDownBtn setImage:openImage forState:UIControlStateNormal];
            
            CGRect frame=self.tableView.frame;
            
            frame.size.height=200.0;
            [self.tableView setFrame:frame];
        } completion:^(BOOL finished){
            
            isOpened=YES;
        }];
        
        
    }
}

-(void)onKeyBoardDown:(id)sender{
    [sender resignFirstResponder];
}

-(void)onBackPress{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_REMOTE_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ACK_RECEIVE_REMOTE_MESSAGE object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onSavePress{
    NSString *email = self.field1.text;
    
    if(!email||!email.length>0){
//        [self.view makeToast:NSLocalizedString(@"input_email", nil)];
        self.progressAlert.dimBackground = YES;
        [self.progressAlert show:YES];
        [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:@"0"];
    }else{
        if(email.length<5||email.length>32){
            [self.view makeToast:NSLocalizedString(@"email_length_error", nil)];
            return;
        }else{
            self.lastSetBindEmail = email;
            self.progressAlert.dimBackground = YES;
            [self.progressAlert show:YES];
            [[P2PClient sharedClient] setAlarmEmailWithId:self.contact.contactId password:self.contact.contactPassword email:self.lastSetBindEmail];
        }
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
