//
//  RecommendInfoListCell.h
//  Yoosee
//
//  Created by gwelltime on 15-1-19.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendInfoListCell : UITableViewCell

@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) UIImageView *imgView;
@property(nonatomic,strong) UILabel *contentLabel;

@property(nonatomic,strong) NSString *titleString;
@property(nonatomic,strong) NSString *timeString;
@property(nonatomic,strong) NSString *imageURLString;
@property(nonatomic,strong) NSString *contentString;

@property (nonatomic,assign) BOOL isReadCell;

@end
