//
//  LocalDeviceCell.h
//  Yoosee
//
//  Created by guojunyi on 14-7-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalDeviceCell : UITableViewCell

@property (nonatomic,strong) NSString *leftImage;
@property (nonatomic,strong) NSString *rightImage;
@property (nonatomic,strong) UIImageView *leftImageView;
@property (nonatomic,strong) UIImageView *rightImageView;
@property (nonatomic,strong) NSString *contentText;
@property (nonatomic,strong) UILabel *contentLabel;
@end
