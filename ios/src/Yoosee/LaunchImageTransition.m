//
//  LaunchImageTransition.m
//  Yoosee
//
//  Created by nyshnukdny on 15-1-28.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "LaunchImageTransition.h"
#import "WebViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Toast+UIView.h"

@interface LaunchImageTransition ()

@end

@implementation LaunchImageTransition

- (id)initWithViewController:(UIViewController *)controller animation:(UIModalTransitionStyle)transition {
    
	return [self initWithViewController:controller animation:transition delay:2.0];
}

- (id)initWithViewController:(UIViewController *)controller animation:(UIModalTransitionStyle)transition delay:(NSTimeInterval)seconds {
	self = [super init];
	
	if (self) {
        CGRect rect = [AppDelegate getScreenSize:YES isHorizontal:NO];
        CGFloat width = rect.size.width;
        CGFloat height = rect.size.height;
        
        UIButton *webLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        webLinkButton.frame = CGRectMake(0, 0, width, height);
        [webLinkButton addTarget:self action:@selector(clickLinkWeb:) forControlEvents:UIControlEventTouchUpInside];
		
        //get launch image
        NSString *lacalFlag = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppStartInfoFlag"];
        NSString *imagePath = [Utils getAppLaunchImageFilePathWithFlag:lacalFlag];
        UIImage *launchImage = [UIImage imageWithContentsOfFile:imagePath];
        
        UIImageView *launchImageView = [[UIImageView alloc] initWithImage:launchImage];
        launchImageView.contentMode = UIViewContentModeCenter;//不改变图片的大小，原型显示
        launchImageView.frame = CGRectMake(0, 0, width, height);
        [webLinkButton addSubview:launchImageView];
        [self.view addSubview:webLinkButton];
        [launchImageView release];
		
		[controller setModalTransitionStyle:transition];
        
        
		[NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(timerFireMethod:) userInfo:controller repeats:NO];
	}
	
	return self;
}

- (void)timerFireMethod:(NSTimer *)theTimer {
    
	[self presentModalViewController:[theTimer userInfo] animated:NO];
}

-(void)clickLinkWeb:(id)sender{
    //get link string
    NSString *link = [[NSUserDefaults standardUserDefaults] objectForKey:@"Link"];
    
    WebViewController *webViewController = [[WebViewController alloc] init];
    webViewController.imgURLLinkString = link;
    webViewController.isFirstLoading = YES;
    webViewController.isQuitWebSite = YES;
    if ([webViewController.imgURLLinkString isEqualToString:@""]) {
        [self.view makeToast:NSLocalizedString(@"invalid_link", nil)];
    }else{
        [self presentModalViewController:webViewController animated:YES];
    }
    [webViewController release];
}

@end
