//
//  GroupHead.m
//  Yoosee
//
//  Created by gwelltime on 14-11-14.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "GroupHead.h"

#define GROUP_NAME_LABEL_WIDTH 100
#define STATUS_LABEL_WIDTH 20

@implementation GroupHead

-(void)dealloc{
    [self.backImageView release];
    [self.groupNameLabel release];
    [self.statusLabel release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!self.backImageView) {
            UIImage *backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
            UIImageView *backImageView = [[UIImageView alloc] init];
            backImageView.frame = CGRectMake(-20, 0, self.frame.size.width+40, self.frame.size.height);
            backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
            backImageView.image = backImg;
            
            [self addSubview:backImageView];
            self.backImageView = backImageView;
            [backImageView release];
        }else{
            UIImage *backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
            self.backImageView.frame = CGRectMake(-20, 0, self.frame.size.width+40, self.frame.size.height);
            backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
            self.backImageView.image = backImg;
            
            [self addSubview:self.backImageView];
        }
        if (!self.groupNameLabel) {
            UILabel *groupNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, GROUP_NAME_LABEL_WIDTH, self.frame.size.height)];
            groupNameLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:groupNameLabel];
            self.groupNameLabel = groupNameLabel;
            [groupNameLabel release];
        }else{
            self.groupNameLabel.frame = CGRectMake(20, 0, GROUP_NAME_LABEL_WIDTH, self.frame.size.height);
            self.groupNameLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:self.groupNameLabel];
        }
        
        if (!self.statusLabel) {
            UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-30, 0, STATUS_LABEL_WIDTH, self.frame.size.height)];
            statusLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:statusLabel];
            self.statusLabel = statusLabel;
            [statusLabel release];
            [self.statusLabel setHidden:self.isStatusLabelHidden];
        }else{
            self.statusLabel.frame = CGRectMake(self.frame.size.width-30, 0, STATUS_LABEL_WIDTH, self.frame.size.height);
            self.statusLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:self.statusLabel];
            [self.statusLabel setHidden:self.isStatusLabelHidden];
        }
        
        
    }
    return self;
}

- (void)refreshUIWithDictionary:(NSDictionary *)dictionary{
    _groupNameLabel.text = dictionary[@"groupName"];
    NSString *isHidden = dictionary[@"isHidden"];
    if ([isHidden intValue] == 1) {
        _statusLabel.text = @">";
    }else{
        _statusLabel.text = @"v";
    }
}

-(void)setStatusLabelHidden:(BOOL)hidden{
    self.isStatusLabelHidden = hidden;
    if (self.statusLabel) {
        [self.statusLabel setHidden:hidden];
    }
}

@end
