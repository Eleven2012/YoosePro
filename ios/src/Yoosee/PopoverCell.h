//
//  PopoverCell.h
//  Yoosee
//
//  Created by gwelltime on 15-3-10.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopoverCell : UITableViewCell

@property (strong,nonatomic) NSString *leftIcon;
@property (strong,nonatomic) NSString *rightIcon;
@property (strong,nonatomic) NSString *labelText;

@property (strong, nonatomic) UIImageView *leftIconView;
@property (strong, nonatomic) UIImageView *leftIconView_p;

@property (strong, nonatomic) UILabel *textLabelView;
@property (strong, nonatomic) UILabel *textLabelView_p;

@property (strong, nonatomic) UIImageView *rightIconView;
@property (strong, nonatomic) UIImageView *rightIconView_p;

@end
