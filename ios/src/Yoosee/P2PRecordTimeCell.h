//
//  P2PRecordTimeCell.h
//  Yoosee
//
//  Created by guojunyi on 14-5-16.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RadioButton;
@protocol P2PRecordTimeCellDelegate <NSObject>
-(void)onRecordTimeCellRadioClick:(RadioButton*)radio index:(NSInteger)index;
@end

@interface P2PRecordTimeCell : UITableViewCell
@property (strong, nonatomic) RadioButton *radio1;
@property (strong, nonatomic) RadioButton *radio2;
@property (strong, nonatomic) RadioButton *radio3;
@property (assign) id<P2PRecordTimeCellDelegate> delegate;
@property (assign) NSInteger selectedIndex;
@end
