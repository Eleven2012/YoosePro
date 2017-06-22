//
//  ContactCell.h
//  Yoosee
//
//  Created by guojunyi on 14-4-12.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "YProgressView.h"
@protocol OnClickDelegate
-(void)onClick:(NSInteger)position contact:(Contact*)contact;

@end

@class Contact;
@interface ContactCell : UITableViewCell
@property (strong, nonatomic) Contact *contact;

@property (strong, nonatomic) UIButton *headView;
@property (strong, nonatomic) UIImageView *typeView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *stateLabel;
@property (strong, nonatomic) UIImageView *weakPwdImageView;

@property (strong, nonatomic) UIButton *defenceStateView;
@property (strong, nonatomic) YProgressView *defenceProgressView;

@property (strong, nonatomic) UIImageView *messageCountView;

@property (strong, nonatomic) id<OnClickDelegate> delegate;
@property (nonatomic) NSInteger position;

@end
