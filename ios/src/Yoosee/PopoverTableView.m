//
//  PopoverTableView.m
//  Yoosee
//
//  Created by gwelltime on 15-3-4.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "PopoverTableView.h"
#import "Constants.h"
#import "CustomCell.h"
#import "AutoNavigation.h"
#import "AddContactNextController.h"
#import "QRCodeController.h"
#import "DXPopover.h"

@implementation PopoverTableView

-(void)dealloc{
    [self.tableView release];
    [self.navigationController release];
    [self.popover release];
    [super dealloc];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(-17, 0, self.frame.size.width+34, self.frame.size.height) style:UITableViewStylePlain];
        [tableView setBackgroundColor:XBGAlpha];
        tableView.backgroundView = nil;
        tableView.scrollEnabled = NO;
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        [self addSubview:tableView];
        self.tableView = tableView;
        [tableView release];
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BAR_BUTTON_HEIGHT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"ToolBoxCell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        [cell setBackgroundColor:XBGAlpha];
        
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UIImage *backImg;
    UIImage *backImg_p;
    
    
    [cell setRightIcon:@"ic_arrow.png"];
    
    switch (section) {
        case 0:
        {
            if(row==0){

                backImg = [UIImage imageNamed:@"bg_bar_btn_top.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_top_p.png"];
                [cell setLeftIcon:@"img_radar_add.png"];
                [cell setLabelText:NSLocalizedString(@"qrcode_add", nil)];
            }else{
                
                backImg = [UIImage imageNamed:@"bg_bar_btn_bottom.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_bottom_p.png"];
                [cell setLeftIcon:@"ic_add_contact_manually.png"];
                [cell setLabelText:NSLocalizedString(@"manually_add", nil)];
            }
        }
            break;
            
            
    }
    
    
    
    UIImageView *backImageView = [[UIImageView alloc] init];
    
    backImg = [backImg stretchableImageWithLeftCapWidth:backImg.size.width*0.5 topCapHeight:backImg.size.height*0.5];
    backImageView.image = backImg;
    [cell setBackgroundView:backImageView];
    [backImageView release];
    
    UIImageView *backImageView_p = [[UIImageView alloc] init];
    
    backImg_p = [backImg_p stretchableImageWithLeftCapWidth:backImg_p.size.width*0.5 topCapHeight:backImg_p.size.height*0.5];
    backImageView_p.image = backImg_p;
    [cell setSelectedBackgroundView:backImageView_p];
    [backImageView_p release];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    [self.popover dismiss];//去掉泡沫
    switch(section){
        case 0:
        {
            if(row==0){
                QRCodeController *qecodeController = [[QRCodeController alloc] init];
               
                [self.navigationController pushViewController:qecodeController animated:YES];
                [qecodeController release];
            }else{
                AddContactNextController *addContactNextController = [[AddContactNextController alloc] init];
                addContactNextController.inType = 1;
                addContactNextController.isInFromManuallAdd = YES;
                [self.navigationController pushViewController:addContactNextController animated:YES];
                [addContactNextController release];
            }
        }
            break;
            
    }
    
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
