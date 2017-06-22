//
//  PopoverView.h
//  Yoosee
//
//  Created by gwelltime on 15-3-20.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopoverViewDelegate <NSObject>
@required
-(void)didSelectedPopoverViewRow:(NSInteger)row;

@end

@interface PopoverView : UIView

@property (nonatomic, strong) UIImage *backgroundImage;

@property(nonatomic, assign) id<PopoverViewDelegate> delegate;

@end
