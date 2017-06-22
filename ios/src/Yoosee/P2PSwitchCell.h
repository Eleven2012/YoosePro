//
//  P2PSwitchCell.h
//  Yoosee
//
//  Created by guojunyi on 14-5-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchCellDelegate <NSObject>

@optional
-(void)onSwitchValueChange:(UISwitch*)sender indexPath:(NSIndexPath*)indexPath;
@end

@interface P2PSwitchCell : UITableViewCell

@property (strong, nonatomic) NSString *leftLabelText;


@property (strong, nonatomic) UILabel *leftLabelView;


@property (strong, nonatomic) UIActivityIndicatorView *progressView;
@property (strong, nonatomic) UISwitch *switchView;

@property (assign) BOOL isProgressViewHidden;
@property (assign) BOOL isSwitchViewHidden;

-(void)setProgressViewHidden:(BOOL)hidden;
-(void)setSwitchViewHidden:(BOOL)hidden;

@property (assign) BOOL on;
@property (assign) id<SwitchCellDelegate> delegate;
@property (nonatomic,strong) NSIndexPath *indexPath;

@end
