//
//  P2PRecordTypeCell.h
//  Yoosee
//
//  Created by guojunyi on 14-5-16.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RadioButton;
@interface P2PRecordTypeCell : UITableViewCell
@property (strong, nonatomic) RadioButton *radio1;
@property (strong, nonatomic) RadioButton *radio2;
@property (strong, nonatomic) RadioButton *radio3;

@property (assign) NSInteger selectedIndex;
@end
