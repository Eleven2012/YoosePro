//
//  TabView.m
//  Yoosee
//
//  Created by wutong on 15-2-3.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "TabView.h"
#import "Constants.h"

#define LINE_HEIGHT 2

@implementation TabView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setBtnIndex:(int)index text:(NSString*)text
{
    CGFloat width = self.bounds.size.width;
    CGFloat heigth = self.bounds.size.height;
    
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(index*width/2, 0, width/2, heigth)];
    [btn setTitle:text forState:UIControlStateNormal];
    if (index == 0) {
        [btn setTitleColor:customRedCorlor forState:UIControlStateNormal];
    }
    else
    {
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    btn.tag = 101+index;
    [btn addTarget:self action:@selector(onBtnPress:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn];
    _btn[index] = btn;
    [btn release];
    
    UIView* lineView = [[UIView alloc]initWithFrame:CGRectMake(index*width/2, heigth-LINE_HEIGHT, width/2, LINE_HEIGHT)];
    lineView.backgroundColor = (index == 0) ? customRedCorlor : [UIColor clearColor];
    [self addSubview:lineView];
    _line[index] = lineView;
    [lineView release];

}

-(void)onBtnPress:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    if (btn.tag == 101) {
        if (_currentPage == 0) {
            return;
        }
        _line[0].backgroundColor = customRedCorlor;
        [_btn[0] setTitleColor:customRedCorlor forState:UIControlStateNormal];
        
        _line[1].backgroundColor = [UIColor clearColor];
        [_btn[1] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _currentPage = 0;
    }
    else if (btn.tag == 102)
    {
        if (_currentPage == 1) {
            return;
        }
        _line[0].backgroundColor = [UIColor clearColor];
        [_btn[0] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        _line[1].backgroundColor = customRedCorlor;
        [_btn[1] setTitleColor:customRedCorlor forState:UIControlStateNormal];
        _currentPage = 1;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabViewSetPage:)]) {
        [self.delegate tabViewSetPage:_currentPage];
    }
}

@end
