//
//  ChatCell.h
//  Yoosee
//
//  Created by guojunyi on 14-5-29.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Message;
@interface ChatCell : UITableViewCell

@property (strong, nonatomic) Message *message;


@property (strong, nonatomic) UIImageView *headerView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *messageView;


@end
