//
//  P2PTimezoneSettingCell.h
//  Yoosee
//
//  Created by guojunyi on 14-9-28.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimezoneView.h"

@interface P2PTimezoneSettingCell : UITableViewCell<TimezoneViewDelegate>

@property (strong, nonatomic) NSString *leftLabelText;
@property (strong, nonatomic) NSString *rightLabelText;

@property (strong, nonatomic) UILabel *leftLabelView;
@property (strong, nonatomic) UILabel *rightLabelView;

@property (strong, nonatomic) TimezoneView *customView;
@property (strong, nonatomic) UIActivityIndicatorView *progressView;
@property (assign) BOOL isCustomViewHidden;
@property (assign) BOOL isLeftLabelHidden;
@property (assign) BOOL isRightLabelHidden;
@property (assign) BOOL isProgressViewHidden;

-(void)setLeftLabelHidden:(BOOL)hidden;
-(void)setRightLabelHidden:(BOOL)hidden;
-(void)setCustomViewHidden:(BOOL)hidden;
-(void)setProgressViewHidden:(BOOL)hidden;

@property (nonatomic , copy) void (^OnTimezoneChange)(NSInteger timezone);

@end
