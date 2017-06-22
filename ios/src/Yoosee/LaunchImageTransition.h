//
//  LaunchImageTransition.h
//  Yoosee
//
//  Created by nyshnukdny on 15-1-28.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LaunchImageTransition : UIViewController

- (id)initWithViewController:(UIViewController *)controller animation:(UIModalTransitionStyle)transition;
- (id)initWithViewController:(UIViewController *)controller animation:(UIModalTransitionStyle)transition delay:(NSTimeInterval)seconds;

@end
