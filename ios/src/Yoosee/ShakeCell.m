//
//  ShakeCell.m
//  Yoosee
//
//  Created by guojunyi on 14-5-23.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "ShakeCell.h"
#import "Constants.h"
#import "Utils.h"
#import "Contact.h"


@implementation ShakeCell

-(void)dealloc{
    [self.typeIcon release];
    [self.typeView release];
    [self.mainView release];
    [self.leftIconView release];
    [self.contactId release];
    [self.labelView release];
    [self.address release];
    [self.labelText release];
    [self.rightIcon release];
    [self.rightIconView release];
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

#define ITEM_WIDTH 268
#define LEFT_IMAGE_MARGIN 6
#define TYPE_ICON_MARGIN 10
#define RIGHT_ICON_MARGIN 18
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.backgroundView.frame.size.width;
    CGFloat height = self.backgroundView.frame.size.height;
    
    if(!self.mainView){
        UIButton *mainView = [UIButton buttonWithType:UIButtonTypeCustom];
        mainView.frame = CGRectMake((width-ITEM_WIDTH)/2, 0, ITEM_WIDTH, height);
        
        mainView.layer.borderColor = [[UIColor blackColor] CGColor];
        mainView.layer.borderWidth = 1.0;
        mainView.layer.cornerRadius = 5.0;
        mainView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        [mainView addTarget:self action:@selector(onSendButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addTarget:self action:@selector(lightButton:) forControlEvents:UIControlEventTouchDown];
        [mainView addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchCancel];
        [mainView addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
        [mainView addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
        
        
        UIImageView *left_icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, LEFT_IMAGE_MARGIN, (height-LEFT_IMAGE_MARGIN*2)*4/3, height-LEFT_IMAGE_MARGIN*2)];
        
        NSString *filePath = [Utils getHeaderFilePathWithId:self.contactId];
        UIImage *leftIconImg = [UIImage imageWithContentsOfFile:filePath];
        if(leftIconImg==nil){
            leftIconImg = [UIImage imageNamed:@"ic_header.png"];
        }
        
        
        left_icon.image = leftIconImg;
        left_icon.contentMode = UIViewContentModeScaleAspectFit;
        [self.mainView addSubview:left_icon];
        self.leftIconView = left_icon;
        [left_icon release];
        
        CGFloat rightIconViewHeight = mainView.frame.size.height-RIGHT_ICON_MARGIN*2;
        UIImageView *right_icon = [[UIImageView alloc] initWithFrame:CGRectMake(mainView.frame.size.width-10-rightIconViewHeight, RIGHT_ICON_MARGIN, rightIconViewHeight, rightIconViewHeight)];
        
        right_icon.image = [UIImage imageNamed:self.rightIcon];
        [mainView addSubview:right_icon];
        self.rightIconView = right_icon;
        [right_icon release];
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(self.leftIconView.frame.origin.x+self.leftIconView.frame.size.width, mainView.frame.size.height/2-self.rightIconView.frame.size.width, mainView.frame.size.width-10*2-self.leftIconView.frame.size.width, mainView.frame.size.height/2)];
        labelView.textAlignment = NSTextAlignmentCenter;
        labelView.textColor = [UIColor whiteColor];
        labelView.font = XFontBold_14;
        labelView.backgroundColor = XBGAlpha;
        labelView.text = self.labelText;
        [mainView addSubview:labelView];
        self.labelView = labelView;
        [labelView release];
        
        CGFloat typeViewHeight = mainView.frame.size.height/2-TYPE_ICON_MARGIN*2;
        UIImageView *typeView = [[UIImageView alloc] initWithFrame:CGRectMake(self.leftIconView.frame.origin.x+self.leftIconView.frame.size.width+(labelView.frame.size.width-typeViewHeight)/2,TYPE_ICON_MARGIN,typeViewHeight, typeViewHeight)];
        typeView.image = [UIImage imageNamed:self.typeIcon];
        [mainView addSubview:typeView];
        self.typeView = typeView;
        [typeView release];
        
        
        
        [self.contentView addSubview:mainView];
        self.mainView = mainView;
        
        
    }else{
        self.leftIconView.frame = CGRectMake(10, LEFT_IMAGE_MARGIN, (height-LEFT_IMAGE_MARGIN*2)*4/3, height-LEFT_IMAGE_MARGIN*2);
        
        NSString *filePath = [Utils getHeaderFilePathWithId:self.contactId];
        UIImage *leftIconImg = [UIImage imageWithContentsOfFile:filePath];
        if(leftIconImg==nil){
            leftIconImg = [UIImage imageNamed:@"ic_header.png"];
        }
        
        self.leftIconView.image = leftIconImg;
        
        
        CGFloat rightIconViewHeight = self.mainView.frame.size.height-RIGHT_ICON_MARGIN*2;
        self.rightIconView.frame = CGRectMake(self.mainView.frame.size.width-10-rightIconViewHeight, RIGHT_ICON_MARGIN, rightIconViewHeight, rightIconViewHeight);
        
        self.rightIconView.image = [UIImage imageNamed:self.rightIcon];
        
        
        
        
        
        self.labelView.frame = CGRectMake(self.leftIconView.frame.origin.x+self.leftIconView.frame.size.width, self.mainView.frame.size.height/2, self.mainView.frame.size.width-10*2-self.leftIconView.frame.size.width-self.rightIconView.frame.size.width, self.mainView.frame.size.height/2);
        self.labelView.text = self.labelText;
        
        CGFloat typeViewHeight = self.mainView.frame.size.height/2-TYPE_ICON_MARGIN*2;
        self.typeView.frame = CGRectMake(self.leftIconView.frame.origin.x+self.leftIconView.frame.size.width+(self.labelView.frame.size.width-typeViewHeight)/2,TYPE_ICON_MARGIN,typeViewHeight, typeViewHeight);
        self.typeView.image = [UIImage imageNamed:self.typeIcon];
        
        
        self.mainView.frame = CGRectMake((width-ITEM_WIDTH)/2, 0, ITEM_WIDTH, height);
        [self.contentView addSubview:self.mainView];
        
        
        
    }
    
    
        if(!self.leftIconView){
            
        }else{
            self.leftIconView.frame = CGRectMake(10, LEFT_IMAGE_MARGIN, (height-LEFT_IMAGE_MARGIN*2)*4/3, height-LEFT_IMAGE_MARGIN*2);
            
            NSString *filePath = [Utils getHeaderFilePathWithId:self.contactId];
            UIImage *leftIconImg = [UIImage imageWithContentsOfFile:filePath];
            if(leftIconImg==nil){
                leftIconImg = [UIImage imageNamed:@"ic_header.png"];
            }
            leftIconImg = [leftIconImg stretchableImageWithLeftCapWidth:leftIconImg.size.width*0.5 topCapHeight:leftIconImg.size.height*0.5];
            self.leftIconView.image = leftIconImg;
            self.leftIconView.contentMode = UIViewContentModeScaleAspectFit;
            [self.mainView addSubview:self.leftIconView];
            
        }
        
    
}


-(void)lightButton:(UIView*)view{
    
    self.mainView.backgroundColor = XBlue;
}

-(void)normalButton:(UIView*)view{
    [UIView transitionWithView:self.mainView duration:0.3 options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        self.mainView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
                    }
                    completion:^(BOOL finished) {
        
                    }
     ];
    
}

-(void)onSendButtonPress:(UIButton*)button{
    [self normalButton:button];
    
    if(self.delegate){
        [self.delegate onShakeCellPress:self contactId:self.contactId contactType:self.contactType contactFlag:self.contactFlag address:self.address];
    }
}

-(void)onButtonPress:(UIButton*)button{
    [self normalButton:button];
    
    if(self.delegate){
        [self.delegate onShakeCellPress:self contactId:self.contactId contactType:self.contactType contactFlag:self.contactFlag address:self.address];
    }
}
@end
