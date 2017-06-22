//
//  RadioButton.h
//  Yoosee
//
//  Created by guojunyi on 14-5-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadioButton : UIButton
@property (assign) BOOL isSelected;
@property (nonatomic,strong) UIImageView *leftIconView;
@property (nonatomic,strong) UILabel *labelView;
-(void)setText:(NSString*)text;

-(void)setSelected:(BOOL)selected;
@end
