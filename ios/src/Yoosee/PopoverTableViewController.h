//
//  PopoverTableViewController.h
//  Yoosee
//
//  Created by gwelltime on 15-3-9.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopoverTableViewController : UITableViewController

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIPopoverController *popover;

@end
