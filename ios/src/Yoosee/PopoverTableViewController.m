//
//  PopoverTableViewController.m
//  Yoosee
//
//  Created by gwelltime on 15-3-9.
//  Copyright (c) 2015年 guojunyi. All rights reserved.
//

#import "PopoverTableViewController.h"
#import "Constants.h"
#import "PopoverCell.h"
#import "AutoNavigation.h"
#import "AddContactNextController.h"
#import "QRCodeController.h"
#import "DXPopover.h"

@interface PopoverTableViewController ()

@end

@implementation PopoverTableViewController

-(void)dealloc{
    [self.navigationController release];
    [self.popover release];
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.tableView registerClass:[PopoverCell class] forCellReuseIdentifier:@"CellOne"];  //6.0
    //[self.tableView setSeparatorInset:UIEdgeInsetsZero]; //7.0
    
    self.tableView.backgroundView = nil;
    self.tableView.scrollEnabled = NO;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BAR_BUTTON_HEIGHT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"CellOne";
    PopoverCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[PopoverCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
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
                
                backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];
                [cell setLeftIcon:@"img_radar_add.png"];
                [cell setLabelText:NSLocalizedString(@"qrcode_add", nil)];
            }else{
                
                backImg = [UIImage imageNamed:@"bg_bar_btn_center.png"];
                backImg_p = [UIImage imageNamed:@"bg_bar_btn_center_p.png"];
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
    
    // 第四：气泡消失
    [self.popover dismissPopoverAnimated:YES];
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

@end
