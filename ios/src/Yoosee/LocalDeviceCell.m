//
//  LocalDeviceCell.m
//  Yoosee
//
//  Created by guojunyi on 14-7-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "LocalDeviceCell.h"
#import "Constants.h"
@implementation LocalDeviceCell

-(void)dealloc{
    [self.leftImage release];
    [self.leftImageView release];
    [self.rightImage release];
    [self.rightImageView release];
    [self.contentText release];
    [self.contentLabel release];
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

#define LEFT_IMAGE_VIEW_WIDTH_HEIGHT 24
#define RIGHT_IMAGE_VIEW_WIDTH_HEIGHT 18
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth = self.backgroundView.frame.size.width;
    CGFloat cellHeight = self.backgroundView.frame.size.height;
    
    if(!self.leftImageView){
        UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (cellHeight-LEFT_IMAGE_VIEW_WIDTH_HEIGHT)/2, LEFT_IMAGE_VIEW_WIDTH_HEIGHT, LEFT_IMAGE_VIEW_WIDTH_HEIGHT)];
        leftImageView.image = [UIImage imageNamed:self.leftImage];
        [self.contentView addSubview:leftImageView];
        self.leftImageView = leftImageView;
        [leftImageView release];
    }else{
        self.leftImageView.frame = CGRectMake(10, (cellHeight-LEFT_IMAGE_VIEW_WIDTH_HEIGHT)/2, LEFT_IMAGE_VIEW_WIDTH_HEIGHT, LEFT_IMAGE_VIEW_WIDTH_HEIGHT);
        self.leftImageView.image = [UIImage imageNamed:self.leftImage];
        [self.contentView addSubview:self.leftImageView];
    }
    
    if(!self.rightImageView){
        UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth-10-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT, (cellHeight-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT)/2, RIGHT_IMAGE_VIEW_WIDTH_HEIGHT, RIGHT_IMAGE_VIEW_WIDTH_HEIGHT)];
        rightImageView.image = [UIImage imageNamed:self.rightImage];
        [self.contentView addSubview:rightImageView];
        self.rightImageView = rightImageView;
        [rightImageView release];
    }else{
        self.rightImageView.frame = CGRectMake(cellWidth-10-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT, (cellHeight-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT)/2, RIGHT_IMAGE_VIEW_WIDTH_HEIGHT, RIGHT_IMAGE_VIEW_WIDTH_HEIGHT);
        self.rightImageView.image = [UIImage imageNamed:self.rightImage];
        [self.contentView addSubview:self.rightImageView];
    }
    
    if(!self.contentLabel){
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+self.leftImageView.frame.origin.x+self.leftImageView.frame.size.width, 0, cellWidth-10*2-LEFT_IMAGE_VIEW_WIDTH_HEIGHT-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT, cellHeight)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.textColor = XBlack;
        contentLabel.font = XFontBold_16;
        contentLabel.text = self.contentText;
        self.contentLabel = contentLabel;
        [self.contentView addSubview:self.contentLabel];
        [contentLabel release];
    }else{
        self.contentLabel.frame = CGRectMake(10+self.leftImageView.frame.origin.x+self.leftImageView.frame.size.width, 0, cellWidth-10*2-LEFT_IMAGE_VIEW_WIDTH_HEIGHT-RIGHT_IMAGE_VIEW_WIDTH_HEIGHT, cellHeight);
        self.contentLabel.text = self.contentText;
        [self.contentView addSubview:self.contentLabel];
    }
}
@end
