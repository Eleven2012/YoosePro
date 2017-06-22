//
//  DefenceCell.m
//  Yoosee
//
//  Created by gwelltime on 14-11-13.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "DefenceCell.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation DefenceCell

-(void)dealloc{
    //{{--kongyulu at 20150919
    self.leftButton = nil;
    self.indexLabel  = nil;
    self.delImageView  = nil;
    self.learnCodeLabel  = nil;
    self.index  = nil;
    self.progressView  = nil;
    self.progressView2  = nil;
    //}}--kongyulu at 20150919
    [super dealloc];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define LEFT_BUTTON_WIDTH 30
#define LEFT_BUTTON_HEIGHT 30//defence area
#define INDEX_LABEL_WIDTH 20
#define LEARN_CODE_WIDTH 100
#define PROGRESS_WIDTH_HEIGHT 32
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth = self.backgroundView.frame.size.width;
    CGFloat cellHeight = self.backgroundView.frame.size.height;
    
    if (!self.leftButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(30, (cellHeight-LEFT_BUTTON_HEIGHT)/2.0, LEFT_BUTTON_WIDTH, LEFT_BUTTON_HEIGHT);//defence area
        [button setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateSelected];
        button.selected = self.isSelectedButton;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        self.leftButton = button;
        [self.leftButton setHidden:self.isLeftButtonHidden];
    }else{
        self.leftButton.frame = CGRectMake(30, (cellHeight-LEFT_BUTTON_HEIGHT)/2.0, LEFT_BUTTON_WIDTH, LEFT_BUTTON_HEIGHT);//defence area
        [self.leftButton setImage:[UIImage imageNamed:@"check_off.png"] forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateSelected];
        self.leftButton.selected = self.isSelectedButton;
        [self.leftButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.leftButton = self.leftButton;
        [self.contentView addSubview:self.leftButton];
        [self.leftButton setHidden:self.isLeftButtonHidden];
    }
    
    if (!self.indexLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        if (self.isLeftButtonHidden && self.isProgressViewHidden) {
            label.frame = CGRectMake(30, 0, LEFT_BUTTON_WIDTH, BAR_BUTTON_HEIGHT);
        }else{
           label.frame = CGRectMake(30+LEFT_BUTTON_WIDTH+10, 0, INDEX_LABEL_WIDTH, BAR_BUTTON_HEIGHT);
        }
        label.backgroundColor = [UIColor clearColor];
        label.text = self.index;
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        self.indexLabel = label;
        [label release];
        
    }else{
        if (self.isLeftButtonHidden && self.isProgressViewHidden) {
            self.indexLabel.frame = CGRectMake(30, 0, LEFT_BUTTON_WIDTH, BAR_BUTTON_HEIGHT);
        }else{
            self.indexLabel.frame = CGRectMake(30+LEFT_BUTTON_WIDTH+10, 0, INDEX_LABEL_WIDTH, BAR_BUTTON_HEIGHT);
        }
        self.indexLabel.backgroundColor = [UIColor clearColor];
        self.indexLabel.text = self.index;
        self.indexLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.indexLabel];
    }
    
    if (!self.learnCodeLabel) {
        UILabel *learnLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth-120, 0, LEARN_CODE_WIDTH, BAR_BUTTON_HEIGHT)];
        learnLabel.backgroundColor = [UIColor clearColor];
        learnLabel.text = NSLocalizedString(@"learn_code", nil);
        [self.contentView addSubview:learnLabel];
        self.learnCodeLabel = learnLabel;
        [learnLabel release];
        [self.learnCodeLabel setHidden:self.isLearnCodeLabelHidden];
    }else{
        self.learnCodeLabel.frame = CGRectMake(cellWidth-120, 0, LEARN_CODE_WIDTH, BAR_BUTTON_HEIGHT);
        self.learnCodeLabel.backgroundColor = [UIColor clearColor];
        self.learnCodeLabel.text = NSLocalizedString(@"learn_code", nil);
        [self.contentView addSubview:self.learnCodeLabel];
        [self.learnCodeLabel setHidden:self.isLearnCodeLabelHidden];
    }
    
    if (!self.delImageView) {
        UIImage *image = [UIImage imageNamed:@"ic_delete_item.png"];//defence area
        
        UIImageView *delImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth-image.size.width-30, (cellHeight-image.size.height)/2, image.size.width, image.size.height)];
        delImageView.image = image;
        [self.contentView addSubview:delImageView];
        self.delImageView = delImageView;
        [delImageView release];
        [self.delImageView setHidden:self.isDelImageViewHidden];
    }else{
         UIImage *image = [UIImage imageNamed:@"ic_delete_item.png"];//defence area
        
        self.delImageView.frame = CGRectMake(cellWidth-image.size.width-30, (cellHeight-image.size.height)/2, image.size.width, image.size.height);
        self.delImageView.image = image;
        [self.contentView addSubview:self.delImageView];
        [self.delImageView setHidden:self.isDelImageViewHidden];
    }
    
    
    if(!self.isProgressViewHidden){
        if(!self.progressView){
            UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            progressView.frame = CGRectMake(30, 0, LEFT_BUTTON_WIDTH, BAR_BUTTON_HEIGHT);
            [progressView setHidden:self.isProgressViewHidden];
            [self.contentView addSubview:progressView];
            [progressView startAnimating];
            self.progressView = progressView;
            [progressView release];
            [self.progressView setHidden:self.isProgressViewHidden];
        }else{
            self.progressView.frame = CGRectMake(30, 0, LEFT_BUTTON_WIDTH, BAR_BUTTON_HEIGHT);
            [self.progressView setHidden:self.isProgressViewHidden];
            [self.contentView addSubview:self.progressView];
            [self.progressView startAnimating];
        }
        
    }else{
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
    
    if(!self.isProgressViewHidden2){
        UIImage *image = [UIImage imageNamed:@"ic_delete_item.png"];//defence area
        if(!self.progressView2){
            UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            progressView.frame = CGRectMake(cellWidth-image.size.width-30, (cellHeight-image.size.height)/2, image.size.width, image.size.height);
            [progressView setHidden:self.isProgressViewHidden2];
            [self.contentView addSubview:progressView];
            [progressView startAnimating];
            self.progressView2 = progressView;
            [progressView release];
            [self.progressView2 setHidden:self.isProgressViewHidden2];
        }else{
            self.progressView2.frame = CGRectMake(cellWidth-image.size.width-30, (cellHeight-image.size.height)/2, image.size.width, image.size.height);
            [self.progressView2 setHidden:self.isProgressViewHidden2];
            [self.contentView addSubview:self.progressView2];
            [self.progressView2 startAnimating];
        }
        
    }else{
        [self.progressView2 removeFromSuperview];
        self.progressView2 = nil;
    }
    
}

-(void)buttonClick:(UIButton *)button{
    if (self.delegate) {
        [self.delegate defenceCell:self section:self.section row:self.row];
    }
}

-(void)setLeftButtonHidden:(BOOL)hidden{
    self.isLeftButtonHidden = hidden;
    if (self.leftButton) {
        [self.leftButton setHidden:hidden];
    }
}
-(void)setDelImageViewHidden:(BOOL)hidden
{
    self.isDelImageViewHidden = hidden;
    if (self.delImageView) {
        [self.delImageView setHidden:hidden];
    }
}
-(void)setLearnCodeLabelHidden:(BOOL)hidden{
    self.isLearnCodeLabelHidden = hidden;
    if (self.learnCodeLabel) {
        [self.learnCodeLabel setHidden:hidden];
    }
}
-(void)setProgressViewHidden:(BOOL)hidden{
    self.isProgressViewHidden = hidden;
    if(self.progressView){
        [self.progressView setHidden:hidden];
        
    }
}
-(void)setProgressViewHidden2:(BOOL)hidden{
    self.isProgressViewHidden2 = hidden;
    if(self.progressView2){
        [self.progressView2 setHidden:hidden];
        
    }
}

@end
