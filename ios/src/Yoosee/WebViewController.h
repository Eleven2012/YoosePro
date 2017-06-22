//
//  WebViewController.h
//  Yoosee
//
//  Created by gwelltime on 15-1-28.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TopBar;
@class  MBProgressHUD;

@interface WebViewController : UIViewController
@property(nonatomic,strong) NSString *imgURLLinkString;
@property(nonatomic,strong) TopBar *topBar;
@property(nonatomic,strong) UIWebView *webView;

@property (strong, nonatomic) MBProgressHUD *progressAlert;
@property(nonatomic) BOOL isFirstLoading;
@property(nonatomic) BOOL isQuitWebSite;

@end
