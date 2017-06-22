//
//  BottomBar.m
//  Yoosee
//
//  Created by guojunyi on 14-4-11.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "BottomBar.h"
#import "Constants.h"
@implementation BottomBar

-(void)dealloc{
    [self.items release];
    [self.backViews release];
    [self.iconViews release];
    [self.itemTitles release];
    [self.infoBadgeView release];
    [self.mallBadgeView release];
    [super dealloc];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    //需要做一些判断，有新的通知，则显示角标badge；查看新通知，清除角标
//    if (self.isHavingNewInfo) {//新的消息
//        self.infoBadgeView.badgeText = @"1";
//    }else{
//        self.infoBadgeView.badgeText = @"";
//    }
//    if (self.isHavingNewMallInfo) {//新的商城消息
//        self.mallBadgeView.badgeText = @"1";
//    }else{
//        self.mallBadgeView.badgeText = @"";
//    }
}

#define ITEM_COUNT 4
#define ICON_MARGIN 6
#define kIconRate 0.7
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.items = [NSMutableArray arrayWithCapacity:0];
        self.iconViews = [NSMutableArray arrayWithCapacity:0];
        self.itemTitles = [NSMutableArray arrayWithCapacity:0];
        self.backViews = [NSMutableArray arrayWithCapacity:0];
        self.selectedIndex = 0;
        CGFloat itemWidth = frame.size.width/ITEM_COUNT;

        for(int i=0;i<ITEM_COUNT;i++){
            
            //create item
            UIButton *item = [[UIButton alloc] init];
            item.frame = CGRectMake(itemWidth*i, 0, itemWidth, frame.size.height);
            
            //item background
            UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, item.frame.size.width, item.frame.size.height)];
            UIImage *backImg = [UIImage imageNamed:@"bg_tab_item.png"];
            backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
            backView.image = backImg;
            [item addSubview:backView];
            
            //item icon
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((backView.frame.size.width-backView.frame.size.height+ICON_MARGIN*2)/2, 0, backView.frame.size.height-ICON_MARGIN*2, backView.frame.size.height*kIconRate)];
            //iconView.frame = CGRectMake((backView.frame.size.width-30)/2, 0, 40, 30);
            UIImage *iconImg = nil;
            //item title
            UILabel *itemTitle = [[UILabel alloc] initWithFrame:CGRectMake(ICON_MARGIN, iconView.frame.size.height, backView.frame.size.width-ICON_MARGIN*2, backView.frame.size.height*(1-kIconRate))];
            //itemTitle.frame = CGRectMake((backView.frame.size.width-180)/2, 30, 180, 19);
            itemTitle.backgroundColor = [UIColor clearColor];
            [itemTitle setFont:XFontBold_14];
            itemTitle.textAlignment = UITextAlignmentCenter;
            switch(i){
                case 0:
                {
                    iconImg = [UIImage imageNamed:@"ic_tab_item_contact_p.png"];
                    itemTitle.text = NSLocalizedString(@"device", nil);
                    itemTitle.textColor = XBlue;
                    
                }
                    break;
                case 1:
                {
                    iconImg = [UIImage imageNamed:@"ic_tab_item_keyboard.png"];
                    itemTitle.text = NSLocalizedString(@"message_item", nil);
                    itemTitle.textColor = [UIColor lightGrayColor];
                    
                    //set badge
                    JSBadgeView *badgeView  = [[JSBadgeView alloc ] initWithParentView:iconView alignment:JSBadgeViewAlignmentTopRight];
                    //badgeView.badgeText = @"1";
                    [badgeView setBadgeTextColor:[UIColor redColor]];
                    [badgeView setBadgePositionAdjustment:CGPointMake(-6.0, 12.0)];
                    [iconView addSubview:badgeView];
                    self.infoBadgeView = badgeView;
                    [badgeView release];
                }
                    break;
                case 2:
                {
                    iconImg = [UIImage imageNamed:@"ic_tab_toolbox.png"];
                    itemTitle.text = NSLocalizedString(@"screen_shot_item", nil);
                    itemTitle.textColor = [UIColor lightGrayColor];
                    
                    //set badge
                    JSBadgeView *badgeView  = [[JSBadgeView alloc ] initWithParentView:iconView alignment:JSBadgeViewAlignmentTopRight];
                    //badgeView.badgeText = @"1";
                    [badgeView setBadgeTextColor:[UIColor redColor]];
                    [badgeView setBadgePositionAdjustment:CGPointMake(-6.0, 12.0)];
                    [iconView addSubview:badgeView];
                    self.mallBadgeView = badgeView;
                    [badgeView release];
                }
                    break;
                case 3:
                {
                    iconImg = [UIImage imageNamed:@"ic_tab_item_setting.png"];
                    itemTitle.text = NSLocalizedString(@"more_item", nil);
                    itemTitle.textColor = [UIColor lightGrayColor];
                }
                    break;
//                case 4:
//                {
//                    iconImg = [UIImage imageNamed:@"ic_tab_item_setting.png"];
//                }
//                    break;
            }
            //iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            iconView.image = iconImg;
            [backView addSubview:iconView];
            [backView addSubview:itemTitle];
            [self.itemTitles addObject:itemTitle];
            [self.iconViews addObject:iconView];
            [self.backViews addObject:backView];
            [itemTitle release];
            [iconView release];
            [backView release];
            
            [self addSubview:item];
            [self.items addObject:item];
            [item release];
        }
        
        
    }
    return self;
}


-(void)updateItemIcon:(NSInteger)willSelectedIndex{
    //get current-selected item background
    UIImageView *backView = [self.backViews objectAtIndex:self.selectedIndex];
    //get current-selected item icon
    UIImageView *iconView = [self.iconViews objectAtIndex:self.selectedIndex];
    //get current-selected item title
    UILabel *itemTitle = [self.itemTitles objectAtIndex:self.selectedIndex];
    
    //get will-selected item background
    UIImageView *willBackView = [self.backViews objectAtIndex:willSelectedIndex];
    //get will-selected item icon
    UIImageView *willIconView = [self.iconViews objectAtIndex:willSelectedIndex];
    //get will-selected item title
    UILabel *willItemTitle = [self.itemTitles objectAtIndex:willSelectedIndex];
    
    UIImage *backImg = [UIImage imageNamed:@"bg_tab_item.png"];
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backView.image = backImg;
    [backView setImage:backImg];
    
    UIImage *willBackImg = [UIImage imageNamed:@"bg_tab_item_p.png"];
    willBackImg = [willBackImg stretchableImageWithLeftCapWidth:willBackImg.size.width*0.5 topCapHeight:willBackImg.size.height*0.5];
    willBackView.image = willBackImg;
    [willBackView setImage:willBackImg];
    
    switch(self.selectedIndex){//update current-selected icon
        case 0:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_contact.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [iconView setImage:iconImg];
            
            itemTitle.textColor = [UIColor lightGrayColor];
        }
            break;
        case 1:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_keyboard.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [iconView setImage:iconImg];
            
            itemTitle.textColor = [UIColor lightGrayColor];
        }
            break;
        case 2:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_toolbox.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [iconView setImage:iconImg];
            
            itemTitle.textColor = [UIColor lightGrayColor];
        }
            break;
        case 3:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_setting.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [iconView setImage:iconImg];
            
            itemTitle.textColor = [UIColor lightGrayColor];
        }
            break;
//        case 4:
//        {
//            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_setting.png"];
//            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
//            [iconView setImage:iconImg];
//        }
//            break;
    }
    
    switch(willSelectedIndex){//update will-selected icon
        case 0:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_contact_p.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [willIconView setImage:iconImg];
            
            willItemTitle.textColor = XBlue;
        }
            break;
        case 1:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_keyboard_p.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [willIconView setImage:iconImg];
            
            willItemTitle.textColor = XBlue;
        }
            break;
        case 2:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_toolbox_p.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [willIconView setImage:iconImg];
            
            willItemTitle.textColor = XBlue;
        }
            break;
        case 3:
        {
            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_setting_p.png"];
            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
            [willIconView setImage:iconImg];
            
            willItemTitle.textColor = XBlue;
        }
            break;
//        case 4:
//        {
//            UIImage *iconImg = [UIImage imageNamed:@"ic_tab_item_setting_p.png"];
//            iconImg = [iconImg stretchableImageWithLeftCapWidth:iconImg.size.width*0.5 topCapHeight:iconImg.size.height*0.5];
//            [willIconView setImage:iconImg];
//        }
//            break;
    }
    
    self.selectedIndex = willSelectedIndex;
}
@end
