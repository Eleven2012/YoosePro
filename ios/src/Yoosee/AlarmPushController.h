//
//  AlarmPushController.h
//  2cu
//
//  Created by 高琦 on 15/3/12.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
@interface AlarmPushController : UIViewController<UIAlertViewDelegate>
@property (strong,nonatomic) UIImageView * touchbtnview;
@property (strong,nonatomic) UIImageView * downlineview;
@property (strong,nonatomic) UIImageView * acceptview;
@property (strong,nonatomic) UIImageView * rejectview;
@property (strong, nonatomic) UIImageView * alarmSnapImageView;
@property (assign)BOOL isshow;
@property (assign)BOOL iscanmove;
@property (assign)BOOL isbreathe;
@property (assign,nonatomic)CGRect touchbtnframe;
@property (assign,nonatomic)CGRect touchlineframe;
@property (assign,nonatomic)CGFloat trans;
@property (strong,nonatomic)NSTimer * timer;

@property(strong,nonatomic)NSString * contactId;
@property (nonatomic,strong) NSString * contactName;
@property (nonatomic, strong) UIImage *imgCurrentCameraCover;

@end
