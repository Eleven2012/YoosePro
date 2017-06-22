//
//  AutoTabBarController.m
//  Yoosee
//
//  Created by guojunyi on 14-4-11.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "AutoTabBarController.h"
#import "BottomBar.h"
#import "TopBar.h"
#import "Constants.h"
@interface AutoTabBarController ()

@end

@implementation AutoTabBarController

-(void)dealloc{
    [self.bottomBar release];
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
    [super viewWillAppear:YES];
    
    
}
//the follow codes sometimes have problem in "viewWillAppear".
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];//没有这句会出在问题的
    
    //注意，放在viewDidLoad里隐藏是不可行的，因为执行viewDidLoad函数时，tabBar还没有。
    self.tabBar.frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y, self.tabBar.frame.size.width, 0);
    [self.tabBar setHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tabBar setBackgroundColor:[UIColor blackColor]];
    
    for(UIView *view in self.view.subviews){
        if([view isKindOfClass:[UITabBar class]]){
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y+TAB_BAR_HEIGHT, view.frame.size.width, view.frame.size.height);
        }else{
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height+TAB_BAR_HEIGHT);
        }
    }
    
    //frame = origin=(x=0, y=975) size=(width=768, height=49)
    BottomBar *bottomBar = [[BottomBar alloc] initWithFrame:CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y-TAB_BAR_HEIGHT, self.tabBar.frame.size.width, self.tabBar.frame.size.height)];
    
    int i = 0;
    for(UIButton *item in bottomBar.items){
        item.tag = i;
        [item addTarget:self action:@selector(onItemPress:) forControlEvents:UIControlEventTouchUpInside];
        i++;
    }
    [self.view addSubview:bottomBar];
    self.bottomBar = bottomBar;
    [bottomBar release];
    
    
    
	// Do any additional setup after loading the view.
}

-(void)onItemPress:(id)sender{
    
    UIButton *item = (UIButton*)sender;
    [self setSelectedIndex:item.tag];
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex{
    [super setSelectedIndex:selectedIndex];
    if(self.bottomBar){
        [self.bottomBar updateItemIcon:selectedIndex];
    }
    
}

-(void)setBottomBarHidden:(BOOL)isHidden{
    if(self.bottomBar){
        [self.bottomBar setHidden:isHidden];
    }
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
