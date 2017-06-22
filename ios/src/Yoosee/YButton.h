//
//  YButton.h
//  Yoosee
//
//  Created by guojunyi on 14-7-24.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YButton;
@protocol YButtonDelegate <NSObject>
-(void)onYButtonClick:(YButton*)yButton;
-(void)onYButtonDown:(YButton*)yButton;
@end

@interface YButton : UIButton
@property (nonatomic,strong) NSString *image;
@property (nonatomic,strong) NSString *image_p;
@property (assign) id<YButtonDelegate> delegate;


@end
