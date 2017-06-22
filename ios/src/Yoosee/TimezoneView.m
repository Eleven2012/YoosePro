//
//  TimezoneView.m
//  Yoosee
//
//  Created by guojunyi on 14-9-28.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "TimezoneView.h"

@implementation TimezoneView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _picker = [[IDJPickerView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) dataLoop:NO];
        _picker.delegate = self;
        [self addSubview:_picker];

        [_picker selectCell:0 inScroll:0];
       
        // Initialization code
    }
    return self;
}


-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    [_picker setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

//指定每一列的滚轮上的Cell的个数
- (NSUInteger)numberOfCellsInScroll:(NSUInteger)scroll {
    switch (scroll) {
        case 0:
            return 24;
            break;
        
        default:
            return 0;
            break;
    }
}

//指定每一列滚轮所占整体宽度的比例，以:分隔
- (NSString *)scrollWidthProportion {
    return @"1";
}

//指定有多少个Cell显示在可视区域
- (NSUInteger)numberOfCellsInVisible {
    return 3;
}

//为指定滚轮上的指定位置的Cell设置内容
- (void)viewForCell:(NSUInteger)cell inScroll:(NSUInteger)scroll reusingCell:(UITableViewCell *)tc {
    tc.textLabel.textAlignment=UITextAlignmentCenter;
    tc.selectionStyle=UITableViewCellSelectionStyleNone;
    [tc.textLabel setFont:[UIFont systemFontOfSize:12.0]];
    int value = cell-11;
    switch (scroll) {
        case 0:{
            if(value<0){
                tc.textLabel.text=[NSString stringWithFormat:@"UTC - %i",-value];
            }else{
                tc.textLabel.text=[NSString stringWithFormat:@"UTC + %i",value];
            }
            
            break;
        }
        
        
            
        default:
            break;
    }
}

//设置选中条的位置
- (NSUInteger)selectionPosition {
    return 1;
}


//当滚轮停止滚动的时候，通知调用者哪一列滚轮的哪一个Cell被选中
- (void)didSelectCell:(NSUInteger)cell inScroll:(NSUInteger)scroll {
    DLog("%ui %ui",cell,scroll);
    
    if(scroll==0){
        if(self.delegate!=nil){
            [self.delegate onTimezoneChange:cell];
        }
        _timezone = cell;
    }
}

@end
