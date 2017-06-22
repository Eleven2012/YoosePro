//
//  TabView.h
//  Yoosee
//
//  Created by wutong on 15-2-3.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol tabviewDelegate <NSObject>
-(void)tabViewSetPage:(int)index;
@end

@interface TabView : UIView
{
    UIButton* _btn[2];
    UIView* _line[2];
    
    int _currentPage;
}
- (void)setBtnIndex:(int)index text:(NSString*)text;
@property (nonatomic, assign) id<tabviewDelegate> delegate;
@end
