//
//  ShakeCell.h
//  Yoosee
//
//  Created by guojunyi on 14-5-23.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ShakeCell;
@protocol ShakeCellDelegate <NSObject>

@optional
-(void)onShakeCellPress:(ShakeCell*)shakeCell contactId:(NSString*)contactId contactType:(NSInteger)contactType contactFlag:(NSInteger)contactFlag address:(NSString*)address;
@end

@interface ShakeCell : UITableViewCell



@property (strong,nonatomic) UIButton *mainView;

@property (strong, nonatomic) NSString *contactId;
@property (strong, nonatomic) NSString *labelText;
@property (strong, nonatomic) UIImageView *leftIconView;
@property (strong, nonatomic) UILabel *labelView;

@property (strong, nonatomic) NSString *typeIcon;
@property (strong, nonatomic) UIImageView *typeView;

@property (assign) NSInteger contactFlag;
@property (assign) NSInteger contactType;
@property (strong, nonatomic) NSString *address;

@property (strong, nonatomic) UIImageView *rightIconView;
@property (strong, nonatomic) NSString *rightIcon;

@property (nonatomic, assign) id<ShakeCellDelegate> delegate;
@end
