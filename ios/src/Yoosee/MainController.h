//
//  MainController.h
//  Yoosee
//
//  Created by guojunyi on 14-3-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "P2PClient.h"
#import "AutoTabBarController.h"
#import "Contact.h"//重新调整监控画面

@protocol MainControllerDelegate <NSObject>

@optional
- (void)P2PClientReady:(NSDictionary*)info;
@end

@interface MainController : AutoTabBarController<P2PClientDelegate>
@property (nonatomic) BOOL isShowP2PView;
@property (nonatomic,strong) NSString * contactName;
@property (nonatomic,strong) Contact * contact;//重新调整监控画面
@property (nonatomic, assign) id<MainControllerDelegate> delegate;

-(void)setUpCallWithId:(NSString*)contactId password:(NSString*)password callType:(P2PCallType)type;

-(void)setUpCallWithId:(NSString*)contactId address:(NSString*)address password:(NSString*)password callType:(P2PCallType)type;

-(void)dismissP2PView;
-(void)dismissP2PView:(void (^)())callBack;
@end
