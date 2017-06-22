//
//  QRCodeGuardFirst.h
//  Yoosee
//
//  Created by wutong on 15-2-3.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol QRGuardDelegate<NSObject>
-(void)setQRGuard:(BOOL)bEnable;
@end

@interface QRCodeGuardFirst : UIView
@property (nonatomic, assign) id<QRGuardDelegate> delegate;

@end
