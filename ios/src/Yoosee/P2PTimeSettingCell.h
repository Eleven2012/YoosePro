//
//  P2PSettingCell.h
//  Yoosee
//
//  Created by guojunyi on 14-5-13.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyPickerView;
@interface P2PTimeSettingCell : UITableViewCell

@property (strong, nonatomic) NSString *leftLabelText;
@property (strong, nonatomic) NSString *rightLabelText;

@property (strong, nonatomic) UILabel *leftLabelView;
@property (strong, nonatomic) UILabel *rightLabelView;

@property (strong, nonatomic) MyPickerView *customView;
@property (strong, nonatomic) UIActivityIndicatorView *progressView;
@property (assign) BOOL isCustomViewHidden;
@property (assign) BOOL isLeftLabelHidden;
@property (assign) BOOL isRightLabelHidden;
@property (assign) BOOL isProgressViewHidden;

-(void)setLeftLabelHidden:(BOOL)hidden;
-(void)setRightLabelHidden:(BOOL)hidden;
-(void)setCustomViewHidden:(BOOL)hidden;
-(void)setProgressViewHidden:(BOOL)hidden;
@end
