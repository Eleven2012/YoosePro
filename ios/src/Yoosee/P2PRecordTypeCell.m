//
//  P2PRecordTypeCell.m
//  Yoosee
//
//  Created by guojunyi on 14-5-16.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "P2PRecordTypeCell.h"
#import "Constants.h"
#import "RadioButton.h"
@implementation P2PRecordTypeCell
-(void)dealloc{

    [self.radio1 release];
    [self.radio2 release];
    [self.radio3 release];
    [super dealloc];
}

    
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth = self.backgroundView.frame.size.width;
    CGFloat cellHeight = self.backgroundView.frame.size.height;
 
    
    if(!self.radio1){
        RadioButton *radio1 = [[RadioButton alloc] initWithFrame:CGRectMake(30, 0, cellWidth/2, cellHeight/3)];
        [radio1 setText:NSLocalizedString(@"manual_record", nil)];
        [self.contentView addSubview:radio1];
        self.radio1 = radio1;
        [radio1 release];
        
        if(self.selectedIndex==0){
            [self.radio1 setSelected:YES];
        }else{
            [self.radio1 setSelected:NO];
        }
    }else{
        self.radio1.frame = CGRectMake(30, 0, cellWidth/2, cellHeight/3);
        [self.contentView addSubview:self.radio1];
        if(self.selectedIndex==0){
            [self.radio1 setSelected:YES];
        }else{
            [self.radio1 setSelected:NO];
        }
    }
    
    if(!self.radio2){
        RadioButton *radio2 = [[RadioButton alloc] initWithFrame:CGRectMake(30, cellHeight/3, cellWidth/2, cellHeight/3)];
        [radio2 setText:NSLocalizedString(@"alarm_record", nil)];
        [self.contentView addSubview:radio2];
        self.radio2 = radio2;
        [radio2 release];
        if(self.selectedIndex==1){
            [self.radio2 setSelected:YES];
        }else{
            [self.radio2 setSelected:NO];
        }
    }else{
        self.radio2.frame = CGRectMake(30, cellHeight/3, cellWidth/2, cellHeight/3);
        [self.contentView addSubview:self.radio2];
        if(self.selectedIndex==1){
            [self.radio2 setSelected:YES];
        }else{
            [self.radio2 setSelected:NO];
        }
    }
    
    if(!self.radio3){
        RadioButton *radio3 = [[RadioButton alloc] initWithFrame:CGRectMake(30, cellHeight/3*2, cellWidth/2, cellHeight/3)];
        [radio3 setText:NSLocalizedString(@"timer_record", nil)];
        [self.contentView addSubview:radio3];
        self.radio3 = radio3;
        [radio3 release];
        if(self.selectedIndex==2){
            [self.radio3 setSelected:YES];
        }else{
            [self.radio3 setSelected:NO];
        }
    }else{
        self.radio3.frame = CGRectMake(30, cellHeight/3*2, cellWidth/2, cellHeight/3);
        [self.contentView addSubview:self.radio3];
        if(self.selectedIndex==2){
            [self.radio3 setSelected:YES];
        }else{
            [self.radio3 setSelected:NO];
        }
    }
}
@end
