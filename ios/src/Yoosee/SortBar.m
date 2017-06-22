//
//  SortBar.m
//  Yoosee
//
//  Created by guojunyi on 14-5-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//






#import "SortBar.h"
#import "Constants.h"



@implementation SortBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(id)initWithDatas:(NSArray*)array frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        CGFloat itemHeight = frame.size.height/[array count];
        self.count = [array count];
        self.itemHeight = itemHeight;
        for(int i=0;i<[array count];i++){
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, i*itemHeight, frame.size.width, itemHeight)];
            label.tag = i+100;
            label.textColor = XWhite;
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = XBGAlpha;
            label.font = XFontBold_12;
            label.text = [array objectAtIndex:i];
            [self addSubview:label];
            [label release];
            
        }
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)onButtonTouch:(UIButton*)button{
    DLog(@"%i",button.tag-100);
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:self];
    int section = (int)(point.y/self.itemHeight);
    if(section<0){
        section = 0;
    }else if(section>=self.count){
        section = self.count-1;
    }
    DLog(@"%i",section);
    if(self.delegate){
        [self.delegate onSortBarChange:self index:section];
    }
    
    
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:self];
    int section = (int)(point.y/self.itemHeight);
    if(section<0){
        section = 0;
    }else if(section>=self.count){
        section = self.count-1;
    }
    DLog(@"%i",section);
    if(self.delegate){
        [self.delegate onSortBarChange:self index:section];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.delegate){
        [self.delegate onSortBarTouchEnd:self];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(self.delegate){
        [self.delegate onSortBarTouchEnd:self];
    }
}
@end
