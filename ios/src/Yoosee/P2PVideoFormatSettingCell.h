//
//  P2PVideoFormatSettingCell.h
//  Yoosee
//
//  Created by guojunyi on 14-5-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RadioButton;
@interface P2PVideoFormatSettingCell : UITableViewCell

@property (strong, nonatomic) NSString *leftLabelText;
@property (strong, nonatomic) NSString *rightLabelText;

@property (strong, nonatomic) UILabel *leftLabelView;
@property (strong, nonatomic) UILabel *rightLabelView;

@property (strong, nonatomic) UIView *customView;
@property (strong, nonatomic) RadioButton *radio1;
@property (strong, nonatomic) RadioButton *radio2;
@property (strong, nonatomic) UIActivityIndicatorView *progressView;
@property (assign) BOOL isCustomViewHidden;
@property (assign) BOOL isLeftLabelHidden;
@property (assign) BOOL isRightLabelHidden;
@property (assign) BOOL isProgressViewHidden;

-(void)setLeftLabelHidden:(BOOL)hidden;
-(void)setRightLabelHidden:(BOOL)hidden;
-(void)setCustomViewHidden:(BOOL)hidden;
-(void)setProgressViewHidden:(BOOL)hidden;

@property (assign) NSInteger selectedIndex;
@end
