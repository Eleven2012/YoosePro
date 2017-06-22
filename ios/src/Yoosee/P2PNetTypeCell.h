//
//  P2PNetTypeCell.h
//  Yoosee
//
//  Created by guojunyi on 14-5-19.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RadioButton;
@interface P2PNetTypeCell : UITableViewCell
@property (strong, nonatomic) RadioButton *radio1;
@property (strong, nonatomic) RadioButton *radio2;

@property (assign) NSInteger selectedIndex;
@end
