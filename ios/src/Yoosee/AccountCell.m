//
//  AccountCell.m
//  Yoosee
//
//  Created by guojunyi on 14-4-25.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "AccountCell.h"
#import "Constants.h"

@implementation AccountCell

-(void)dealloc{

    [self.textLabelView release];

    [self.rightIconView release];
    [self.rightLabelView release];
    
    [self.labelText release];
    [self.rightIcon release];
    [self.rightText release];
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

#define LEFT_LABEL_WIDTH 100
-(void)layoutSubviews{
    [super layoutSubviews];
    
    
    CGFloat cellWidth = self.backgroundView.frame.size.width;
    
    
    if(self.rightIcon&&self.rightIcon.length>0){
        if(!self.rightIconView){
            UIImageView *right_icon = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth-30-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)];
            right_icon.contentMode = UIViewContentModeScaleAspectFit;
            UIImage *rightIconImg = [UIImage imageNamed:self.rightIcon];
            right_icon.image = rightIconImg;
            [self.contentView addSubview:right_icon];
            if(self.isHiddenRightIcon){
                [right_icon setHidden:YES];
            }else{
                [right_icon setHidden:NO];
            }
            self.rightIconView = right_icon;
            [right_icon release];
        }else{
            self.rightIconView.frame = CGRectMake(cellWidth-30-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT,(BAR_BUTTON_HEIGHT-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT)/2,BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT);
            self.rightIconView.contentMode = UIViewContentModeScaleAspectFit;
            UIImage *rightIconImg = [UIImage imageNamed:self.rightIcon];
            self.rightIconView.image = rightIconImg;
            if(self.isHiddenRightIcon){
                [self.rightIconView setHidden:YES];
            }else{
                [self.rightIconView setHidden:NO];
            }
            [self.contentView addSubview:self.rightIconView];
        }
    }
    
    if(self.labelText&&self.labelText.length>0){
        if(!self.textLabelView){
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT)];
            textLabel.textAlignment = NSTextAlignmentLeft;
            textLabel.textColor = XBlack;
            textLabel.backgroundColor = XBGAlpha;
            [textLabel setFont:XFontBold_16];
            textLabel.text = self.labelText;
            [self.contentView addSubview:textLabel];
            self.textLabelView = textLabel;
            [textLabel release];
        }else{
            self.textLabelView.frame = CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT);
            self.textLabelView.textAlignment = NSTextAlignmentLeft;
            self.textLabelView.textColor = XBlack;
            self.textLabelView.backgroundColor = XBGAlpha;
            [self.textLabelView setFont:XFontBold_16];
            self.textLabelView.text = self.labelText;
            [self.contentView addSubview:self.textLabelView];
        }
    }
    
    if(!self.rightLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30+LEFT_LABEL_WIDTH+10, 0, cellWidth-(30+10)*2-LEFT_LABEL_WIDTH-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_HEIGHT)];
        textLabel.textAlignment = NSTextAlignmentRight;
        textLabel.textColor = [UIColor grayColor];
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_14];
        textLabel.text = self.rightText;
        [self.contentView addSubview:textLabel];
        if(self.isHiddenRightLabel){
            [textLabel setHidden:YES];
        }else{
            [textLabel setHidden:NO];
        }
        self.rightLabelView = textLabel;
        [textLabel release];
    }else{
        self.rightLabelView.frame = CGRectMake(30+LEFT_LABEL_WIDTH+10, 0, cellWidth-(30+10)*2-LEFT_LABEL_WIDTH-BAR_BUTTON_RIGHT_ICON_WIDTH_AND_HEIGHT, BAR_BUTTON_HEIGHT);
        self.rightLabelView.textAlignment = NSTextAlignmentRight;
        self.rightLabelView.textColor = [UIColor grayColor];
        self.rightLabelView.backgroundColor = XBGAlpha;
        [self.rightLabelView setFont:XFontBold_14];
        self.rightLabelView.text = self.rightText;
        if(self.isHiddenRightLabel){
            [self.rightLabelView setHidden:YES];
        }else{
            [self.rightLabelView setHidden:NO];
        }
        [self.contentView addSubview:self.rightLabelView];
    }
    
    if(!(self.rightText&&self.rightText.length>0)){
        self.rightLabelView.text = NSLocalizedString(@"unbind", nil);
    }
    
    
}

@end
