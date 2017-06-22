//
//  P2PBuzzerCell.m
//  Yoosee
//
//  Created by guojunyi on 14-5-15.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "P2PBuzzerCell.h"
#import "Constants.h"
#import "RadioButton.h"
@implementation P2PBuzzerCell
-(void)dealloc{
    [self.leftLabelText release];
    [self.leftLabelView release];
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
    
    if(!self.leftLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, cellWidth-30*2, cellHeight/2)];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_14];
        textLabel.text = self.leftLabelText;
        [self.contentView addSubview:textLabel];
        self.leftLabelView = textLabel;
        [textLabel release];
        
    }else{
        self.leftLabelView.frame = CGRectMake(30, 0, cellWidth-30*2, cellHeight/2);
        self.leftLabelView.textAlignment = NSTextAlignmentLeft;
        self.leftLabelView.textColor = XBlack;
        self.leftLabelView.backgroundColor = XBGAlpha;
        [self.leftLabelView setFont:XFontBold_14];
        self.leftLabelView.text = self.leftLabelText;
        [self.contentView addSubview:self.leftLabelView];
        
    }
    
    if(!self.radio1){
        RadioButton *radio1 = [[RadioButton alloc] initWithFrame:CGRectMake(30, cellHeight/2, (cellWidth-30*2)/3, cellHeight/2)];
        [radio1 setText:@"1"];
        [self.contentView addSubview:radio1];
        self.radio1 = radio1;
        [radio1 release];
    }else{
        self.radio1.frame = CGRectMake(30, cellHeight/2, (cellWidth-30*2)/3, cellHeight/2);
        [self.contentView addSubview:self.radio1];
    }
    
    if(!self.radio2){
        RadioButton *radio2 = [[RadioButton alloc] initWithFrame:CGRectMake(30+(cellWidth-30*2)/3, cellHeight/2, (cellWidth-30*2)/3, cellHeight/2)];
        [radio2 setText:@"2"];
        [self.contentView addSubview:radio2];
        self.radio2 = radio2;
        [radio2 release];
    }else{
        self.radio2.frame = CGRectMake(30+(cellWidth-30*2)/3, cellHeight/2, (cellWidth-30*2)/3, cellHeight/2);
        [self.contentView addSubview:self.radio2];
    }
    
    if(!self.radio3){
        RadioButton *radio3 = [[RadioButton alloc] initWithFrame:CGRectMake(30+(cellWidth-30*2)/3*2, cellHeight/2, (cellWidth-30*2)/3, cellHeight/2)];
        [radio3 setText:@"3"];
        [self.contentView addSubview:radio3];
        self.radio3 = radio3;
        [radio3 release];
    }else{
        self.radio3.frame = CGRectMake(30+(cellWidth-30*2)/3*2, cellHeight/2, (cellWidth-30*2)/3, cellHeight/2);
        [self.contentView addSubview:self.radio3];
    }
    
    if(self.selectedIndex==0){
        [self.radio1 setSelected:YES];
        [self.radio2 setSelected:NO];
        [self.radio3 setSelected:NO];
    }else if(self.selectedIndex==1){
        [self.radio1 setSelected:NO];
        [self.radio2 setSelected:YES];
        [self.radio3 setSelected:NO];
    }else if(self.selectedIndex==2){
        [self.radio1 setSelected:NO];
        [self.radio2 setSelected:NO];
        [self.radio3 setSelected:YES];
    }
}
@end
