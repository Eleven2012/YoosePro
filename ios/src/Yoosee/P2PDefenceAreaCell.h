//
//  P2PDefenceAreaCell.h
//  Yoosee
//
//  Created by guojunyi on 14-5-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DefenceAreaDelegate <NSObject>

@optional
-(void)onItemClicked:(UIButton*)button group:(NSInteger)group item:(NSInteger)item state:(BOOL)isLight;
@end

@interface P2PDefenceAreaCell : UITableViewCell
@property (strong, nonatomic) NSString *leftLabelText;
@property (strong, nonatomic) UILabel *leftLabelView;

@property (strong, nonatomic) UIView *customView;

@property (assign) BOOL isShowCustomView;

@property (nonatomic, assign) id<DefenceAreaDelegate> delegate;

@property (assign) NSInteger group;
@property (strong,nonatomic) NSMutableArray *status;

@property (strong, nonatomic) UIActivityIndicatorView *progressView;

@property (assign) BOOL isProgressViewHidden;

-(void)setProgressViewHidden:(BOOL)hidden;
@end
