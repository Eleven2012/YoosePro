//
//  ChooseCountryCell.m
//  Yoosee
//
//  Created by guojunyi on 14-5-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ChooseCountryCell.h"
#import "Constants.h"

@implementation ChooseCountryCell

-(void)dealloc{
    [self.leftLabelText release];
    [self.leftLabelView release];
    [self.rightLabelText release];
    [self.rightLabelView release];
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

#define RIGHT_MARGIN 50
#define RIGHT_LABEL_WIDTH 80
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth = self.backgroundView.frame.size.width;
    CGFloat cellHeight = self.backgroundView.frame.size.height;
    
    if(!self.leftLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, cellWidth-RIGHT_LABEL_WIDTH-RIGHT_MARGIN-30, cellHeight)];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.leftLabelText;
        [self.contentView addSubview:textLabel];
        self.leftLabelView = textLabel;
        [textLabel release];
        
        
    }else{
        self.leftLabelView.frame = CGRectMake(30, 0, cellWidth-RIGHT_LABEL_WIDTH-RIGHT_MARGIN-30, cellHeight);
        self.leftLabelView.textAlignment = NSTextAlignmentLeft;
        self.leftLabelView.textColor = XBlack;
        self.leftLabelView.backgroundColor = XBGAlpha;
        [self.leftLabelView setFont:XFontBold_16];
        self.leftLabelView.text = self.leftLabelText;
        [self.contentView addSubview:self.leftLabelView];
        
    }
    
    
    if(!self.rightLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth-RIGHT_MARGIN-RIGHT_LABEL_WIDTH, 0, RIGHT_LABEL_WIDTH, cellHeight)];
        textLabel.textAlignment = NSTextAlignmentRight;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_14];
        textLabel.text = self.rightLabelText;
        [self.contentView addSubview:textLabel];
        self.rightLabelView = textLabel;
        [textLabel release];
        
    }else{
        self.rightLabelView.frame = CGRectMake(cellWidth-RIGHT_MARGIN-RIGHT_LABEL_WIDTH, 0, RIGHT_LABEL_WIDTH, cellHeight);
        self.rightLabelView.textAlignment = NSTextAlignmentRight;
        self.rightLabelView.textColor = XBlack;
        self.rightLabelView.backgroundColor = XBGAlpha;
        [self.rightLabelView setFont:XFontBold_14];
        self.rightLabelView.text = self.rightLabelText;
        [self.contentView addSubview:self.rightLabelView];
        
    }
    
}
@end
