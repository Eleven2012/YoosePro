//
//  SortBar.h
//  Yoosee
//
//  Created by guojunyi on 14-5-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SortBar;
@protocol SortBarDelegate <NSObject>

@optional
-(void)onSortBarChange:(SortBar*)sortBar index:(NSInteger)index;
-(void)onSortBarTouchEnd:(SortBar*)sortBar;
@end

@interface SortBar : UIView
-(id)initWithDatas:(NSArray*)array frame:(CGRect)frame;

@property (assign) NSInteger count;
@property (assign) CGFloat itemHeight;
@property (nonatomic, assign) id<SortBarDelegate> delegate;
@end
