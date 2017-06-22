//
//  AutoTabBarController.h
//  Yoosee
//
//  Created by guojunyi on 14-4-11.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomBar.h"
@interface AutoTabBarController : UITabBarController
@property (strong, nonatomic) BottomBar *bottomBar;

-(void)setBottomBarHidden:(BOOL)isHidden;
@end
