//
//  RecentCell.h
//  Yoosee
//
//  Created by guojunyi on 14-4-2.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentCell : UITableViewCell

@property (strong, nonatomic) NSString *leftIcon;
@property (strong, nonatomic) NSString *contactId;
@property (strong, nonatomic) NSString *callState;
@property (strong, nonatomic) NSString *time;

@property (strong, nonatomic) UIImageView *leftIconView;
@property (strong, nonatomic) UILabel *contactIdLabel;
@property (strong, nonatomic) UIImageView *callStateView;
@property (strong, nonatomic) UILabel *timeLabel;


@property (strong, nonatomic) UILabel *contactIdLabel_p;
@property (strong, nonatomic) UIImageView *callStateView_p;
@property (strong, nonatomic) UILabel *timeLabel_p;
@end
