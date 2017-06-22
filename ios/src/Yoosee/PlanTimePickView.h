//
//  PlanTimePickView.h
//  Yoosee
//
//  Created by guojunyi on 14-5-19.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDJPickerView.h"
#import "Constants.h"
@interface PlanTimePickView : UIView<IDJPickerViewDelegate>
@property (nonatomic, strong) IDJPickerView *picker;
@property(nonatomic) DeviceDate date;
@end
