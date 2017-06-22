//
//  P2PDefenceAreaCell.m
//  Yoosee
//
//  Created by guojunyi on 14-5-20.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "P2PDefenceAreaCell.h"
#import "Constants.h"
@implementation P2PDefenceAreaCell

-(void)dealloc{
    [self.leftLabelText release];
    [self.leftLabelView release];
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

#define LEFT_LABEL_WIDTH 120
#define BUTTON_ITEM_WIDTH_AND_HEIGHT 32
#define PROGRESS_WIDTH_HEIGHT 32
#define SELECTED_COLOR [UIColor colorWithRed:120.0/255.0 green:201.0/255.0 blue:247.0/255.0 alpha:1.0]

#define UN_SELECTED_COLOR [UIColor colorWithRed:235.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0]
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWidth = self.backgroundView.frame.size.width;
    CGFloat cellHeight = self.backgroundView.frame.size.height;
    
    if(!self.leftLabelView){
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT)];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.textColor = XBlack;
        textLabel.backgroundColor = XBGAlpha;
        [textLabel setFont:XFontBold_16];
        textLabel.text = self.leftLabelText;
        [self.contentView addSubview:textLabel];
        self.leftLabelView = textLabel;
        [textLabel release];
        
        
    }else{
        self.leftLabelView.frame = CGRectMake(30, 0, LEFT_LABEL_WIDTH, BAR_BUTTON_HEIGHT);
        self.leftLabelView.textAlignment = NSTextAlignmentLeft;
        self.leftLabelView.textColor = XBlack;
        self.leftLabelView.backgroundColor = XBGAlpha;
        [self.leftLabelView setFont:XFontBold_16];
        self.leftLabelView.text = self.leftLabelText;
        [self.contentView addSubview:self.leftLabelView];
    }
    
    
    
    if(!self.customView){
        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, cellWidth-10*2, cellHeight)];
        
        int horizontal_margin = (customView.frame.size.width-BUTTON_ITEM_WIDTH_AND_HEIGHT*4)/5;
        int vertical_margin = (customView.frame.size.height-BUTTON_ITEM_WIDTH_AND_HEIGHT*2)/3;
        for(int i=0;i<8;i++){
            int row = i/4;
            int col = i%4;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i+100;
            button.layer.cornerRadius = 3.0;
            button.layer.borderWidth = 1.0;
            if([self.status count]==8){
                int state = [[self.status objectAtIndex:i] intValue];
                if(state==0){
                    button.backgroundColor = SELECTED_COLOR;
                }else{
                    button.backgroundColor = UN_SELECTED_COLOR;
                }
            }
            
            button.layer.borderColor = [[UIColor colorWithRed:235.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0] CGColor];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            button.frame = CGRectMake(horizontal_margin*(col+1)+BUTTON_ITEM_WIDTH_AND_HEIGHT*col, vertical_margin*(row+1)+BUTTON_ITEM_WIDTH_AND_HEIGHT*row, BUTTON_ITEM_WIDTH_AND_HEIGHT, BUTTON_ITEM_WIDTH_AND_HEIGHT);
            [button setTitle:[NSString stringWithFormat:@"%i",i+1] forState:UIControlStateNormal];
            [customView addSubview:button];
        }
        
        [self.contentView addSubview:customView];
        self.customView = customView;
        [customView release];
    }else{
        
        self.customView.frame = CGRectMake(10, 0, cellWidth-10*2, cellHeight);
        int horizontal_margin = (self.customView.frame.size.width-BUTTON_ITEM_WIDTH_AND_HEIGHT*4)/5;
        int vertical_margin = (self.customView.frame.size.height-BUTTON_ITEM_WIDTH_AND_HEIGHT*2)/3;
        for(int i=0;i<8;i++){
            UIButton *button = (UIButton*)[self.customView viewWithTag:i+100];
            
            
            if([self.status count]==8){
                
                int state = [[self.status objectAtIndex:i] intValue];
                if(state==0){
                    button.backgroundColor = SELECTED_COLOR;
                }else{
                    button.backgroundColor = UN_SELECTED_COLOR;
                }
            }
            
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.tag = i+100;
            button.layer.cornerRadius = 3.0;
            button.layer.borderWidth = 1.0;
            
            button.layer.borderColor = [[UIColor colorWithRed:235.0/255.0 green:208.0/255.0 blue:208.0/255.0 alpha:1.0] CGColor];
            
            int row = i/4;
            int col = i%4;
            button.frame = CGRectMake(horizontal_margin*(col+1)+BUTTON_ITEM_WIDTH_AND_HEIGHT*col, vertical_margin*(row+1)+BUTTON_ITEM_WIDTH_AND_HEIGHT*row, BUTTON_ITEM_WIDTH_AND_HEIGHT, BUTTON_ITEM_WIDTH_AND_HEIGHT);
        }
        
        [self.contentView addSubview:self.customView];
    }
    
    if(!self.progressView){
        UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        progressView.frame = CGRectMake(cellWidth-30-PROGRESS_WIDTH_HEIGHT, (cellHeight-PROGRESS_WIDTH_HEIGHT)/2, PROGRESS_WIDTH_HEIGHT, PROGRESS_WIDTH_HEIGHT);
        [self.contentView addSubview:progressView];
        [progressView startAnimating];
        self.progressView = progressView;
        [progressView release];
        [self.progressView setHidden:self.isProgressViewHidden];
    }else{
        self.progressView.frame = CGRectMake(cellWidth-30-PROGRESS_WIDTH_HEIGHT, (cellHeight-PROGRESS_WIDTH_HEIGHT)/2, PROGRESS_WIDTH_HEIGHT, PROGRESS_WIDTH_HEIGHT);
        [self.contentView addSubview:self.progressView];
        [self.progressView startAnimating];
        [self.progressView setHidden:self.isProgressViewHidden];
    }
    
    if(self.isShowCustomView){
        [self.customView setHidden:NO];
        [self.leftLabelView setHidden:YES];
    }else{
        [self.customView setHidden:YES];
        [self.leftLabelView setHidden:NO];
    }
}

-(void)onButtonPress:(UIButton*)button{
    if(self.delegate){
        if([[self.status objectAtIndex:button.tag-100] intValue]==0){
            [self.delegate onItemClicked:button group:self.group item:button.tag-100 state:YES];
        }else{
            [self.delegate onItemClicked:button group:self.group item:button.tag-100 state:NO];
        }
        
    }
}

-(void)setProgressViewHidden:(BOOL)hidden{
    self.isProgressViewHidden = hidden;
    if(self.progressView){
        [self.progressView setHidden:hidden];
    }
}
@end
