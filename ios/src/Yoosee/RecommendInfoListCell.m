//
//  RecommendInfoListCell.m
//  Yoosee
//
//  Created by gwelltime on 15-1-19.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "RecommendInfoListCell.h"
#import "Constants.h"
#import "UIImageView+AFNetworking.h"
#import "Utils.h"

@implementation RecommendInfoListCell
-(void)dealloc{
    [self.titleLabel release];
    [self.timeLabel release];
    [self.imgView release];
    [self.contentLabel release];
    
    [self.titleString release];
    [self.timeString release];
    [self.imageURLString release];
    [self.contentString release];
    [super dealloc];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define IMAGEVIEW_WIDTH 300
#define IMAGEVIEW_HEIGHT 170
-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.backgroundView.frame.size.width;
    //CGFloat height = self.backgroundView.frame.size.height;
    
    //标题
    CGFloat titleTextWidth = [Utils getStringWidthWithString:self.titleString font:XFontBold_16 maxWidth:width-10];
    CGFloat titleTextHeight = [Utils getStringHeightWithString:self.titleString font:XFontBold_16 maxWidth:width-10];
    if (!self.titleLabel) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, titleTextWidth, titleTextHeight)];
        
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = XBlack;
        titleLabel.backgroundColor = XBGAlpha;
        [titleLabel setFont:XFontBold_16];
        titleLabel.numberOfLines = 0;
        titleLabel.text = self.titleString;
        
        
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        [titleLabel release];
    }else{
        self.titleLabel.frame = CGRectMake(10, 10, titleTextWidth, titleTextHeight);
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.textColor = XBlack;
        self.titleLabel.backgroundColor = XBGAlpha;
        [self.titleLabel setFont:XFontBold_16];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.text = self.titleString;
        
        [self.contentView addSubview:self.titleLabel];
    }
    
    //时间
    CGFloat timeTextWidth = [Utils getStringWidthWithString:self.timeString font:XFontBold_16 maxWidth:width-10];
    CGFloat timeTextHeight = [Utils getStringHeightWithString:self.timeString font:XFontBold_16 maxWidth:width-10];
    if (!self.timeLabel) {
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.titleLabel.frame.origin.y+titleTextHeight+10, timeTextWidth, timeTextHeight)];
        
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.textColor = XBlack;
        timeLabel.backgroundColor = XBGAlpha;
        [timeLabel setFont:XFontBold_16];
        timeLabel.numberOfLines = 0;
        timeLabel.text = self.timeString;
        
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        [timeLabel release];
    }else{
        self.timeLabel.frame = CGRectMake(10, self.titleLabel.frame.origin.y+titleTextHeight+10, timeTextWidth, timeTextHeight);
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.textColor = XBlack;
        self.timeLabel.backgroundColor = XBGAlpha;
        [self.timeLabel setFont:XFontBold_16];
        self.timeLabel.numberOfLines = 0;
        self.timeLabel.text = self.timeString;
        
        [self.contentView addSubview:self.timeLabel];
    }
    
    //图片
    if (!self.imgView) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.timeLabel.frame.origin.y+timeTextHeight+10, IMAGEVIEW_WIDTH, IMAGEVIEW_HEIGHT)];
        [imgView setImageWithURL:[NSURL URLWithString:self.imageURLString]];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView addSubview:imgView];
        self.imgView = imgView;
        [imgView release];
    }else{
        self.imgView.frame = CGRectMake(10, self.timeLabel.frame.origin.y+timeTextHeight+10, IMAGEVIEW_WIDTH, IMAGEVIEW_HEIGHT);
        [self.imgView setImageWithURL:[NSURL URLWithString:self.imageURLString]];
        self.imgView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView addSubview:self.imgView];
    }
    
    //内容
    CGFloat contentTextWidth = [Utils getStringWidthWithString:self.contentString font:XFontBold_16 maxWidth:width-10];
    CGFloat contentTextHeight = [Utils getStringHeightWithString:self.contentString font:XFontBold_16 maxWidth:width-10];
    if (!self.contentLabel) {
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.imgView.frame.origin.y+IMAGEVIEW_HEIGHT+10, contentTextWidth, contentTextHeight)];
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.textColor = XBlack;
        contentLabel.backgroundColor = XBGAlpha;
        [contentLabel setFont:XFontBold_16];
        contentLabel.numberOfLines = 0;
        contentLabel.text = self.contentString;
        
        [self.contentView addSubview:contentLabel];
        self.contentLabel = contentLabel;
        [contentLabel release];
    }else{
        self.contentLabel.frame = CGRectMake(10, self.imgView.frame.origin.y+IMAGEVIEW_HEIGHT+10, contentTextWidth, contentTextHeight);
        self.contentLabel.textAlignment = NSTextAlignmentLeft;
        self.contentLabel.textColor = XBlack;
        self.contentLabel.backgroundColor = XBGAlpha;
        [self.contentLabel setFont:XFontBold_16];
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.text = self.contentString;
        
        [self.contentView addSubview:self.contentLabel];
    }
    
    // 如果状态是已读 那么显示灰色 否则黑色
    if (self.isReadCell) {
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.timeLabel.textColor = [UIColor lightGrayColor];
        self.contentLabel.textColor = [UIColor lightGrayColor];
    }
    else
    {
        self.titleLabel.textColor = [UIColor blackColor];
        self.timeLabel.textColor = [UIColor blackColor];
        self.contentLabel.textColor = [UIColor blackColor];
    }
}

@end
