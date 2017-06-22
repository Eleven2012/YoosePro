//
//  YButton.m
//  Yoosee
//
//  Created by guojunyi on 14-7-24.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "YButton.h"

@implementation YButton
@synthesize image = _image;
@synthesize image_p = _image_p;

static bool isDown;
-(void)dealloc{
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:backgroundView];
        [backgroundView release];
        [self addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(lightButton:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchCancel];
        [self addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(normalButton:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return self;
}




-(void)onButtonPress:(UIView*)view{
    [self normalButton:view];
    if(self.delegate){
        [self.delegate onYButtonClick:self];
    }
}

-(void)lightButton:(UIView*)view{
    //view.backgroundColor = XBlue;
    if(!isDown){
        isDown = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while(isDown){
                if(self.delegate){
                    [self.delegate onYButtonDown:self];
                }
                
                usleep(600000);
            }
        });
    }
    
    UIImageView *backgroundView = [[view subviews] objectAtIndex:0];
    backgroundView.image = [UIImage imageNamed:_image_p];
}

-(void)normalButton:(UIView*)view{
    //view.backgroundColor = XWhite;
    isDown = NO;
    
    UIImageView *backgroundView = [[view subviews] objectAtIndex:0];
    backgroundView.image = [UIImage imageNamed:_image];
}

-(void)setImage:(NSString *)image{
    _image = image;
    [_image retain];
    UIImageView *backgroundView = [[self subviews] objectAtIndex:0];
    backgroundView.image = [UIImage imageNamed:_image];
}

@end
