//
//  P2PEmailSettingCell.h
//  Yoosee
//
//  Created by guojunyi on 14-5-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface P2PEmailSettingCell : UITableViewCell
@property (strong, nonatomic) NSString *leftLabelText;
@property (strong, nonatomic) UILabel *leftLabelView;

@property (strong, nonatomic) NSString *rightLabelText;
@property (strong, nonatomic) UILabel *rightLabelView;

@property (strong, nonatomic) NSString *leftIcon;
@property (strong, nonatomic) UIImageView *leftIconView;
    
@property (strong, nonatomic) NSString *rightIcon;
@property (strong, nonatomic) UIImageView *rightIconView;

@property (strong, nonatomic) UIActivityIndicatorView *progressView;

@property (assign) BOOL isLeftLabelHidden;
@property (assign) BOOL isRightLabelHidden;
@property (assign) BOOL isLeftIconHidden;
@property (assign) BOOL isRightIconHidden;
    
@property (assign) BOOL isProgressViewHidden;



-(void)setRightLabelHidden:(BOOL)hidden;
-(void)setLeftIconHidden:(BOOL)hidden;
-(void)setRightIconHidden:(BOOL)hidden;
-(void)setProgressViewHidden:(BOOL)hidden;
-(void)setLeftLabelHidden:(BOOL)hidden;
@end
