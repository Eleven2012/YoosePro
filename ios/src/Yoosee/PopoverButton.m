//
//  PopoverButton.m
//  Yoosee
//
//  Created by gwelltime on 15-3-24.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "PopoverButton.h"

#define TITLE_ICON_SPACE 10.0
#define TITLE_WIDTH 80.0
#define TITLE_HEIGHT 30.0
#define ICON_WIDTH 42.0
#define ICON_HEIGHT 30.0

@implementation PopoverButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    
    CGFloat leftMargin = (contentRect.size.width-(ICON_WIDTH+TITLE_WIDTH+TITLE_ICON_SPACE))/2.0;
    CGFloat topMargin = (contentRect.size.height-ICON_HEIGHT)/2.0;
    
    CGFloat titleW = TITLE_WIDTH;
    
    CGFloat titleH = TITLE_HEIGHT;
    
    CGFloat titleX = leftMargin + ICON_WIDTH + TITLE_ICON_SPACE;
    
    CGFloat titleY = topMargin;
    
    
    
    contentRect = (CGRect){{titleX,titleY},{titleW,titleH}};
    
    return contentRect;
    
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    CGFloat leftMargin = (contentRect.size.width-(ICON_WIDTH+TITLE_WIDTH+TITLE_ICON_SPACE))/2.0;
    CGFloat topMargin = (contentRect.size.height-ICON_HEIGHT)/2.0;
    
    CGFloat imageW = ICON_WIDTH;
    
    CGFloat imageH = ICON_HEIGHT;
    
    CGFloat imageX = leftMargin;
    
    CGFloat imageY = topMargin;
    
    
    
    contentRect = (CGRect){{imageX,imageY},{imageW,imageH}};
    
    return contentRect;
    
}

@end
