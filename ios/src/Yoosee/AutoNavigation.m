//
//  AutoNavigation.m
//  Yoosee
//
//  Created by guojunyi on 14-3-27.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "AutoNavigation.h"
#import "Constants.h"

@interface AutoNavigation ()

@end

@implementation AutoNavigation

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//UINavigationController与UITabBarController不同，viewWillAppear每次都执行
-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationBar.frame = CGRectMake(self.navigationBar.frame.origin.x, self.navigationBar.frame.origin.y, self.navigationBar.frame.size.width, 0);
    self.navigationBarHidden = YES;
}

//执行一次
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:XHeadBarTextColor,UITextAttributeTextColor,[UIFont boldSystemFontOfSize:XHeadBarTextSize],UITextAttributeFont,nil]];
    
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_navigation_bar.png"] forBarMetrics:UIBarMetricsDefault];
    if(CURRENT_VERSION<7.0){
        [self.navigationBar setTitleVerticalPositionAdjustment:NAVIGATION_BAR_HEIGHT/2 forBarMetrics:UIBarMetricsDefault];
        
        
    }
    DLog(@"navigationBarHeight:%f",self.navigationBar.frame.size.height);
   
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    
    if([[self.viewControllers lastObject] shouldAutorotate]){
        DLog(@"AutoNavigation  YES");
    }
    
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return [[self.viewControllers lastObject] shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}
@end
