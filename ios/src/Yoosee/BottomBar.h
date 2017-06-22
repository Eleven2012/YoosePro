//
//  BottomBar.h
//  Yoosee
//
//  Created by guojunyi on 14-4-11.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"

@interface BottomBar : UIView
@property (strong,nonatomic) NSMutableArray *items;
@property (strong,nonatomic) NSMutableArray *backViews;
@property (strong,nonatomic) NSMutableArray *iconViews;
@property (strong,nonatomic) NSMutableArray *itemTitles;
@property (strong,nonatomic) JSBadgeView *infoBadgeView;
@property (strong,nonatomic) JSBadgeView *mallBadgeView;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) BOOL isHavingNewInfo;
@property (nonatomic) BOOL isHavingNewMallInfo;
-(void)updateItemIcon:(NSInteger)willSelectedIndex;
@end
