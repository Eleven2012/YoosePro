//
//  ConnectFailurePromptView.h
//  Yoosee
//
//  Created by gwelltime on 15-3-13.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConnectFailurePromptViewDelegate <NSObject>
@required
-(void)connectOnceAgainButtonClick;
-(void)connectFailurePromptViewSetWifiToAddDeviceByQR;//set wifi to add device by qr

@end

@interface ConnectFailurePromptView : UIView
@property(nonatomic, assign) id<ConnectFailurePromptViewDelegate> delegate;
@end
