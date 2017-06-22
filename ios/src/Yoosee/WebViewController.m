//
//  WebViewController.m
//  Yoosee
//
//  Created by gwelltime on 15-1-28.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "WebViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "TopBar.h"
#import "MainController.h"
#import "MBProgressHUD.h"
#import "Toast+UIView.h"
#import "UDManager.h"
#import "LoginController.h"
#import "NetManager.h"
#import "LoginResult.h"
#import "AccountResult.h"
#import "AutoNavigation.h"

@interface WebViewController ()<UIWebViewDelegate>

@end

@implementation WebViewController
-(void)dealloc{
    [self.imgURLLinkString release];
    [self.topBar release];
    [self.webView release];
    [self.progressAlert release];
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated{
    MainController *mainController = [AppDelegate sharedDefault].mainController;
    [mainController setBottomBarHidden:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initComponent];
}

-(void)initComponent{
    
    [self.view setBackgroundColor:XBgColor];
    CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    //navigation bar
    TopBar *topBar = [[TopBar alloc] initWithFrame:CGRectMake(0, 0, width, NAVIGATION_BAR_HEIGHT)];
    [topBar setBackButtonHidden:NO];
    [topBar.backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBar];
    self.topBar = topBar;
    [topBar release];
    
    //webView
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, width, height-NAVIGATION_BAR_HEIGHT)];
    webView.scalesPageToFit = TRUE;
    [webView setUserInteractionEnabled:YES];//是否支持交互
    webView.delegate = self;
    NSURL *imgURLLink = [NSURL URLWithString:self.imgURLLinkString];
    NSURLRequest *request = [NSURLRequest requestWithURL:imgURLLink];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    self.webView = webView;
    [webView release];
    
    //UIActivityIndicatorView
    MBProgressHUD *progress = [[MBProgressHUD alloc]initWithView:self.view];
    self.progressAlert = progress;
    self.progressAlert.labelText = NSLocalizedString(@"loading", nil);
    [self.webView addSubview:self.progressAlert];
    [progress release];
}

#pragma mark - UIWebViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView{
    if (self.isFirstLoading) {
        self.progressAlert.dimBackground = YES;
        [self.progressAlert show:YES];
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if (self.isFirstLoading) {
        [self.progressAlert hide:YES];
        self.isFirstLoading = NO;
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if (self.isFirstLoading) {
        //[self.view makeToast:NSLocalizedString(@"加载失败", nil)];
        [self.progressAlert hide:YES];
    }
}

-(void)onBackPress{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else{
        self.webView.delegate = nil;//设置代理最常见的崩溃问题
        if (self.webView.loading) {
            [self.webView stopLoading];
        }
        
        if (self.isQuitWebSite) {
            if([UDManager isLogin]){
                
                MainController *mainController = [[MainController alloc] init];
                [AppDelegate sharedDefault].mainController = mainController;
                self.view.window.rootViewController = [AppDelegate sharedDefault].mainController;
                [mainController release];
                LoginResult *loginResult = [UDManager getLoginInfo];
                [[NetManager sharedManager] getAccountInfo:loginResult.contactId sessionId:loginResult.sessionId callBack:^(id JSON){
                    
                    AccountResult *accountResult = (AccountResult*)JSON;
                    if(accountResult.error_code==NET_RET_GET_ACCOUNT_SUCCESS){
                        loginResult.email = accountResult.email;
                        loginResult.phone = accountResult.phone;
                        loginResult.countryCode = accountResult.countryCode;
                        [UDManager setLoginInfo:loginResult];
                    }
                    
                }];
            }else{
                LoginController *loginController = [[LoginController alloc] init];
                AutoNavigation *mainController = [[AutoNavigation alloc] initWithRootViewController:loginController];
                
            
                self.view.window.rootViewController = mainController;
                [loginController release];
                [mainController release];
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
