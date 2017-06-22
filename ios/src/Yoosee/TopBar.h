//
//  TopBar.h
//  Yoosee
//
//  Created by guojunyi on 14-4-3.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopBar : UIView
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *rightButton;
@property (strong, nonatomic) UIImageView *rightButtonIconView;
@property (strong, nonatomic) UILabel *rightButtonLabel;
-(void)setTitle:(NSString*)title;
-(void)setBackButtonHidden:(BOOL)hidden;
-(void)setRightButtonHidden:(BOOL)hidden;
-(void)setRightButtonIcon:(UIImage*)img;
-(void)setRightButtonText:(NSString*)text;
@end
