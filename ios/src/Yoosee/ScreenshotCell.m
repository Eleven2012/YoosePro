//
//  ScreenshotCell.m
//  Yoosee
//
//  Created by guojunyi on 14-4-3.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ScreenshotCell.h"
#import "Constants.h"
@implementation ScreenshotCell
-(void)dealloc{
    [self.filePath1 release];
    [self.filePath2 release];
    [self.filePath3 release];
    [self.backImgView1 release];
    [self.backImgView2 release];
    [self.backImgView3 release];
    [self.backButton1 release];
    [self.backButton2 release];
    [self.backButton3 release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
#define BORDER_WIDTH 5
#define VERTICAL_MARGIN 10
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat itemHeight = height-VERTICAL_MARGIN*2;
    CGFloat itemWidth = itemHeight*4/3;
    CGFloat horizontalMargin = (width-itemWidth*3)/4;
    DLog(@"%@",self.filePath1);
    if(!self.backButton1){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 0;
        button.backgroundColor = XWhite;
        button.frame = CGRectMake(horizontalMargin*3+itemWidth*2, VERTICAL_MARGIN, itemWidth, itemHeight);
        UIImage *buttonBackImg_p = [UIImage imageNamed:@"bg_normal_cell_p.png"];
        buttonBackImg_p = [buttonBackImg_p stretchableImageWithLeftCapWidth:buttonBackImg_p.size.width*0.5 topCapHeight:buttonBackImg_p.size.height*0.5];
        
        [button setBackgroundImage:buttonBackImg_p forState:UIControlStateHighlighted];
        button.frame = CGRectMake(horizontalMargin, VERTICAL_MARGIN, itemWidth, itemHeight);
        [button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        self.backButton1 = button;
        
        UIImageView *backImgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(BORDER_WIDTH,BORDER_WIDTH, itemWidth-BORDER_WIDTH*2, itemHeight-BORDER_WIDTH*2)];
        backImgView1.contentMode = UIViewContentModeScaleAspectFit;
        [self loading1];
        [self.backButton1 addSubview:backImgView1];
        self.backImgView1 = backImgView1;
        [backImgView1 release];
        
        [self.contentView addSubview:self.backButton1];
    }else{
        self.backButton1.frame = CGRectMake(horizontalMargin, VERTICAL_MARGIN, itemWidth, itemHeight);
        self.backImgView1.frame = CGRectMake(BORDER_WIDTH,BORDER_WIDTH, itemWidth-BORDER_WIDTH*2, itemHeight-BORDER_WIDTH*2);
        //self.backImgView1.image = [UIImage imageWithContentsOfFile:self.filePath1];
        [self loading1];
        
        [self.contentView addSubview:self.backButton1];
        
    }
    
    if(!self.backButton2){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 1;
        button.backgroundColor = XWhite;
        button.frame = CGRectMake(horizontalMargin*3+itemWidth*2, VERTICAL_MARGIN, itemWidth, itemHeight);
        UIImage *buttonBackImg_p = [UIImage imageNamed:@"bg_normal_cell_p.png"];
        buttonBackImg_p = [buttonBackImg_p stretchableImageWithLeftCapWidth:buttonBackImg_p.size.width*0.5 topCapHeight:buttonBackImg_p.size.height*0.5];
        
        [button setBackgroundImage:buttonBackImg_p forState:UIControlStateHighlighted];
        button.frame = CGRectMake(horizontalMargin*2+itemWidth, VERTICAL_MARGIN, itemWidth, itemHeight);
        [button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        self.backButton2 = button;
        
        UIImageView *backImgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(BORDER_WIDTH,BORDER_WIDTH, itemWidth-BORDER_WIDTH*2, itemHeight-BORDER_WIDTH*2)];
        backImgView2.contentMode = UIViewContentModeScaleAspectFit;
        //backImgView2.image = [UIImage imageWithContentsOfFile:self.filePath2];
        [self loading2];
        [self.backButton2 addSubview:backImgView2];
        self.backImgView2 = backImgView2;
        [backImgView2 release];
        

    }else{
        self.backButton2.frame = CGRectMake(horizontalMargin*2+itemWidth, VERTICAL_MARGIN, itemWidth, itemHeight);
        self.backImgView2.frame = CGRectMake(BORDER_WIDTH,BORDER_WIDTH, itemWidth-BORDER_WIDTH*2, itemHeight-BORDER_WIDTH*2);
        //self.backImgView2.image = [UIImage imageWithContentsOfFile:self.filePath2];
        [self loading2];
    }
    
    if(!self.backButton3){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 2;
        button.backgroundColor = XWhite;
        button.frame = CGRectMake(horizontalMargin*3+itemWidth*2, VERTICAL_MARGIN, itemWidth, itemHeight);
        UIImage *buttonBackImg_p = [UIImage imageNamed:@"bg_normal_cell_p.png"];
        buttonBackImg_p = [buttonBackImg_p stretchableImageWithLeftCapWidth:buttonBackImg_p.size.width*0.5 topCapHeight:buttonBackImg_p.size.height*0.5];
        
        [button setBackgroundImage:buttonBackImg_p forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        self.backButton3 = button;
        
        UIImageView *backImgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(BORDER_WIDTH,BORDER_WIDTH, itemWidth-BORDER_WIDTH*2, itemHeight-BORDER_WIDTH*2)];
        backImgView3.contentMode = UIViewContentModeScaleAspectFit;
        //backImgView3.image = [UIImage imageWithContentsOfFile:self.filePath3];
        [self loading3];
        [self.backButton3 addSubview:backImgView3];
        self.backImgView3 = backImgView3;
        [backImgView3 release];
        
       
    }else{
        self.backButton3.frame = CGRectMake(horizontalMargin*3+itemWidth*2, VERTICAL_MARGIN, itemWidth, itemHeight);
        self.backImgView3.frame = CGRectMake(BORDER_WIDTH,BORDER_WIDTH, itemWidth-BORDER_WIDTH*2, itemHeight-BORDER_WIDTH*2);
        //self.backImgView3.image = [UIImage imageWithContentsOfFile:self.filePath3];
        [self loading3];
    }
    
    
    [self.contentView addSubview:self.backButton2];
    [self.contentView addSubview:self.backButton3];
    
    if(!self.filePath1||[self.filePath1 isEqualToString:@""]){
        [self.backButton1 setHidden:YES];
    }else{
        [self.backButton1 setHidden:NO];
    }
    
    if(!self.filePath2||[self.filePath2 isEqualToString:@""]){
        [self.backButton2 setHidden:YES];
    }else{
        [self.backButton2 setHidden:NO];
    }
    
    if(!self.filePath3||[self.filePath3 isEqualToString:@""]){
        [self.backButton3 setHidden:YES];
    }else{
        [self.backButton3 setHidden:NO];
    }
}


-(void)onButtonPress:(UIButton*)button{
    if(self.delegate){
        [self.delegate onItemPress:self row:self.row index:button.tag];
    }
}

-(void)loading1{
    if(!self.isLoading1){
        self.isLoading1 = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:self.filePath1];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backImgView1.image = image;
            });
        });
    }
}

-(void)loading2{
    if(!self.isLoading2){
        self.isLoading2 = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:self.filePath2];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backImgView2.image = image;
            });
        });
    }
}

-(void)loading3{
    if(!self.isLoading3){
        self.isLoading3 = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:self.filePath3];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.backImgView3.image = image;
            });
        });
    }
}
@end
