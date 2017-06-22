//
//  PopoverTableView.h
//  Yoosee
//
//  Created by gwelltime on 15-3-4.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DXPopover;

@interface PopoverTableView : UIView<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) DXPopover *popover;
@end
